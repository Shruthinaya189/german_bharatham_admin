const express = require("express");
const router = express.Router();
const { adminLogin } = require("./adminController");
const { getCategoryStats, getDashboardStats } = require("./dashboardController");
const { protect, adminOnly } = require("../../middleware/auth");

router.post("/login", (req, res, next) => {
  console.log("🔵 /api/admin/login route hit!");
  console.log("Body:", req.body);
  next();
}, adminLogin);

// 🔐 Protected + Admin Only
router.get("/dashboard", protect, adminOnly, getDashboardStats);
router.get("/category-stats", protect, adminOnly, getCategoryStats);

module.exports = router;