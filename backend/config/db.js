const mongoose = require("mongoose");
const dns = require("dns");

// Optional custom DNS servers for MongoDB SRV lookups.
// Some networks block public DNS (8.8.8.8/1.1.1.1), which can cause querySrv timeouts.
// If you need to override DNS, set:
//   DNS_SERVERS=8.8.8.8,1.1.1.1
const dnsServers = (process.env.DNS_SERVERS || "")
  .split(",")
  .map((s) => s.trim())
  .filter(Boolean);

if (dnsServers.length > 0) {
  dns.setServers(dnsServers);
}

const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGO_URI, {
      serverSelectionTimeoutMS: 10000,
      socketTimeoutMS: 45000,
      family: 4, // Use IPv4, skip trying IPv6
    });
    console.log(`MongoDB Connected: ${conn.connection.host}`);
  } catch (error) {
    console.error("DB connection failed:", error.message);
    process.exit(1);
  }
};

module.exports = connectDB;