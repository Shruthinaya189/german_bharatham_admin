const User = require("../user/models/User");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

exports.adminLogin = async (req, res) => {
  console.log("=== ADMIN LOGIN ENDPOINT HIT ===");
  console.log("Request body:", JSON.stringify(req.body));
  console.log("Request headers:", JSON.stringify(req.headers));
  
  try {
    const { email, password } = req.body;

    console.log("Extracted email:", email);
    console.log("Extracted password:", password ? "***" : "NOT PROVIDED");

    // 1️⃣ Check if user exists
    const user = await User.findOne({ email });

    if (!user) {
      console.log("User not found in database:", email);
      return res.status(400).json({ message: "Invalid credentials" });
    }

    console.log("User found:", { email: user.email, role: user.role });

    // 2️⃣ Check role
    if (user.role !== "admin") {
      console.log("Not an admin:", user.role);
      return res.status(403).json({ message: "Access denied. Not an admin." });
    }

    // 3️⃣ Check password
    const isMatch = await bcrypt.compare(password, user.password);

    console.log("Password match:", isMatch);

    if (!isMatch) {
      console.log("Password mismatch");
      return res.status(400).json({ message: "Invalid credentials" });
    }

    // 4️⃣ Generate token
    const token = jwt.sign(
      { id: user._id, role: user.role },
      process.env.JWT_SECRET,
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