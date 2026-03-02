const User = require("../models/User");

// 👀 Get All Users (only role = user)
exports.getAllUsers = async (req, res) => {
  try {
    const users = await User.find({ role: "user" }).select("-password");
    res.json(users);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// ✅ Activate User
exports.activateUser = async (req, res) => {
  try {
    await User.findByIdAndUpdate(req.params.id, { isActive: true });
    res.json({ message: "User activated" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// ❌ Deactivate User
exports.deactivateUser = async (req, res) => {
  try {
    await User.findByIdAndUpdate(req.params.id, { isActive: false });
    res.json({ message: "User deactivated" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};