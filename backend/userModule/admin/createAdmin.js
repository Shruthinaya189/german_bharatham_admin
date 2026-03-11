const path = require("path");
require("dotenv").config({ path: path.resolve(__dirname, "../..", ".env") });

const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");
const User = require("../user/models/User");

const mongoUri = process.env.MONGO_URI || process.env.MONGODB_URI;
if (!mongoUri) {
  console.error("Missing MongoDB connection string. Set MONGO_URI in backend/.env");
  process.exit(1);
}

mongoose.connect(mongoUri)
  .then(async () => {

    const existingAdmin = await User.findOne({ email: "admin@german.com" });

    if (existingAdmin) {
      console.log("Admin already exists");
      process.exit();
    }

    const hashedPassword = await bcrypt.hash("admin@123", 10);

    await User.create({
      name: "Super Admin",
      email: "admin@german.com",
      password: hashedPassword,
      role: "admin",
    });

    console.log("Admin created successfully");
    process.exit();
  })
  .catch(err => console.log(err));