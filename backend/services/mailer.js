const nodemailer = require("nodemailer");

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
  });
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
  if (!cfg.user || !cfg.pass) {
    const err = new Error(
      "SMTP not configured. Set SMTP_USER and SMTP_PASS (and optionally SMTP_HOST/SMTP_PORT/SMTP_FROM)."
    );
    err.code = "SMTP_NOT_CONFIGURED";
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
