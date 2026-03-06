require("dotenv").config();
const express = require("express");
const cors = require("cors");
const connectDB = require("./config/db");
const path = require("path");

const app = express();

// Middleware
app.use(cors());
app.use(express.json({ limit: '25mb' }));
app.use(express.urlencoded({ extended: true, limit: '25mb' }));

// Serve static files (uploaded images)
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Root route
app.get("/", (req, res) => {
  res.send("Backend running successfully");
});



// Test route
app.get("/test", (req, res) => {
  res.send("Test route working");
});

// Routes
// Admin Routes
app.use("/api/admin", require("./userModule/admin/adminRoutes"));

// User Routes
app.use("/api/user", require("./userModule/user/routes/authRoutes"));

// Community Routes
app.use("/api/community", require("./communityModule/user/routes/communityRoutes"));
app.use("/api/admin/community", require("./communityModule/admin/Routes/communityRoutes"));

// Job Routes
app.use("/api/admin/jobs", require("./jobsModule/admin/jobAdminRoutes"));
app.use("/api/jobs", require("./jobsModule/user/jobUserRoutes"));

// Accommodation Routes
app.use("/api/accommodation/admin", require("./accommodationModule/admin/routes/accommodationRoutes"));
app.use("/api/accommodation/user", require("./accommodationModule/user.js"));

// Food & Grocery Routes
app.use("/api/food/admin", require("./foodGroceryModule/admin/index.js"));
app.use("/api/user/foodgrocery", require("./foodGroceryModule/user.js"));

const PORT = process.env.PORT || 5000;

// Start server after DB connection
const startServer = async () => {
  try {
    await connectDB();
    console.log("MongoDB Connected");

    app.listen(PORT, "0.0.0.0", () => {
      console.log(`Server running on port ${PORT}`);
    });
  } catch (err) {
    console.error("DB connection failed:", err.message);
    process.exit(1);
  }
};

startServer();