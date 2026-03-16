const Subscription = require("./models/Subscription");
const User = require("../userModule/user/models/User");
const Plan = require("./models/Plan");

const axios = require("axios");

const toNumber = (v) => {
  const n = Number(v);
  return Number.isFinite(n) ? n : 0;
};

const getDefaultCurrency = () => {
  return String(process.env.SUBSCRIPTIONS_CURRENCY || "INR").trim() || "INR";
};

const ensureDefaultPlans = async () => {
  const currency = getDefaultCurrency();

  // Map legacy env names to new plan ids.
  const price1m = toNumber(process.env.SUBSCRIPTIONS_MONTHLY_PRICE_INR);
  const price1y = toNumber(process.env.SUBSCRIPTIONS_YEARLY_PRICE_INR);
  const price3m = toNumber(process.env.SUBSCRIPTIONS_3MONTH_PRICE_INR);
  const price6m = toNumber(process.env.SUBSCRIPTIONS_6MONTH_PRICE_INR);

  const defaults = [
    { id: "free", label: "Free (7 days)", durationDays: 7, priceInr: 0, currency, active: true },
    { id: "1m", label: "1 Month", durationDays: 30, priceInr: price1m || 0, currency },
    { id: "3m", label: "3 Months", durationDays: 90, priceInr: price3m || 0, currency },
    { id: "6m", label: "6 Months", durationDays: 180, priceInr: price6m || 0, currency },
    { id: "1y", label: "1 Year", durationDays: 365, priceInr: price1y || 0, currency },
  ];

  const existing = await Plan.find({ id: { $in: defaults.map((d) => d.id) } })
    .select("id")
    .lean();
  const existingIds = new Set(existing.map((e) => e.id));
  const toCreate = defaults.filter((d) => !existingIds.has(d.id));
  if (toCreate.length > 0) {
    await Plan.insertMany(toCreate.map((p) => ({ ...p, active: true })), { ordered: false });
  }
};

const listActivePlans = async () => {
  await ensureDefaultPlans();
  return Plan.find({ active: true }).sort({ durationDays: 1 }).lean();
};

const getPlanById = async (planId) => {
  await ensureDefaultPlans();
  return Plan.findOne({ id: String(planId || "").trim() }).lean();
};

const getRazorpayKeys = () => {
  const keyId = String(process.env.RAZORPAY_KEY_ID || "").trim();
  const keySecret = String(process.env.RAZORPAY_KEY_SECRET || "").trim();
  if (!keyId || !keySecret) {
    const err = new Error("Missing RAZORPAY_KEY_ID / RAZORPAY_KEY_SECRET");
    err.statusCode = 500;
    throw err;
  }
  return { keyId, keySecret };
};

const razorpayApi = () => {
  const { keyId, keySecret } = getRazorpayKeys();
  return axios.create({
    baseURL: "https://api.razorpay.com/v1",
    auth: { username: keyId, password: keySecret },
    timeout: 20000,
  });
};

const getBaseUrl = (req) => {
  const configured = String(process.env.BACKEND_URL || "").trim();
  if (configured) return configured.replace(/\/$/, "");
  const proto = req.headers["x-forwarded-proto"]
    ? String(req.headers["x-forwarded-proto"]).split(",")[0].trim()
    : req.protocol;
  return `${proto}://${req.get("host")}`;
};

exports.getPlans = async (_req, res) => {
  const items = await listActivePlans();
  return res.status(200).json({
    plans: items.map((p) => ({
      id: p.id,
      label: p.label,
      currency: p.currency || "INR",
      price: p.priceInr,
      durationDays: p.durationDays,
    })),
  });
};

exports.getMySubscription = async (req, res) => {
  const sub = await Subscription.findOne({ userId: req.user.id }).sort({ createdAt: -1 }).lean();
  let user = await User.findById(req.user.id).select(
    "subscriptionStatus subscriptionPlan subscriptionExpiresAt firstLoginAt lastLoginAt"
  ).lean();

  // If user is new and has no subscription, ensure correct defaults
  if (user && !user.subscriptionPlan && (!user.subscriptionStatus || user.subscriptionStatus === 'none')) {
    user.subscriptionPlan = null;
    user.subscriptionStatus = 'none';
    user.subscriptionExpiresAt = null;
  }

  // Determine if free trial is completed
  let freeTrialCompleted = false;
  if (user) {
    if (user.subscriptionPlan === "free") {
      // If free plan and expired
      if (user.subscriptionExpiresAt && new Date(user.subscriptionExpiresAt) < new Date()) {
        freeTrialCompleted = true;
      }
    } else if (user.subscriptionPlan) {
      // If not on free plan, check if user ever had free plan and it expired
      // Optionally, you can check subscription history if needed
      // For now, if not on free plan, assume free trial completed
      freeTrialCompleted = true;
    }
  }

  return res.status(200).json({
    user: user ? { ...user, freeTrialCompleted } : null,
    subscription: sub || null,
  });
};

// Return the authenticated user's payment/subscription history.
exports.getPaymentHistory = async (req, res) => {
  const items = await Subscription.find({ userId: req.user.id })
    .sort({ createdAt: -1 })
    .lean();

  // Load plan metadata to include price/label where available
  const planIds = Array.from(new Set(items.map((it) => it.planId).filter(Boolean)));
  const plansMap = {};
  if (planIds.length > 0) {
    const planDocs = await Plan.find({ id: { $in: planIds } }).lean();
    planDocs.forEach((p) => (plansMap[p.id] = p));
  }

  const out = items.map((it) => {
    const plan = it.planId ? plansMap[it.planId] : null;
    return {
      date: it.createdAt ? it.createdAt.toISOString() : null,
      plan: plan ? (plan.label || plan.id) : (it.planId || null),
      amount: plan ? plan.priceInr : null,
      status: it.status || null,
    };
  });

  return res.status(200).json(out);
};

exports.createCheckoutSession = async (req, res) => {
  // Kept for backward compatibility with existing mobile/web clients.
  // Under the hood this now creates a Razorpay Payment Link and returns its short_url.
  try {
    const { planId } = req.body || {};
    const plan = await getPlanById(planId);

    if (!plan || plan.active === false) return res.status(400).json({ message: "Invalid planId" });

    // Handle free plan (price 0) directly
    if (Number(plan.priceInr) === 0) {
      // Activate free plan for user
      const now = new Date();
      const expiresAt = new Date(now.getTime() + (plan.durationDays || 7) * 24 * 60 * 60 * 1000);
      await User.findByIdAndUpdate(req.user.id, {
        subscriptionStatus: "trial",
        subscriptionPlan: plan.id,
        subscriptionExpiresAt: expiresAt,
      });
      return res.status(200).json({ message: "Free plan activated", free: true });
    }

    if (!plan.priceInr || Number(plan.priceInr) <= 0) {
      return res.status(400).json({ message: "Plan price not configured" });
    }

    const user = await User.findById(req.user.id).select("name email phone");
    if (!user) return res.status(404).json({ message: "User not found" });

    const api = razorpayApi();
    const appBase = getBaseUrl(req);

    const description = `German Bharatham - ${plan.label || plan.id} subscription`;

    const payload = {
      amount: Math.round(Number(plan.priceInr) * 100),
      currency: plan.currency || "INR",
      accept_partial: false,
      description,
      customer: {
        name: String(user.name || "").trim() || undefined,
        email: String(user.email || "").trim() || undefined,
        contact: String(user.phone || "").trim() || undefined,
      },
      notes: {
        userId: String(req.user.id),
        planId: String(plan.id),
      },
      callback_url: `${appBase}/api/subscriptions/razorpay/callback`,
      callback_method: "get",
    };

    const resp = await api.post("/payment_links", payload);
    const link = resp && resp.data ? resp.data : null;
    const url = link && (link.short_url || link.shortUrl || link.shorturl) ? (link.short_url || link.shortUrl || link.shorturl) : "";
    const paymentLinkId = link && link.id ? String(link.id) : null;
    if (!url || !paymentLinkId) {
      return res.status(500).json({ message: "Failed to create Razorpay payment link" });
    }

    await Subscription.findOneAndUpdate(
      { userId: req.user.id, razorpayPaymentLinkId: paymentLinkId },
      {
        $setOnInsert: {
          userId: req.user.id,
          provider: "razorpay",
          status: "pending",
          razorpayPaymentLinkId: paymentLinkId,
          metadata: { createdBy: "payment_link" },
        },
        $set: {
          planId: plan.id,
        },
      },
      { upsert: true, new: true }
    );

    return res.status(200).json({ url });
  } catch (error) {
    const status = error && error.response && error.response.status ? Number(error.response.status) : (error && error.statusCode ? Number(error.statusCode) : 500);
    const details = error && error.response && error.response.data ? JSON.stringify(error.response.data) : null;
    return res.status(status).json({
      message: error.message || "Failed to initialize payment",
      details,
    });
  }
};

exports.listAllSubscriptions = async (_req, res) => {
  const items = await Subscription.find()
    .populate("userId", "email")
    .sort({ createdAt: -1 })
    .limit(500)
    .lean();
  return res.status(200).json(items);
};


// List all plans (admin)
exports.listPlansAdmin = async (_req, res) => {
  await ensureDefaultPlans();
  const items = await Plan.find().sort({ durationDays: 1 }).lean();
  return res.status(200).json(
    items.map((p) => ({
      id: p.id,
      label: p.label,
      currency: p.currency || "INR",
      priceInr: p.priceInr,
      durationDays: p.durationDays,
      active: p.active !== false,
    }))
  );
};

// Bulk update plans (admin)
exports.upsertPlansAdmin = async (req, res) => {
  const payload = req.body && (req.body.plans || req.body);
  const arr = Array.isArray(payload) ? payload : [];
  if (arr.length === 0) return res.status(400).json({ message: "Missing plans" });

  await ensureDefaultPlans();

  const ops = [];
  for (const raw of arr) {
    if (!raw) continue;
    const id = String(raw.id || "").trim();
    if (!id) continue;

    const update = {
      label: raw.label !== undefined ? String(raw.label || "").trim() || id : undefined,
      currency: raw.currency !== undefined ? String(raw.currency || "INR").trim() || "INR" : undefined,
      priceInr: raw.priceInr !== undefined ? toNumber(raw.priceInr) : undefined,
      durationDays: raw.durationDays !== undefined ? Math.trunc(toNumber(raw.durationDays)) : undefined,
      active: raw.active !== undefined ? Boolean(raw.active) : undefined,
    };

    Object.keys(update).forEach((k) => update[k] === undefined && delete update[k]);
    ops.push({
      updateOne: {
        filter: { id },
        update: { $set: update, $setOnInsert: { id } },
        upsert: true,
      },
    });
  }

  if (ops.length === 0) return res.status(400).json({ message: "No valid plans to update" });
  await Plan.bulkWrite(ops);

  const items = await Plan.find().sort({ durationDays: 1 }).lean();
  return res.status(200).json(
    items.map((p) => ({
      id: p.id,
      label: p.label,
      currency: p.currency || "INR",
      priceInr: p.priceInr,
      durationDays: p.durationDays,
      active: p.active !== false,
    }))
  );
};

// Add a new plan (admin)
exports.createPlanAdmin = async (req, res) => {
  const { id, label, priceInr, durationDays, currency, active } = req.body || {};
  if (!id || !label || !durationDays) {
    return res.status(400).json({ message: "Missing required fields (id, label, durationDays)" });
  }
  const exists = await Plan.findOne({ id: String(id).trim() });
  if (exists) return res.status(400).json({ message: "Plan with this id already exists" });
  const plan = await Plan.create({
    id: String(id).trim(),
    label: String(label).trim(),
    priceInr: toNumber(priceInr),
    durationDays: Math.trunc(toNumber(durationDays)),
    currency: String(currency || "INR").trim(),
    active: active !== false,
  });
  return res.status(201).json(plan);
};

// Delete a plan (admin)
exports.deletePlanAdmin = async (req, res) => {
  const { id } = req.params;
  if (!id) return res.status(400).json({ message: "Missing plan id" });
  const plan = await Plan.findOneAndDelete({ id: String(id).trim() });
  if (!plan) return res.status(404).json({ message: "Plan not found" });
  return res.status(200).json({ message: "Plan deleted" });
};