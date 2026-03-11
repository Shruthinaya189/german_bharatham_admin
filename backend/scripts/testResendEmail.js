require("dotenv").config();

const { sendMail, hasSmtpConfig } = require("../services/mailer");

async function main() {
  const to = process.argv[2];
  if (!to) {
    console.error("Usage: node scripts/testResendEmail.js <recipient-email>");
    process.exit(2);
  }

  if (!hasSmtpConfig()) {
    console.error(
      "SMTP not configured. Set SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASS, SMTP_FROM in backend/.env or Render env vars."
    );
    process.exit(2);
  }

  const base = process.env.USER_RESET_PASSWORD_URL_BASE || "http://localhost:5000/reset-password";
  const token = `TEST_TOKEN_${Date.now()}`;
  const link = `${base}${base.includes("?") ? "&" : "?"}token=${encodeURIComponent(token)}`;

  const subject = "Test: Password reset link";
  const text = `Test reset link: ${link}`;
  const html = `<p>Test reset link:</p><p><a href=\"${link}\">${link}</a></p>`;

  try {
    await sendMail({ to, subject, text, html });
    console.log("Sent test email to:", to);
    console.log("Link:", link);
  } catch (err) {
    console.error("Failed to send test email.");
    console.error(err && err.message ? err.message : err);

    if (err && err.code) console.error("Code:", err.code);

    process.exit(1);
  }
}

main();
