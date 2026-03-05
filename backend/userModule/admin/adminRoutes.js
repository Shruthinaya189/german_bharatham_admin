const express = require("express");
const router = express.Router();
const { adminLogin, adminDashboard } = require("./adminController");
const { protect, adminOnly } = require("../../middleware/auth");

router.post("/login", (req, res, next) => {
  console.log("🔵 /api/admin/login route hit!");
  console.log("Body:", req.body);
  next();
}, adminLogin);

// 🔐 Protected + Admin Only
router.get("/dashboard", protect, adminOnly, adminDashboard);

module.exports = router;