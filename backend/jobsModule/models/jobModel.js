const mongoose = require("mongoose");

const jobSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: true,
    },
    category: {
      type: String,
      default: "Job",
    },
    companyName: String,
    companyLogo: String,
    location: String,
    description: String,
    contact: String,
    salary: String,
    jobType: {
      type: String,
      enum: ["Full Time", "Part Time"],
      default: "Full Time",
    },
    requirements: String,
    benefits: String,
    applyUrl: String,
    status: {
      type: String,
      default: "Active",
    },
    amenities: [String],
  },
  { timestamps: true }
);

// Collection name: jobs
module.exports = mongoose.model("Job", jobSchema);