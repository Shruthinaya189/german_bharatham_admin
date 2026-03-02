const { protect, adminOnly } = require("../../../middleware/auth");
const userController = require("../controllers/userController");
const express = require("express");
const router = express.Router();
const controller = require("../controllers/authController");

router.post("/register", controller.register);
router.post("/login", controller.login);
// 👑 Admin Routes
router.get("/all-users", protect, adminOnly, userController.getAllUsers);
router.put("/activate/:id", protect, adminOnly, userController.activateUser);
router.put("/deactivate/:id", protect, adminOnly, userController.deactivateUser);
module.exports = router;