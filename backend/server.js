require("dotenv").config();
const express = require("express");
const cors = require("cors");
const connectDB = require("./config/db");

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Routes
// Admin Routes
app.use("/api/admin", require("./userModule/admin/adminRoutes"));

// User Routes
app.use("/api/user", require("./userModule/user/routes/authRoutes"));

// Community
app.use("/api/community", require("./communityModule/user/routes/communityRoutes"));
app.use("/api/admin/community", require("./communityModule/admin/Routes/communityRoutes"));
app.get("/test", (req, res) => {
  res.send("Test route working");
});

const PORT = process.env.PORT || 5000;

// ✅ Wait for DB connection before starting server
const startServer = async () => {
  try {
    await connectDB(); // Ensure MongoDB connects first
    console.log("MongoDB Connected"); // Debug
    app.listen(PORT, "0.0.0.0", () => {
      console.log(`Server running on port ${PORT}`);
    });
  } catch (err) {
    console.error("DB connection failed:", err.message);
    process.exit(1);
  }
};

startServer();