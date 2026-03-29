const express = require('express');
const router = express.Router();
const Food = require('./Food');
const { notifyListingActivated } = require('../userModule/user/services/notificationService');

const adminCheck = (req, res, next) => {
  if (!req.user || req.user.role !== 'admin') return res.status(403).json({ message: 'Admin access required' });
  next();
};

// GET ALL (supports pagination: ?page=1&limit=20)
router.get('/', adminCheck, async (req, res) => {
  try {
    const { status } = req.query;
    const filter = status ? { status } : {};
    const page = Math.max(1, parseInt(req.query.page) || 1);
    const limit = Math.min(200, parseInt(req.query.limit) || 1);
    const skip = (page - 1) * limit;

    const totalCount = await Food.countDocuments(filter);
    const data = await Food.find(filter).sort({ createdAt: -1 }).skip(skip).limit(limit).lean();

    res.json({ data, count: (data || []).length, totalCount: totalCount || 0, page, limit });
  } catch (e) { res.status(500).json({ message: e.message }); }
});

// GET ONE
router.get('/:id', adminCheck, async (req, res) => {
  try {
    const doc = await Food.findById(req.params.id);
    if (!doc) return res.status(404).json({ message: 'Not found' });
    res.json(doc);
  } catch (e) { res.status(500).json({ message: e.message }); }
});

// CREATE
router.post('/', adminCheck, async (req, res) => {
  try {
    const { name, city, contactPhone } = req.body;
    if (!name || !city || !contactPhone) return res.status(400).json({ message: 'Name, City and Contact Phone are required' });

    // New listings must be reviewed before going live.
    req.body.status = 'pending';

    const doc = new Food(req.body);
    await doc.save();
    res.status(201).json(doc);
  } catch (e) {
    if (e.name === 'ValidationError') return res.status(400).json({ message: e.message });
    res.status(500).json({ message: e.message });
  }
});

// UPDATE (full)
router.put('/:id', adminCheck, async (req, res) => {
  try {
    const doc = await Food.findByIdAndUpdate(req.params.id, req.body, { new: true, runValidators: true });
    if (!doc) return res.status(404).json({ message: 'Not found' });
    res.json(doc);
  } catch (e) { res.status(500).json({ message: e.message }); }
});

// PATCH status
router.patch('/:id/status', adminCheck, async (req, res) => {
  try {
    const { status } = req.body;
    const normalised = status === 'inactive' ? 'disabled' : status;
    if (!['active', 'disabled', 'pending'].includes(normalised)) return res.status(400).json({ message: 'Invalid status' });

    const before = await Food.findById(req.params.id).lean();
    if (!before) return res.status(404).json({ message: 'Not found' });

    const doc = await Food.findByIdAndUpdate(req.params.id, { status: normalised }, { new: true });
    if (!doc) return res.status(404).json({ message: 'Not found' });

    const wasActive = String(before.status || '').toLowerCase() === 'active';
    const isActive = normalised === 'active';
    if (!wasActive && isActive) {
      notifyListingActivated({
        module: 'foodgrocery',
        entityId: doc._id,
        listingTitle: doc.name || doc.restaurantName,
      }).catch(() => {});
    }

    res.json(doc);
  } catch (e) { res.status(500).json({ message: e.message }); }
});

// DELETE
router.delete('/:id', adminCheck, async (req, res) => {
  try {
    const doc = await Food.findByIdAndDelete(req.params.id);
    if (!doc) return res.status(404).json({ message: 'Not found' });
    res.json({ message: 'Deleted' });
  } catch (e) { res.status(500).json({ message: e.message }); }
});

module.exports = router;