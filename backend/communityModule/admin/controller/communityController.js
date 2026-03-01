const Guide = require("../model/Guide");

// public list – most recent first
exports.getAllGuides = async (req, res) => {
  try {
    const guides = await Guide.find().sort({ createdAt: -1 });
    res.json(guides);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getGuideById = async (req, res) => {
  try {
    const guide = await Guide.findById(req.params.id);
    if (!guide) return res.status(404).json({ message: "Not found" });
    res.json(guide);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.createGuide = async (req, res) => {
  try {
    const guide = new Guide(req.body);
    const saved = await guide.save();
    res.status(201).json(saved);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

exports.updateGuide = async (req, res) => {
  try {
    const updated = await Guide.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true }
    );
    res.json(updated);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

exports.deleteGuide = async (req, res) => {
  try {
    await Guide.findByIdAndDelete(req.params.id);
    res.json({ message: "Deleted successfully" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};