const mongoose = require('mongoose');

const GenericListingSchema = new mongoose.Schema({
  categoryId:   { type: mongoose.Schema.Types.ObjectId, ref: 'Category', required: true },
  categoryName: { type: String, required: true },
  title:        { type: String, required: true, trim: true },
  description:  { type: String, default: '' },
  contactPhone: { type: String, default: '' },
  city:         { type: String, default: '' },
  area:         { type: String, default: '' },
  images:       [String],
  status:       { type: String, enum: ['active', 'disabled', 'pending'], default: 'active' },
}, { timestamps: true });

module.exports = mongoose.model('GenericListing', GenericListingSchema);
