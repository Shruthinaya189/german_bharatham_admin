require("dotenv").config();
const express = require("express");
const cors = require("cors");
const connectDB = require("./config/db");
const path = require("path");
const { protect, adminOnly } = require("./middleware/auth");

const app = express();

// Middleware
app.use(
  cors({
    origin: "*",
    methods: ["GET", "POST", "PUT", "DELETE", "PATCH"],
    credentials: false,
  })
);
app.use(express.json({ limit: "50mb" }));
app.use(express.urlencoded({ extended: true, limit: "50mb" }));

// Serve static files (uploaded images)
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

// ── User Module ─────────────────────────────────────────────────────────────
app.use("/api/admin", require("./userModule/admin/adminRoutes"));
app.use("/api/user", require("./userModule/user/routes/authRoutes"));

// ── Accommodation Module ────────────────────────────────────────────────────
app.use("/api/accommodation/admin", protect, require("./accommodationModule/admin"));
app.use("/api/accommodation/user", require("./accommodationModule/user"));

// ── Food & Grocery Module ───────────────────────────────────────────────────
const foodGroceryRoutes = require("./foodGroceryModule/admin/routes/foodGroceryRoutes");
console.log("Food Grocery routes loaded:", typeof foodGroceryRoutes);
app.use(
  "/api/admin/foodgrocery",
  (req, res, next) => {
    console.log(`📍 Food Grocery route accessed: ${req.method} ${req.path}`);
    next();
  },
  protect,
  foodGroceryRoutes
);
app.use("/api/user/foodgrocery", require("./foodGroceryModule/user"));

// ── Jobs Module ─────────────────────────────────────────────────────────────
app.use("/api/jobs/admin", protect, require("./jobsModule/admin"));
app.use("/api/jobs/user", require("./jobsModule/user"));

// ── Services Module ─────────────────────────────────────────────────────────
app.use("/api/services/admin", protect, require("./servicesModule/admin"));
app.use("/api/services/user", require("./servicesModule/user"));
// ── Universal Rating Module ─────────────────────────────────────────────────
app.use("/api/ratings", require("./routes/ratingRoutes"));

// ── Community Module ────────────────────────────────────────────────────────
app.use("/api/community", require("./communityModule/user/routes/communityRoutes"));
app.use(
  "/api/admin/community",
  require("./communityModule/admin/Routes/communityRoutes")
);

// ── Custom Category Module ──────────────────────────────────────────────────
app.use("/api/custom-categories", protect, require("./categoryModule/admin"));

// ── Settings Module ─────────────────────────────────────────────────────────
app.use("/api/admin/settings", require("./userModule/admin/settingsRoutes"));

// ── Utility routes ──────────────────────────────────────────────────────────
app.get("/", (req, res) => {
  res.send("German Bharatham Backend Running");
});
app.get("/api/health", (req, res) => {
  res.status(200).json({ message: "Server is running", status: "OK" });
});

// Password reset page (for email reset-link flow)
app.get("/reset-password", (req, res) => {
  const token = String(req.query.token || "").trim();
  res.setHeader("Content-Type", "text/html; charset=utf-8");
  res.send(`<!doctype html>
  <html lang="en">
    <head>
      <meta charset="utf-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1" />
      <title>Reset Password</title>
      <style>
        body{font-family:Arial,sans-serif;max-width:420px;margin:40px auto;padding:0 16px;}
        h1{font-size:20px;margin:0 0 12px;}
        label{display:block;margin:12px 0 6px;font-size:14px;}
        input{width:100%;padding:10px;border:1px solid #ccc;border-radius:8px;}
        button{margin-top:14px;width:100%;padding:10px;border:0;border-radius:8px;background:#4E7F6D;color:#fff;font-size:14px;cursor:pointer;}
        .msg{margin-top:12px;font-size:13px;white-space:pre-wrap;}
        .err{color:#b00020;}
        .ok{color:#1b5e20;}
      </style>
    </head>
    <body>
      <h1>Reset Password</h1>
      <p style="margin:0;color:#555;font-size:13px">Enter a new password to complete the reset.</p>

      <form id="f">
        <label for="pw">New password</label>
        <input id="pw" type="password" minlength="6" required />

        <label for="pw2">Confirm password</label>
        <input id="pw2" type="password" minlength="6" required />

        <button type="submit">Update Password</button>
      </form>

      <div id="msg" class="msg"></div>

      <script>
        const token = ${JSON.stringify(token)};
        const msg = document.getElementById('msg');
        const form = document.getElementById('f');

        if (!token) {
          msg.textContent = 'Missing reset token.';
          msg.className = 'msg err';
        }

        form.addEventListener('submit', async (e) => {
          e.preventDefault();
          if (!token) return;
          msg.textContent = '';
          msg.className = 'msg';

          const pw = document.getElementById('pw').value;
          const pw2 = document.getElementById('pw2').value;
          if (pw !== pw2) {
            msg.textContent = 'Passwords do not match.';
            msg.className = 'msg err';
            return;
          }

          try {
            const res = await fetch('/api/user/reset-password', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ token, newPassword: pw }),
            });

            const data = await res.json().catch(() => ({}));
            if (res.ok) {
              msg.textContent = data.message || 'Password updated successfully.';
              msg.className = 'msg ok';
              form.querySelector('button').disabled = true;
            } else {
              msg.textContent = data.message || ('Failed (HTTP ' + res.status + ')');
              msg.className = 'msg err';
            }
          } catch (err) {
            msg.textContent = 'Network error. Please try again.';
            msg.className = 'msg err';
          }
        });
      </script>
    </body>
  </html>`);
});

// Connect DB and start server
const PORT = process.env.PORT || 5000;
const HOST = process.env.HOST || "0.0.0.0";

(async () => {
  await connectDB();
  app.listen(PORT, HOST, () => {
    console.log(`Server running on http://${HOST}:${PORT}`);
  });
})();
