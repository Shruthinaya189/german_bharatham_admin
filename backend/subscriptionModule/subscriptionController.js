const Subscription = require("./models/Subscription");
const User = require("../userModule/user/models/User");
const { plans } = require("./subscriptionConfig");

const axios = require("axios");

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
  return res.status(200).json({
    plans: plans().map(({ amountPaise, ...p }) => ({
      ...p,
    })),
  });
};

exports.getMySubscription = async (req, res) => {
  const sub = await Subscription.findOne({ userId: req.user.id }).sort({ createdAt: -1 }).lean();
  const user = await User.findById(req.user.id).select(
    "subscriptionStatus subscriptionPlan subscriptionExpiresAt firstLoginAt lastLoginAt"
  );

  return res.status(200).json({
    user: user || null,
    subscription: sub || null,
  });
};

exports.createCheckoutSession = async (req, res) => {
  // Kept for backward compatibility with existing mobile/web clients.
  // Under the hood this now creates a Razorpay Payment Link and returns its short_url.
  try {
    const { planId } = req.body || {};
    const plan = plans().find((p) => p.id === String(planId || "").trim());
    if (!plan) {
      return res.status(400).json({ message: "Invalid planId" });
    }

    const user = await User.findById(req.user.id).select("name email phone");
    if (!user) return res.status(404).json({ message: "User not found" });

    const api = razorpayApi();
    const appBase = getBaseUrl(req);

    const description = `German Bharatham - ${plan.label || plan.id} subscription`;

    const payload = {
      amount: plan.amountPaise,
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
  const items = await Subscription.find().sort({ createdAt: -1 }).limit(500).lean();
  return res.status(200).json(items);
};