const User = require("../models/User");

// 🌐 Public-safe user profiles (role=user only)
exports.getPublicUsers = async (req, res) => {
  try {
    const users = await User.find({ role: "user", isActive: true })
      .select("name email phone photo role isActive createdAt");
    res.json(users);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// 👀 Get All Users (only role = user) - with pagination
exports.getAllUsers = async (req, res) => {
  try {
    // Parse pagination parameters
    const page = Math.max(1, parseInt(req.query.page) || 1);
    const limit = Math.min(100, Math.max(1, parseInt(req.query.limit) || 20));
    const skip = (page - 1) * limit;

    // Parallel count and data queries
    const [users, totalCount] = await Promise.all([
      User.find({ role: "user" })
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .lean() // Plain objects (faster)
        .select('_id name email phone photo isActive createdAt'), // Only needed fields
      User.countDocuments({ role: "user" })
    ]);

    res.json({
      data: users,
      count: users.length,
      totalCount,
      page,
      limit,
      totalPages: Math.ceil(totalCount / limit)
    });
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