const User = require("../models/User");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const crypto = require("crypto");
const { sendEmail } = require("../../../services/mailer");
const axios = require("axios");

let googleAuthLib;
try {
  googleAuthLib = require("google-auth-library");
} catch (_) {
  googleAuthLib = null;
}

let jose;
try {
  jose = require("jose");
} catch (_) {
  jose = null;
}

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

const parseCsv = (value) =>
  String(value || "")
    .split(",")
    .map((v) => v.trim())
    .filter(Boolean);

const getOrCreateSocialUser = async ({
  provider,
  providerUserId,
  email,
  name,
  photo,
}) => {
  const providerField =
    provider === "google"
      ? "googleId"
      : provider === "facebook"
        ? "facebookId"
        : provider === "apple"
          ? "appleSub"
          : null;

  if (!providerField) {
    throw new Error("Unsupported provider");
  }

  let user = await User.findOne({ [providerField]: providerUserId });

  if (!user && email) {
    user = await User.findOne({ email: String(email).toLowerCase().trim() });
    if (user && !user[providerField]) {
      user[providerField] = providerUserId;
      user.authProvider = provider;
      if (photo && !user.photo) user.photo = photo;
      if (name && !user.name) user.name = name;
      await user.save();
    }
  }

  if (!user) {
    if (!email) {
      // We require email to create an account because the schema enforces it.
      throw new Error("Email permission is required for this login");
    }
    user = await User.create({
      name: String(name || "User").trim() || "User",
      email: String(email).toLowerCase().trim(),
      password: null,
      role: "user",
      authProvider: provider,
      [providerField]: providerUserId,
      photo: photo || null,
    });
  }

  if (user.isActive === false) {
    const err = new Error("Account is deactivated");
    err.statusCode = 403;
    throw err;
  }

  return user;
};

const verifyGoogle = async ({ idToken, accessToken }) => {
  if (!googleAuthLib) {
    throw new Error(
      "Google auth library not installed. Run: npm install google-auth-library"
    );
  }

  const allowedClientIds = Array.from(
    new Set([
      ...parseCsv(process.env.GOOGLE_CLIENT_IDS),
      ...parseCsv(process.env.GOOGLE_CLIENT_ID),
      ...parseCsv(process.env.GOOGLE_SERVER_CLIENT_ID),
      ...parseCsv(process.env.GOOGLE_WEB_CLIENT_ID),
      ...parseCsv(process.env.GOOGLE_ANDROID_CLIENT_ID),
      ...parseCsv(process.env.GOOGLE_IOS_CLIENT_ID),
    ])
  );
  if (allowedClientIds.length === 0) {
    throw new Error(
      "Missing Google OAuth client id(s). Set GOOGLE_CLIENT_IDS (comma-separated) or GOOGLE_WEB_CLIENT_ID / GOOGLE_ANDROID_CLIENT_ID in .env"
    );
  }

  const trimmedIdToken = String(idToken || "").trim();
  const trimmedAccessToken = String(accessToken || "").trim();

  // Preferred: verify ID token (strong audience guarantee).
  if (trimmedIdToken) {
    const { OAuth2Client } = googleAuthLib;
    const client = new OAuth2Client();
    const ticket = await client.verifyIdToken({
      idToken: trimmedIdToken,
      audience: allowedClientIds,
    });
    const payload = ticket.getPayload() || {};

    return {
      providerUserId: payload.sub,
      email: payload.email,
      name: payload.name,
      photo: payload.picture,
      emailVerified: payload.email_verified,
    };
  }

  // Fallback: verify access token then fetch userinfo.
  // This helps Android sign-in succeed even when serverClientId is not set.
  if (!trimmedAccessToken) {
    throw new Error("Missing idToken or accessToken for Google login");
  }

  // Validate token and ensure it's intended for our app.
  const tokenInfoRes = await axios.get("https://oauth2.googleapis.com/tokeninfo", {
    params: { access_token: trimmedAccessToken },
    timeout: 10000,
  });
  const tokenInfo = tokenInfoRes.data || {};
  const aud = String(tokenInfo.aud || tokenInfo.audience || tokenInfo.issued_to || "").trim();
  if (aud && allowedClientIds.length > 0 && !allowedClientIds.includes(aud)) {
    const err = new Error("Wrong recipient, payload audience != requiredAudience");
    err.statusCode = 401;
    throw err;
  }

  const userInfoRes = await axios.get("https://www.googleapis.com/oauth2/v3/userinfo", {
    headers: { Authorization: `Bearer ${trimmedAccessToken}` },
    timeout: 10000,
  });
  const profile = userInfoRes.data || {};

  return {
    providerUserId: profile.sub || profile.id,
    email: profile.email,
    name: profile.name,
    photo: profile.picture,
    emailVerified: profile.email_verified,
  };
};

const verifyFacebook = async ({ accessToken }) => {
  const token = String(accessToken || "").trim();
  if (!token) throw new Error("Missing Facebook accessToken");

  const meRes = await axios.get("https://graph.facebook.com/me", {
    params: {
      fields: "id,name,email,picture.type(large)",
      access_token: token,
    },
    timeout: 10000,
  });
  const me = meRes.data || {};

  // Optional: validate token belongs to your app (recommended)
  const appId = String(process.env.FACEBOOK_APP_ID || "").trim();
  const appSecret = String(process.env.FACEBOOK_APP_SECRET || "").trim();
  if (appId && appSecret) {
    const appAccessToken = `${appId}|${appSecret}`;
    const dbgRes = await axios.get("https://graph.facebook.com/debug_token", {
      params: { input_token: token, access_token: appAccessToken },
      timeout: 10000,
    });
    const dbg = (dbgRes.data && dbgRes.data.data) || {};
    if (dbg.app_id && String(dbg.app_id) !== appId) {
      throw new Error("Facebook token app_id mismatch");
    }
    if (dbg.is_valid === false) {
      throw new Error("Facebook token is not valid");
    }
  }

  return {
    providerUserId: me.id,
    email: me.email,
    name: me.name,
    photo:
      me.picture && me.picture.data && me.picture.data.url ? me.picture.data.url : null,
  };
};

const verifyApple = async ({ identityToken }) => {
  if (!jose) {
    throw new Error("Apple token verification requires 'jose'. Run: npm install jose");
  }

  const token = String(identityToken || "").trim();
  if (!token) throw new Error("Missing Apple identityToken");

  const audience = String(process.env.APPLE_CLIENT_ID || "").trim();
  if (!audience) throw new Error("Missing APPLE_CLIENT_ID in .env");

  const jwks = jose.createRemoteJWKSet(new URL("https://appleid.apple.com/auth/keys"));
  const { payload } = await jose.jwtVerify(token, jwks, {
    issuer: "https://appleid.apple.com",
    audience,
  });

  return {
    providerUserId: payload.sub,
    email: payload.email,
    name: null,
    photo: null,
    emailVerified:
      payload.email_verified === "true" || payload.email_verified === true,
  };
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
    const {
      name, phone, photo,
      dob, gender, location, preferredCity,
      education, profession, germanLevel, passport,
    } = req.body;
    const update = {};
    if (name          !== undefined) update.name          = name.trim();
    if (phone         !== undefined) update.phone         = phone.trim();
    if (photo         !== undefined) update.photo         = photo;
    if (dob           !== undefined) update.dob           = dob;
    if (gender        !== undefined) update.gender        = gender;
    if (location      !== undefined) update.location      = location;
    if (preferredCity !== undefined) update.preferredCity = preferredCity;
    if (education     !== undefined) update.education     = education;
    if (profession    !== undefined) update.profession    = profession;
    if (germanLevel   !== undefined) update.germanLevel   = germanLevel;
    if (passport      !== undefined) update.passport      = passport;
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

    if (!user.password) {
      return res.status(400).json({
        message: "This account uses social login. Please login with Google/Facebook/Apple.",
      });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch)
      return res.status(400).json({ message: "Invalid credentials" });

    // Track first/last login timestamps
    const now = new Date();
    if (!user.firstLoginAt) user.firstLoginAt = now;
    user.lastLoginAt = now;
    await user.save();

    res.json({
      token: generateToken(user),
      user: sanitizeUser(user),
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// SOCIAL LOGIN (Google/Facebook/Apple) - token exchange
// Body examples:
// { provider: 'google', idToken: '...' }
// { provider: 'facebook', accessToken: '...' }
// { provider: 'apple', identityToken: '...' }
exports.socialLogin = async (req, res) => {
  try {
    const provider = String(req.body.provider || "").trim().toLowerCase();
    if (!provider) return res.status(400).json({ message: "provider is required" });

    let verified;
    if (provider === "google") {
      verified = await verifyGoogle({
        idToken: req.body.idToken,
        accessToken: req.body.accessToken,
      });
    } else if (provider === "facebook") {
      verified = await verifyFacebook({ accessToken: req.body.accessToken });
    } else if (provider === "apple") {
      verified = await verifyApple({ identityToken: req.body.identityToken });
    } else {
      return res.status(400).json({ message: "Unsupported provider" });
    }

    const user = await getOrCreateSocialUser({
      provider,
      providerUserId: verified.providerUserId,
      email: verified.email,
      name: verified.name,
      photo: verified.photo,
    });

    // Track first/last login timestamps
    const now = new Date();
    if (!user.firstLoginAt) user.firstLoginAt = now;
    user.lastLoginAt = now;
    await user.save();

    return res.status(200).json({
      token: generateToken(user),
      user: sanitizeUser(user),
    });
  } catch (error) {
    const status = error && error.statusCode ? Number(error.statusCode) : 500;
    return res.status(status).json({ message: error.message || "Social login failed" });
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

    if (!user.password) {
      return res.status(400).json({
        message: "This account does not have a password set (social login account).",
      });
    }

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

    // DEV_RETURN_RESET_LINK=true returns the reset URL in the API response
    // (useful for testing before SMTP is configured; also works in production if explicitly set)
    const devReturnLink =
      String(process.env.DEV_RETURN_RESET_LINK || "").toLowerCase() === "true";

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