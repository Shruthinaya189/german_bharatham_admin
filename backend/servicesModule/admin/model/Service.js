const mongoose = require("mongoose");

const serviceSchema = new mongoose.Schema(
  {
    title: { type: String, required: true },
    category: { type: String, default: "Services" },
    serviceType: { type: String, required: true }, // e.g., "Immigration", "Legal", "Financial", "Plumbing", "Cleaning"
    provider: { type: String }, // Company or individual name
    address: { type: String },
    city: { type: String, required: true },
    state: { type: String },
    zipCode: { type: String },
    phone: { type: String },
    email: { type: String },
    website: { type: String },
    description: { type: String },
    pricing: { type: String }, // e.g., "Hourly", "Fixed Rate"
    priceRange: { type: String }, // e.g., "$50-$100/hour"
    availability: { type: String },
    certifications: { type: [String], default: [] },
    languages: { type: [String], default: [] },
    image: { type: String },
    status: { type: String, enum: ['Active', 'Pending', 'Inactive'], default: 'Pending' },
    featured: { type: Boolean, default: false },
    verified: { type: Boolean, default: false },
  },
  { 
    timestamps: true,
    collection: "services"
  }
);

module.exports =
  mongoose.models.Service ||
  mongoose.model("Service", serviceSchema);
