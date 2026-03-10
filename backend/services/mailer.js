const nodemailer = require("nodemailer");

const hasSmtpConfig = () => {
  const host = String(process.env.SMTP_HOST || "").trim();
  const port = String(process.env.SMTP_PORT || "").trim();
  const user = String(process.env.SMTP_USER || "").trim();
  const pass = String(process.env.SMTP_PASS || "").trim();
  const from = String(process.env.SMTP_FROM || "").trim();
  return Boolean(host && port && user && pass && from);
};

const createTransporter = () => {
  const host = String(process.env.SMTP_HOST || "").trim();
  const port = Number(String(process.env.SMTP_PORT || "").trim());
  const user = String(process.env.SMTP_USER || "").trim();
  // Gmail app passwords are frequently copied with spaces; strip all whitespace.
  const pass = String(process.env.SMTP_PASS || "").replace(/\s+/g, "");
  return nodemailer.createTransport({
    host,
    port,
    secure: port === 465,
    auth: {
      user,
      pass,
    },
    // Fail fast to avoid reverse-proxy 502 when SMTP hangs (common on hosted envs)
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
  await transporter.sendMail({
    from: String(process.env.SMTP_FROM || "").trim(),
    to,
    subject,
    text,
    html,
  });
}

module.exports = { sendMail, hasSmtpConfig };
