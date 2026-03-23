const Service = require("../model/Service");

// Get all services (with pagination)
exports.getAllServices = async (req, res) => {
  try {
    // Parse pagination parameters
    const page = Math.max(1, parseInt(req.query.page) || 1);
    const limit = Math.min(100, Math.max(1, parseInt(req.query.limit) || 20));
    const skip = (page - 1) * limit;
    const statusRaw = String(req.query.status || '').trim().toLowerCase();

    const filter = {};
    if (statusRaw) {
      if (statusRaw === 'active') filter.status = { $in: ['Active', 'active'] };
      else if (statusRaw === 'pending') filter.status = { $in: ['Pending', 'pending'] };
      else if (statusRaw === 'disabled' || statusRaw === 'inactive') {
        filter.status = { $in: ['Inactive', 'inactive', 'disabled'] };
      }
    }

    // Parallel count and data queries
    const [items, totalCount] = await Promise.all([
      Service.find(filter)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .lean() // Plain objects (faster)
        .select('-images -media'), // Exclude huge fields
      Object.keys(filter).length === 0 ? Service.estimatedDocumentCount() : Service.countDocuments(filter)
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

// Get single service by ID
exports.getServiceById = async (req, res) => {
  try {
    const item = await Service.findById(req.params.id);
    if (!item) return res.status(404).json({ message: "Item not found" });
    res.json(item);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Create new service
exports.createService = async (req, res) => {
  try {
    const item = new Service(req.body);
    const saved = await item.save();
    res.status(201).json(saved);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

// Update service
exports.updateService = async (req, res) => {
  try {
    const updated = await Service.findByIdAndUpdate(
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

// Delete service
exports.deleteService = async (req, res) => {
  try {
    const deleted = await Service.findByIdAndDelete(req.params.id);
    if (!deleted) return res.status(404).json({ message: "Item not found" });
    res.json({ message: "Deleted successfully" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
