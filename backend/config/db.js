const mongoose = require("mongoose");

const connectDB = async () => {
  try {
    const mongoUri = process.env.MONGODB_URI;
    const mongoUriFallback = process.env.MONGODB_URI_FALLBACK;
    const dbName = process.env.MONGODB_DB_NAME || "german";

    if (!mongoUri) {
      throw new Error("MONGODB_URI is not set. Create backend/.env from backend/.env.example and provide a valid URI.");
    }

    try {
      await mongoose.connect(mongoUri, { dbName });
    } catch (primaryError) {
      const isSrvDnsError =
        primaryError &&
        (primaryError.code === "ECONNREFUSED" || primaryError.code === "ENOTFOUND") &&
        primaryError.syscall === "querySrv";

      if (isSrvDnsError && mongoUriFallback) {
        console.warn("Primary SRV Mongo URI failed. Retrying with MONGODB_URI_FALLBACK...");
        await mongoose.connect(mongoUriFallback, { dbName });
      } else if (isSrvDnsError && !mongoUriFallback) {
        console.error("SRV DNS resolution failed for MONGODB_URI. Set MONGODB_URI_FALLBACK with a non-SRV mongodb:// URI.");
        throw primaryError;
      } else {
        throw primaryError;
      }
    }
    
    console.log(`MongoDB connected successfully (db: ${dbName})`);
    
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
