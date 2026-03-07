require("dotenv").config();
const express = require("express");
const cors = require("cors");
const connectDB = require("./config/db");
const path = require("path");
const { protect, adminOnly } = require("./middleware/auth");

const app = express();

// Middleware
const allowedOrigins = [
  "http://localhost:3000",
  "https://germanbharatham.vercel.app/",
  process.env.FRONTEND_URL,
].filter(Boolean);

app.use(cors({
  origin: (origin, callback) => {
    // Allow requests with no origin (mobile apps, curl, Render health checks)
    if (!origin) return callback(null, true);
    if (allowedOrigins.includes(origin) || origin.endsWith(".vercel.app")) {
      return callback(null, true);
    }
    callback(new Error("Not allowed by CORS"));
  },
  credentials: true,
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

// ── Community Module ─────────────────────────────────────────────────────────
app.use("/api/community", require("./communityModule/user/routes/communityRoutes"));
app.use("/api/admin/community", require("./communityModule/admin/Routes/communityRoutes"));

// ── Custom Category Module ───────────────────────────────────────────────────
app.use("/api/custom-categories", protect, require("./categoryModule/admin"));

// ── Utility routes ───────────────────────────────────────────────────────────
app.get("/api/health", (req, res) => {
  res.status(200).json({ message: "Server is running", status: "OK" });
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
