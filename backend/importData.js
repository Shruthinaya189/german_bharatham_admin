const mongoose = require("mongoose");
const xlsx = require("xlsx");
require("dotenv").config();

const Guide = require("./models/Guide");

const importData = async () => {
  try {
    // 1️⃣ Connect to MongoDB
    await mongoose.connect(process.env.MONGO_URI);
    console.log("MongoDB Connected ✅");

    // 2️⃣ Read Excel file
    const workbook = xlsx.readFile("Guides_Dataset.xlsx");
    const sheetName = workbook.SheetNames[0];
    const sheet = workbook.Sheets[sheetName];
    const data = xlsx.utils.sheet_to_json(sheet);

    // 3️⃣ Insert data
    await Guide.insertMany(data);

    console.log("Data Imported Successfully 🎉");

    process.exit();
  } catch (error) {
    console.error("Error:", error.message);
    process.exit(1);
  }
};

importData();