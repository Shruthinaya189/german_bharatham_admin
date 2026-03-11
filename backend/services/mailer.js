const nodemailer = require("nodemailer");
const axios = require("axios");

const transientNetworkErrorCodes = new Set([
  "ETIMEDOUT",
  "ECONNRESET",
  "ECONNREFUSED",
  "EHOSTUNREACH",
  "ENETUNREACH",
]);

function buildTransport({ host, port, secure, user, pass }) {
  return nodemailer.createTransport({
    host,
    port,
    secure,
    auth: user && pass ? { user, pass } : undefined,

    connectionTimeout: 10000,
    greetingTimeout: 10000,
    socketTimeout: 20000,

    requireTLS: !secure,

    tls: {
      minVersion: "TLSv1.2",
      rejectUnauthorized: false
    }
  });
}

function emailProvider() {
  return String(process.env.EMAIL_PROVIDER || "")
    .trim()
    .toLowerCase();
}

async function sendViaResend({ to, subject, text, html, from }) {
  const apiKey = String(process.env.RESEND_API_KEY || "").trim();
  if (!apiKey) {
    const err = new Error("RESEND_API_KEY is not configured");
    err.code = "RESEND_NOT_CONFIGURED";
    throw err;
  }

  const resolvedFrom = String(process.env.RESEND_FROM || from || "").trim();
  if (!resolvedFrom) {
    const err = new Error(
      "Sender is not configured. Set RESEND_FROM (or SMTP_FROM/SMTP_USER)."
    );
    err.code = "RESEND_FROM_NOT_CONFIGURED";
    throw err;
  }

  const payload = {
    from: resolvedFrom,
    to: Array.isArray(to) ? to : [to],
    subject,
    ...(text ? { text } : {}),
    ...(html ? { html } : {}),
  };

  try {
    const resp = await axios.post("https://api.resend.com/emails", payload, {
      headers: {
        Authorization: `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      timeout: Number(process.env.EMAIL_HTTP_TIMEOUT_MS || 15_000),
    });

    // Normalize return shape (nodemailer returns { messageId, accepted, ... }).
    return {
      messageId: resp?.data?.id,
      accepted: payload.to,
      rejected: [],
      provider: "resend",
    };
  } catch (err) {
    // Bubble up a compact error but keep original details available.
    const status = err?.response?.status;
    const data = err?.response?.data;
    const e = new Error(
      `Resend API request failed${status ? ` (HTTP ${status})` : ""}`
    );
    e.code = "RESEND_REQUEST_FAILED";
    e.status = status;
    e.details = data;
    e.cause = err;
    throw e;
  }
}

function smtpConfig() {
  const host = String(process.env.SMTP_HOST || "smtp.gmail.com").trim();
  const port = Number(process.env.SMTP_PORT || 587);
  const secureEnv = String(process.env.SMTP_SECURE || "").trim();
  const secure = secureEnv ? secureEnv.toLowerCase() === "true" : port === 465;

  const user = String(process.env.SMTP_USER || "").trim();
  let pass = String(process.env.SMTP_PASS || "").trim();
  // Gmail app passwords are often displayed with spaces; authentication expects no spaces.
  if (/^smtp\.gmail\.com$/i.test(host)) {
    pass = pass.replace(/\s+/g, "");
  }
  const from = String(process.env.SMTP_FROM || user).trim();

  return { host, port, secure, user, pass, from };
}

async function sendEmail({ to, subject, text, html }) {
  const cfg = smtpConfig();
  const provider = emailProvider();
  const hasResend = Boolean(String(process.env.RESEND_API_KEY || "").trim());

  // Prefer HTTP-based provider in production unless explicitly forced to SMTP.
  if (provider === "resend" || (!provider && hasResend)) {
    return sendViaResend({ to, subject, text, html, from: cfg.from });
  }

  if (!cfg.user || !cfg.pass) {
    const err = new Error(
      "Email is not configured. Set RESEND_API_KEY/RESEND_FROM (recommended) or SMTP_USER/SMTP_PASS (and optionally SMTP_HOST/SMTP_PORT/SMTP_FROM)."
    );
    err.code = "EMAIL_NOT_CONFIGURED";
    throw err;
  }

  const transporter = buildTransport(cfg);

  const mail = {
    from: cfg.from,
    to,
    subject,
    ...(text ? { text } : {}),
    ...(html ? { html } : {}),
  };

  try {
    return await transporter.sendMail(mail);
  } catch (err) {
    // Common on some hosts: port 465 blocked/timeouts. If configured with 465, retry on 587.
    const code = err && (err.code || err.errno);
    const shouldRetry =
      cfg.port === 465 &&
      (transientNetworkErrorCodes.has(String(code)) ||
        /timeout/i.test(String(err.message || "")));

    if (!shouldRetry) throw err;

    const fallbackCfg = {
      ...cfg,
      port: 587,
      secure: false,
    };
    const fallbackTransporter = buildTransport(fallbackCfg);
    return fallbackTransporter.sendMail({ ...mail, from: fallbackCfg.from });
  }
}

module.exports = { sendEmail };
