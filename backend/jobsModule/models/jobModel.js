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

// Query performance indexes for admin listing pages.
jobSchema.index({ createdAt: -1 });
jobSchema.index({ status: 1, createdAt: -1 });
jobSchema.index({ location: 1 });

// Collection name: jobs
module.exports = mongoose.models.Job || mongoose.model("Job", jobSchema);