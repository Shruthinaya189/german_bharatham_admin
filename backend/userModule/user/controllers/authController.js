const User = require("../models/User");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const crypto = require("crypto");
const { sendMail, hasSmtpConfig } = require("../../../services/mailer");

const sanitizeUser = (userDoc) => {
  if (!userDoc) return null;
  const obj = typeof userDoc.toObject === "function" ? userDoc.toObject() : userDoc;
  if (obj.password !== undefined) delete obj.password;
  return obj;
};

const generateToken = (user) => {
  return jwt.sign(
    { id: user._id, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: "7d" }
  );
};

const sha256 = (value) =>
  crypto.createHash("sha256").update(String(value)).digest("hex");

const buildResetLink = (token) => {
  const base = process.env.USER_RESET_PASSWORD_URL_BASE;
  if (!base) return null;
  const joiner = base.includes("?") ? "&" : "?";
  return `${base}${joiner}token=${encodeURIComponent(token)}`;
};

// REGISTER
exports.register = async (req, res) => {
  try {
    const { name, email, phone, password } = req.body;

    const existingUser = await User.findOne({ email });
    if (existingUser)
      return res.status(400).json({ message: "User already exists" });

    const hashedPassword = await bcrypt.hash(password, 10);

    const user = await User.create({
      name,
      email,
      phone,
      password: hashedPassword,
      role: "user",
    });

    res.status(201).json({
      token: generateToken(user),
      user: sanitizeUser(user),
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// GET PROFILE
exports.getProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-password');
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.json(user);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// UPDATE PROFILE
exports.updateProfile = async (req, res) => {
  try {
    const { name, phone, photo } = req.body;
    const update = {};
    if (name !== undefined) update.name = name.trim();
    if (phone !== undefined) update.phone = phone.trim();
    if (photo !== undefined) update.photo = photo;
    const user = await User.findByIdAndUpdate(req.user.id, update, { new: true }).select('-password');
    if (!user) return res.status(404).json({ message: 'User not found' });
    res.json(user);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// LOGIN
exports.login = async (req, res) => {
  try {
    const identifierRaw = String(
      req.body.identifier ?? req.body.email ?? req.body.phone ?? ""
    ).trim();
    const password = String(req.body.password ?? "").trim();

    if (!identifierRaw || !password) {
      return res
        .status(400)
        .json({ message: "Email/Phone and password are required" });
    }

    const isLikelyEmail = identifierRaw.includes("@");
    const email = identifierRaw.toLowerCase();

    const phoneDigits = identifierRaw.replace(/\D/g, "");

    const query = isLikelyEmail
      ? { email }
      : {
          $or: [
            { phone: identifierRaw },
            ...(phoneDigits
              ? [
                  { phone: phoneDigits },
                  { phone: `+${phoneDigits}` },
                  { phone: new RegExp(`${phoneDigits}$`) },
                ]
              : []),
          ],
        };

    const user = await User.findOne(query);
    if (!user)
      return res.status(400).json({ message: "Invalid credentials" });

    if (user.isActive === false) {
      return res.status(403).json({ message: "Account is deactivated" });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch)
      return res.status(400).json({ message: "Invalid credentials" });

    res.json({
      token: generateToken(user),
      user: sanitizeUser(user),
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// CHANGE PASSWORD
exports.changePassword = async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;

    if (!currentPassword || !newPassword) {
      return res
        .status(400)
        .json({ message: "currentPassword and newPassword are required" });
    }

    const trimmedNew = String(newPassword).trim();
    if (trimmedNew.length < 6) {
      return res
        .status(400)
        .json({ message: "New password must be at least 6 characters" });
    }

    // protect middleware attaches user without password; fetch full user
    const user = await User.findById(req.user.id);
    if (!user) return res.status(404).json({ message: "User not found" });

    const isMatch = await bcrypt.compare(currentPassword, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: "Current password is incorrect" });
    }

    user.password = await bcrypt.hash(trimmedNew, 10);
    await user.save();

    return res.status(200).json({ message: "Password updated successfully" });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

// FORGOT PASSWORD (send reset link)
exports.forgotPassword = async (req, res) => {
  try {
    const email = String(req.body.email || "").trim().toLowerCase();
    if (!email) return res.status(400).json({ message: "Email is required" });

    const user = await User.findOne({ email });

    // Always respond success to avoid leaking which emails exist.
    if (!user) {
      return res.status(200).json({ message: "If the email exists, a reset link was sent." });
    }

    if (user.isActive === false) {
      return res.status(200).json({ message: "If the email exists, a reset link was sent." });
    }

    const token = crypto.randomBytes(32).toString("hex");
    user.resetPasswordToken = sha256(token);
    user.resetPasswordExpires = new Date(Date.now() + 60 * 60 * 1000); // 1 hour
    await user.save();

    const resetLink = buildResetLink(token);

    const devReturnLink = String(process.env.DEV_RETURN_RESET_LINK || "").toLowerCase() === "true";

    // If no URL base is configured, we can't build a usable link.
    if (!resetLink) {
      console.warn(
        "[forgotPassword] USER_RESET_PASSWORD_URL_BASE is not configured; cannot email reset link."
      );
      if (devReturnLink) {
        return res.status(200).json({
          message:
            "Reset link generated (dev). Configure USER_RESET_PASSWORD_URL_BASE to email it.",
          resetLink: `/reset-password?token=${token}`,
        });
      }
      // Always respond success to avoid leaking which emails exist.
      return res.status(200).json({ message: "If the email exists, a reset link was sent." });
    }

    const subject = "Reset your German Bharatham password";
    const text = `You requested a password reset. Open this link to set a new password: ${resetLink}`;
    const html = `
      <p>You requested a password reset.</p>
      <p><a href="${resetLink}">Click here to reset your password</a></p>
      <p>This link expires in 1 hour.</p>
    `;

    try {
      await sendMail({ to: user.email, subject, text, html });
    } catch (mailErr) {
      // Never fail the response (avoid leaking which emails exist); log for debugging.
      if (mailErr && mailErr.code === "SMTP_NOT_CONFIGURED") {
        console.warn(
          "[forgotPassword] SMTP not configured; set SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASS, SMTP_FROM"
        );
        if (devReturnLink) {
          console.log("[DEV] Password reset link:", resetLink);
          return res.status(200).json({
            message: "SMTP not configured; returning reset link for dev.",
            resetLink,
          });
        }
        return res.status(200).json({ message: "If the email exists, a reset link was sent." });
      }

      console.error("[forgotPassword] Failed to send reset email:", mailErr);
      return res.status(200).json({ message: "If the email exists, a reset link was sent." });
    }

    return res.status(200).json({ message: "If the email exists, a reset link was sent." });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};

// RESET PASSWORD (use token + new password)
exports.resetPassword = async (req, res) => {
  try {
    const token = String(req.body.token || "").trim();
    const newPassword = String(req.body.newPassword || "").trim();

    if (!token || !newPassword) {
      return res.status(400).json({ message: "token and newPassword are required" });
    }

    if (newPassword.length < 6) {
      return res.status(400).json({ message: "New password must be at least 6 characters" });
    }

    const tokenHash = sha256(token);
    const user = await User.findOne({
      resetPasswordToken: tokenHash,
      resetPasswordExpires: { $gt: new Date() },
    });

    if (!user) {
      return res.status(400).json({ message: "Invalid or expired reset token" });
    }

    user.password = await bcrypt.hash(newPassword, 10);
    user.resetPasswordToken = null;
    user.resetPasswordExpires = null;
    await user.save();

    return res.status(200).json({ message: "Password reset successful" });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};