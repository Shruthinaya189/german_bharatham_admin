// =======================
// Import Packages
// =======================
const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const dns = require("node:dns");
require("dotenv").config();

// =======================
// Create Express App
// =======================
const app = express();

// =======================
// Middleware
// =======================
app.use(cors());
app.use(express.json());

// =======================
// Environment Variables
// =======================
const MONGO_URI = process.env.MONGO_URI;
const PORT = process.env.PORT || 5000;

// =======================
// Configure Custom DNS (for college WiFi issues)
// =======================
function configureDnsServers() {
  const rawDnsServers = process.env.MONGO_DNS_SERVERS;

  if (!rawDnsServers) return;

  const dnsServers = rawDnsServers
    .split(",")
    .map((value) => value.trim())
    .filter(Boolean);

  if (!dnsServers.length) return;

  dns.setServers(dnsServers);
  console.log(
    `Using custom DNS servers for MongoDB: ${dnsServers.join(", ")}`
  );
}

// =======================
// Start Server Function
// =======================
async function startServer() {
  try {
    if (!MONGO_URI) {
      throw new Error("MONGO_URI is not defined in .env file");
    }

    configureDnsServers();

    await mongoose.connect(MONGO_URI, {
      serverSelectionTimeoutMS: 10000,
    });

    console.log("MongoDB Connected Successfully");
    console.log("Connected DB:", mongoose.connection.name);

    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });

  } catch (error) {
    console.error("MongoDB Connection Error:");
    console.error(error.message);

    if (error.message.includes("querySrv ECONNREFUSED")) {
      console.error(
        "DNS SRV lookup failed. Set MONGO_DNS_SERVERS=8.8.8.8,1.1.1.1 in .env and retry."
      );
    }

    process.exit(1);
  }
}

// =======================
// Routes
// =======================

// Health check route
app.get("/", (req, res) => {
  res.send("Backend is running");
});

// Admin Routes
app.use("/api/admin/jobs", require("./jobsModule/admin/jobAdminRoutes"));

// User Routes
app.use("/api/jobs", require("./jobsModule/user/jobUserRoutes"));

// =======================
// Start Application
// =======================
startServer();