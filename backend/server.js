require("dotenv").config();
const express = require("express");
const cors = require("cors");
const connectDB = require("./config/db");
const path = require("path");
const { protect, adminOnly } = require("./middleware/auth");

const app = express();

// Middleware
app.use(cors({
  origin: "*",
  methods: ["GET", "POST", "PUT", "DELETE", "PATCH"],
  credentials: false,
}));
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Serve static files (uploaded images)
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// ── User Module ─────────────────────────────────────────────────────────────
app.use("/api/admin", require("./userModule/admin/adminRoutes"));
app.use("/api/user", require("./userModule/user/routes/authRoutes"));

// ── Accommodation Module ─────────────────────────────────────────────────────
app.use("/api/accommodation/admin", protect, require("./accommodationModule/admin"));
app.use("/api/accommodation/user", require("./accommodationModule/user"));

// ── Food & Grocery Module ────────────────────────────────────
const foodGroceryRoutes = require("./foodGroceryModule/admin/routes/foodGroceryRoutes");
console.log("Food Grocery routes loaded:", typeof foodGroceryRoutes);
app.use("/api/admin/foodgrocery", (req, res, next) => {
  console.log(`📍 Food Grocery route accessed: ${req.method} ${req.path}`);
  next();
}, protect, foodGroceryRoutes);
const foodGroceryUserRoutes = require("./foodGroceryModule/user");

app.use("/api/user/foodgrocery", foodGroceryUserRoutes);

// ── Jobs Module ──────────────────────────────────────────────
app.use("/api/jobs/admin", protect, require("./jobsModule/admin"));
app.use("/api/jobs/user", require("./jobsModule/user"));

// ── Services Module ────────────────────────────────────────
app.use("/api/services/admin", protect, require("./servicesModule/admin"));
app.use("/api/services/user", require("./servicesModule/user"));
// ── Universal Rating Module ──────────────────────────────────────────
app.use("/api/ratings", require("./routes/ratingRoutes"));
// ── Community Module ─────────────────────────────────────────────────────────
app.use("/api/community", require("./communityModule/user/routes/communityRoutes"));
app.use("/api/admin/community", require("./communityModule/admin/Routes/communityRoutes"));

// ── Custom Category Module ───────────────────────────────────────────────────
app.use("/api/custom-categories", protect, require("./categoryModule/admin"));

// ── Settings Module ──────────────────────────────────────────────────────────
app.use("/api/admin/settings", require("./userModule/admin/settingsRoutes"));

// ── Utility routes ───────────────────────────────────────────────────────────
app.get("/", (req, res) => {
  res.send("German Bharatham Backend Running");
});
app.get("/api/health", (req, res) => {
  res.status(200).json({ message: "Server is running", status: "OK" });
});

// Minimal reset password page (for links emailed to users)
app.get("/reset-password", (req, res) => {
  res.setHeader("Content-Type", "text/html; charset=utf-8");
  res.send(`<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Reset Password</title>
    <style>
      :root { --primary: #4E7F6D; --bg: #F7F7F7; --text: #1b1b1b; --muted: #666; --danger: #b00020; }
      * { box-sizing: border-box; }
      body { margin: 0; font-family: Arial, sans-serif; background: var(--bg); color: var(--text); }
      .appbar { background: var(--primary); color: #fff; padding: 14px 16px; display: flex; align-items: center; justify-content: center; }
      .title { font-size: 18px; font-weight: 700; }
      .wrap { max-width: 520px; margin: 0 auto; padding: 18px 16px 28px; }
      .card { background: #fff; border-radius: 14px; padding: 16px; box-shadow: 0 1px 2px rgba(0,0,0,0.06); }
      p { margin: 0 0 12px; color: var(--muted); }
      label { display: block; margin: 12px 0 6px; font-size: 14px; }
      input { width: 100%; padding: 12px 12px; font-size: 14px; border: 1px solid #d0d0d0; border-radius: 10px; outline: none; }
      input:focus { border-color: var(--primary); box-shadow: 0 0 0 3px rgba(78,127,109,0.18); }
      button.primary { width: 100%; height: 46px; margin-top: 14px; padding: 10px 14px; font-size: 15px; cursor: pointer; border: 0; border-radius: 12px; background: var(--primary); color: #fff; font-weight: 700; }
      button.primary:disabled { opacity: 0.6; cursor: not-allowed; }
      .msg { margin-top: 12px; white-space: pre-wrap; font-size: 14px; }
      .error { color: var(--danger); }
      .ok { color: var(--primary); }
    </style>
  </head>
  <body>
    <div class="appbar">
      <div class="title">Reset Password</div>
    </div>

    <div class="wrap">
      <div class="card">
        <p>Enter your new password below.</p>

        <form id="form">
          <label for="password">New password</label>
          <input id="password" type="password" minlength="6" required />

          <label for="confirm">Confirm new password</label>
          <input id="confirm" type="password" minlength="6" required />

          <button class="primary" id="btn" type="submit">Reset password</button>
        </form>

        <div id="msg" class="msg"></div>
      </div>
    </div>

    <script>
      (function () {
        var params = new URLSearchParams(window.location.search);
        var token = params.get('token') || '';
        var msgEl = document.getElementById('msg');
        var form = document.getElementById('form');
        var btn = document.getElementById('btn');

        if (!token) {
          msgEl.className = 'msg error';
          msgEl.textContent = 'Missing token. Please open the full link from your email.';
          btn.disabled = true;
          return;
        }

        form.addEventListener('submit', async function (e) {
          e.preventDefault();
          msgEl.className = 'msg';
          msgEl.textContent = '';

          var password = document.getElementById('password').value || '';
          var confirm = document.getElementById('confirm').value || '';
          if (password.length < 6) {
            msgEl.className = 'msg error';
            msgEl.textContent = 'Password must be at least 6 characters.';
            return;
          }
          if (password !== confirm) {
            msgEl.className = 'msg error';
            msgEl.textContent = 'Passwords do not match.';
            return;
          }

          btn.disabled = true;
          btn.textContent = 'Resetting...';
          try {
            var resp = await fetch('/api/user/reset-password', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ token: token, newPassword: password })
            });
            var data = null;
            try { data = await resp.json(); } catch (_) {}
            if (resp.ok) {
              msgEl.className = 'msg ok';
              msgEl.textContent = (data && data.message) ? data.message : 'Password reset successful. Please return to the app and login.';
              form.reset();
            } else {
              msgEl.className = 'msg error';
              msgEl.textContent = (data && data.message) ? data.message : ('Failed (HTTP ' + resp.status + ')');
            }
          } catch (err) {
            msgEl.className = 'msg error';
            msgEl.textContent = 'Network error. Please try again.';
          } finally {
            btn.disabled = false;
            btn.textContent = 'Reset password';
          }
        });
      })();
    </script>
  </body>
</html>`);
});
app.get("/test", (req, res) => {
  res.send("Test route working");
});

// ── Global error handler ─────────────────────────────────────────────────────
app.use((err, req, res, next) => {
  console.error(err);
  res.status(err.status || 500).json({
    message: err.message || "Internal Server Error",
    status: err.status || 500
  });
});

// ── Start server (wait for DB first) ─────────────────────────────────────────
const PORT = process.env.PORT || 5000;

const startServer = async () => {
  try {
    await connectDB();
    app.listen(PORT, "0.0.0.0", () => {
      console.log(`Server running on http://localhost:${PORT}`);
    });
  } catch (err) {
    console.error("DB connection failed:", err.message);
    process.exit(1);
  }
};

startServer();

module.exports = app;
