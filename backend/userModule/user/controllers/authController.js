const User = require("../models/User");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const crypto = require("crypto");
const { sendEmail } = require("../../../services/mailer");

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

const getAppBaseUrl = (req) => {
  const configured = String(process.env.BACKEND_URL || "").trim();
  if (configured) return configured.replace(/\/$/, "");
  const proto = req.headers["x-forwarded-proto"]
    ? String(req.headers["x-forwarded-proto"]).split(",")[0].trim()
    : req.protocol;
  return `${proto}://${req.get("host")}`;
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
    const emailRaw = String(req.body.email || "").trim().toLowerCase();
    if (!emailRaw) return res.status(400).json({ message: "Email is required" });

    const user = await User.findOne({ email: emailRaw });

    // Always respond success to avoid leaking which emails exist.
    if (!user || user.isActive === false) {
      return res
        .status(200)
        .json({ message: "If the email exists, a reset link was sent." });
    }

    const resetToken = crypto.randomBytes(32).toString("hex");
    user.resetPasswordToken = sha256(resetToken);
    user.resetPasswordExpires = new Date(Date.now() + 60 * 60 * 1000); // 1 hour
    await user.save();

    const baseUrl = getAppBaseUrl(req);
    const resetUrl = `${baseUrl}/reset-password?token=${resetToken}`;

    const devReturnLink =
      String(process.env.DEV_RETURN_RESET_LINK || "").toLowerCase() === "true" &&
      String(process.env.NODE_ENV || "").toLowerCase() !== "production";

    const subject = "Reset your password";
    const text = `You requested a password reset. Open this link to set a new password: ${resetUrl}`;
    const html = `
      <div style="font-family:Arial,sans-serif;line-height:1.5">
        <h2 style="margin:0 0 12px">Reset your password</h2>
        <p>We received a request to reset your password.</p>
        <p><a href="${resetUrl}" style="display:inline-block;padding:10px 14px;background:#4E7F6D;color:#fff;text-decoration:none;border-radius:6px">Reset Password</a></p>
        <p style="color:#555">This link expires in 1 hour.</p>
        <p style="color:#777;font-size:12px">If you didn’t request this, you can ignore this email.</p>
      </div>
    `;

    let emailSent = true;
    try {
      const info = await sendEmail({ to: emailRaw, subject, text, html });
      try {
        console.log("[forgotPassword] Reset email sent", {
          to: emailRaw,
          messageId: info && info.messageId,
          accepted: info && info.accepted,
          rejected: info && info.rejected,
        });
      } catch (_) {}
    } catch (mailErr) {
      emailSent = false;
      console.error("[forgotPassword] Failed to send reset email:", mailErr);
    }

    if (devReturnLink) {
      return res.status(200).json({
        message: emailSent
          ? "Reset link generated. Returning reset link for dev."
          : "Email not sent. Returning reset link for dev.",
        resetUrl,
        emailSent,
      });
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
      return res
        .status(400)
        .json({ message: "New password must be at least 6 characters" });
    }

    const user = await User.findOne({
      resetPasswordToken: sha256(token),
      resetPasswordExpires: { $gt: new Date() },
    });

    if (!user) return res.status(400).json({ message: "Invalid or expired token" });

    user.password = await bcrypt.hash(newPassword, 10);
    user.resetPasswordToken = null;
    user.resetPasswordExpires = null;
    await user.save();

    return res.status(200).json({ message: "Password reset successful" });
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
};