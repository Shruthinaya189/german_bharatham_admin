const nodemailer = require("nodemailer");

const hasSmtpConfig = () => {
  const host = String(process.env.SMTP_HOST || "").trim();
  const port = String(process.env.SMTP_PORT || "").trim();
  const user = String(process.env.SMTP_USER || "").trim();
  const pass = String(process.env.SMTP_PASS || "").trim();
  const from = String(process.env.SMTP_FROM || "").trim();
  return Boolean(host && port && user && pass && from);
};

const toBool = (value, defaultValue = false) => {
  if (value === undefined || value === null || value === "") return defaultValue;
  const v = String(value).trim().toLowerCase();
  if (["1", "true", "yes", "y", "on"].includes(v)) return true;
  if (["0", "false", "no", "n", "off"].includes(v)) return false;
  return defaultValue;
};

const createTransporter = () => {
  const host = String(process.env.SMTP_HOST || "").trim();
  const port = Number(String(process.env.SMTP_PORT || "").trim());
  const user = String(process.env.SMTP_USER || "").trim();
  // App passwords are frequently copied with spaces; strip all whitespace.
  const pass = String(process.env.SMTP_PASS || "").replace(/\s+/g, "");

  // For some providers, forcing secure/STARTTLS helps.
  const secure = toBool(process.env.SMTP_SECURE, port === 465);
  const requireTLS = toBool(process.env.SMTP_REQUIRE_TLS, false);
  const rejectUnauthorized = toBool(process.env.SMTP_TLS_REJECT_UNAUTHORIZED, true);

  return nodemailer.createTransport({
    host,
    port,
    secure,
    auth: { user, pass },
    requireTLS,
    tls: { rejectUnauthorized },

    // Keep HTTP fast on hosted envs; fail quickly if SMTP is blocked.
    connectionTimeout: 10_000,
    greetingTimeout: 10_000,
    socketTimeout: 20_000,
  });
};

async function sendMail({ to, subject, text, html }) {
  if (!hasSmtpConfig()) {
    const err = new Error(
      "SMTP is not configured. Set SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASS, SMTP_FROM"
    );
    err.code = "SMTP_NOT_CONFIGURED";
    throw err;
  }

  const transporter = createTransporter();
  return transporter.sendMail({
    from: String(process.env.SMTP_FROM || "").trim(),
    to,
    subject,
    text,
    html,
  });
}

module.exports = { sendMail, hasSmtpConfig };
