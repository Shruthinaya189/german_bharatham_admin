require("dotenv").config();
const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");
const User = require("../user/models/User");

mongoose.connect(process.env.MONGO_URI)
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