const express = require("express");
const router = express.Router();
const { adminLogin, adminDashboard } = require("./adminController");
const { protect, adminOnly } = require("../../middleware/auth");

router.post("/login", adminLogin);

// 🔐 Protected + Admin Only
router.get("/dashboard", protect, adminOnly, adminDashboard);

module.exports = router;