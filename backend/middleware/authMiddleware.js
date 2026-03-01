const express = require("express");
const router = express.Router();
const controller = require("../controllers/communityController");

const { protect, adminOnly } = require("../../middleware/authMiddleware");

// Public route
router.get("/", controller.getAllGuides);

// Admin only routes
router.post("/", controller.createGuide);
router.delete("/:id", protect, adminOnly, controller.deleteGuide);

module.exports = router;