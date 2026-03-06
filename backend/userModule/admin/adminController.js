const User = require("../user/models/User");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

exports.adminLogin = async (req, res) => {
  try {
    const { email, password } = req.body;
    const normalizedEmail = (email || "").trim().toLowerCase();

    // 1️⃣ Check if user exists
    const user = await User.findOne({ email: normalizedEmail });

    if (!user) {
      return res.status(400).json({ message: "Invalid credentials" });
    }

    if (!user.password || typeof password !== "string") {
      return res.status(400).json({ message: "Invalid credentials" });
    }

    // 2️⃣ Check role
    if (user.role !== "admin") {
      return res.status(403).json({ message: "Access denied. Not an admin." });
    }

    // 3️⃣ Check password
    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(400).json({ message: "Invalid credentials" });
    }

    // 4️⃣ Generate token
    const jwtSecret = process.env.JWT_SECRET || "dev_jwt_secret";
    const token = jwt.sign(
      { id: user._id, role: user.role },
      jwtSecret,
      { expiresIn: "1d" }
    );

    res.json({
      message: "Admin login successful",
      token,
    });
    console.log("Logging in user:", user.email);
console.log("User role:", user.role);

  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error" });
  }
};

exports.adminDashboard = async (req, res) => {
  res.json({
    message: "Welcome Admin Dashboard",
  });
};