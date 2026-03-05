const Accommodation = require("../model/Accommodation");

// Get all accommodations
exports.getAllAccommodations = async (req, res) => {
  try {
    const items = await Accommodation.find().sort({ createdAt: -1 });
    res.json({ data: items, count: items.length });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Get single accommodation by ID
exports.getAccommodationById = async (req, res) => {
  try {
    const item = await Accommodation.findById(req.params.id);
    if (!item) return res.status(404).json({ message: "Item not found" });
    res.json(item);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Create new accommodation
exports.createAccommodation = async (req, res) => {
  try {
    const item = new Accommodation(req.body);
    const saved = await item.save();
    res.status(201).json(saved);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

// Update accommodation
exports.updateAccommodation = async (req, res) => {
  try {
    const updated = await Accommodation.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true }
    );
    if (!updated) return res.status(404).json({ message: "Item not found" });
    res.json(updated);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

// Delete accommodation
exports.deleteAccommodation = async (req, res) => {
  try {
    const deleted = await Accommodation.findByIdAndDelete(req.params.id);
    if (!deleted) return res.status(404).json({ message: "Item not found" });
    res.json({ message: "Deleted successfully" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
