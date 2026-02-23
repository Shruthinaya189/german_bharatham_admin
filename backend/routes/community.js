const express = require("express");
const router = express.Router();
const controller = require("../controllers/communityController");

// Default route - returns all guides
router.get("/", controller.getGuides);

router.post("/guides", controller.createGuide);
router.get("/guides", controller.getGuides);
router.get("/guides/:id", controller.getGuideById);

module.exports = router;
