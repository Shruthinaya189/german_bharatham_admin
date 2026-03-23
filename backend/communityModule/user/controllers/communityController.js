const Guide = require("../models/Guide");

exports.getAllGuides = async (req, res) => {
  try {
    // Parse pagination parameters
    const page = Math.max(1, parseInt(req.query.page) || 1);
    const limit = Math.min(100, Math.max(1, parseInt(req.query.limit) || 20));
    const skip = (page - 1) * limit;

    // Parallel count and data queries
    const [guides, totalCount] = await Promise.all([
      Guide.find()
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .lean() // Plain objects (faster)
        .select('_id title description category createdAt'), // Only needed fields
      Guide.countDocuments()
    ]);

    res.json({
      data: guides,
      count: guides.length,
      totalCount,
      page,
      limit,
      totalPages: Math.ceil(totalCount / limit)
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getGuideById = async (req, res) => {
  try {
    const guide = await Guide.findById(req.params.id);
    if (!guide) return res.status(404).json({ message: "Not found" });
    res.json(guide);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.createGuide = async (req, res) => {
  try {
    const guide = new Guide(req.body);
    const saved = await guide.save();
    res.status(201).json(saved);
  } catch (error) {
    res.status(400).json({ message: error.message });
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
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.deleteGuide = async (req, res) => {
  try {
    await Guide.findByIdAndDelete(req.params.id);
    res.json({ message: "Deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};