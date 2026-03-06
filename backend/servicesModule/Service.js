const mongoose = require('mongoose');

const serviceSchema = new mongoose.Schema(
  {
    serviceName: { type: String, required: true, trim: true },
    providerName: { type: String, required: true, trim: true },
    serviceType: { type: String, default: null, trim: true },
    description: { type: String, default: null, trim: true },
    city: { type: String, required: true, trim: true },
    area: { type: String, default: null, trim: true },
    address: { type: String, default: null, trim: true },
    postalCode: { type: String, default: null, trim: true },
    contactPhone: { type: String, required: true, trim: true },
    priceRange: { type: String, default: null, trim: true },
    media: {
      images: { type: [String], default: [] }
    },
    status: { type: String, enum: ['active', 'disabled', 'pending'], default: 'active' }
  },
  { timestamps: true }
);

module.exports = mongoose.model('Service', serviceSchema);

