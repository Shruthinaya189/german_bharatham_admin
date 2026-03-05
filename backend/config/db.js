const mongoose = require("mongoose");

const connectDB = async () => {
  try {
    const mongoUri = process.env.MONGO_URI;
    const mongoUriFallback = process.env.MONGO_URI_FALLBACK;

    if (!mongoUri) {
      throw new Error("MONGO_URI is not set. Create backend/.env from backend/.env.example and provide a valid URI.");
    }

    try {
      await mongoose.connect(mongoUri);
    } catch (primaryError) {
      const isSrvDnsError =
        primaryError &&
        (primaryError.code === "ECONNREFUSED" || primaryError.code === "ENOTFOUND") &&
        primaryError.syscall === "querySrv";

      if (isSrvDnsError && mongoUriFallback) {
        console.warn("Primary SRV Mongo URI failed. Retrying with MONGO_URI_FALLBACK...");
        await mongoose.connect(mongoUriFallback);
      } else if (isSrvDnsError && !mongoUriFallback) {
        console.error("SRV DNS resolution failed for MONGO_URI. Set MONGO_URI_FALLBACK with a non-SRV mongodb:// URI.");
        throw primaryError;
      } else {
        throw primaryError;
      }
    }
    
    console.log(`MongoDB connected successfully (db: ${mongoose.connection.db.databaseName})`);
    
    // Ensure accommodation database and collection
    const db = mongoose.connection.db;
    const collections = await db.listCollections().toArray();
    const accommodationExists = collections.some(col => col.name === "accommodations");
    
    if (!accommodationExists) {
      await db.createCollection("accommodations");
      console.log("Created accommodations collection");
    }
    
  } catch (error) {
    console.error("MongoDB connection error:", error);
    process.exit(1);
  }
};

module.exports = connectDB;
