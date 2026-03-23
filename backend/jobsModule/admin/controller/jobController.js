const Job = require("../model/Job");

// Get all jobs (with pagination)
exports.getAllJobs = async (req, res) => {
  try {
    // Parse pagination parameters
    const page = Math.max(1, parseInt(req.query.page) || 1);
    const limit = Math.min(100, Math.max(1, parseInt(req.query.limit) || 20));
    const skip = (page - 1) * limit;

    // Parallel count and data queries
    const [items, totalCount] = await Promise.all([
      Job.find()
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .lean() // Plain objects (faster)
        .select('_id title company salary location status createdAt'), // Only needed fields
      Job.countDocuments()
    ]);

    res.json({ 
      data: items, 
      count: items.length,
      totalCount,
      page,
      limit,
      totalPages: Math.ceil(totalCount / limit)
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Get single job by ID
exports.getJobById = async (req, res) => {
  try {
    const item = await Job.findById(req.params.id);
    if (!item) return res.status(404).json({ message: "Item not found" });
    res.json(item);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Create new job
exports.createJob = async (req, res) => {
  try {
    const item = new Job(req.body);
    const saved = await item.save();
    res.status(201).json(saved);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

// Update job
exports.updateJob = async (req, res) => {
  try {
    const updated = await Job.findByIdAndUpdate(
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

// Delete job
exports.deleteJob = async (req, res) => {
  try {
    const deleted = await Job.findByIdAndDelete(req.params.id);
    if (!deleted) return res.status(404).json({ message: "Item not found" });
    res.json({ message: "Deleted successfully" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
