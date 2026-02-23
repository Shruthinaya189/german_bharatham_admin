const Guide = require("../models/Guide");

// Create Guide
exports.createGuide = async (req, res) => {
  try {
    const guide = await Guide.create(req.body);
    res.status(201).json(guide);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Get All Guides
exports.getGuides = async (req, res) => {
  const guides = await Guide.find().sort({ createdAt: -1 });
  res.json(guides);
};

// Get Single Guide
exports.getGuideById = async (req, res) => {
  const guide = await Guide.findById(req.params.id);
  res.json(guide);
};
