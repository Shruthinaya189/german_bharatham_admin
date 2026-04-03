const express = require('express');
const router = express.Router();
const Job = require('./models/jobModel');
const { notifyListingActivated } = require('../userModule/user/services/notificationService');

const adminCheck = (req, res, next) => {
  if (!req.user || req.user.role !== 'admin') return res.status(403).json({ message: 'Admin access required' });
  next();
};

const normalizeStatus = (value, fallback = 'Pending') => {
  const raw = String(value || '').trim().toLowerCase();
  if (raw === 'active') return 'Active';
  if (raw === 'pending') return 'Pending';
  if (raw === 'inactive' || raw === 'disabled') return 'Inactive';
  return fallback;
};

// GET ALL (supports pagination: ?page=1&limit=20)
router.get('/', adminCheck, async (req, res) => {
  try {
    const { status } = req.query;
    const filter = status ? { status: normalizeStatus(status, String(status)) } : {};
    const page = Math.max(1, parseInt(req.query.page) || 1);
    const limit = Math.min(200, parseInt(req.query.limit) || 1);
    const skip = (page - 1) * limit;

    const totalCount = await Job.countDocuments(filter);
    const data = await Job.find(filter).sort({ createdAt: -1 }).skip(skip).limit(limit).lean();

    res.json({ data, count: (data || []).length, totalCount: totalCount || 0, page, limit });
  } catch (e) { res.status(500).json({ message: e.message }); }
});

// GET ONE
router.get('/:id', adminCheck, async (req, res) => {
  try {
    const doc = await Job.findById(req.params.id);
    if (!doc) return res.status(404).json({ message: 'Not found' });
    res.json(doc);
  } catch (e) { res.status(500).json({ message: e.message }); }
});

// CREATE
router.post('/', adminCheck, async (req, res) => {
  try {
    const { title } = req.body;
    if (!title || !title.trim()) return res.status(400).json({ message: 'Job Title is required' });

    // New listings must be reviewed before going live.
    req.body.status = 'Pending';

    const doc = new Job(req.body);
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
    if (req.body && req.body.status != null) {
      req.body.status = normalizeStatus(req.body.status, req.body.status);
    }
    const doc = await Job.findByIdAndUpdate(req.params.id, req.body, { new: true, runValidators: true });
    if (!doc) return res.status(404).json({ message: 'Not found' });
    res.json(doc);
  } catch (e) { res.status(500).json({ message: e.message }); }
});

// PATCH status
router.patch('/:id/status', adminCheck, async (req, res) => {
  try {
    const { status } = req.body;
    const normalised = normalizeStatus(status, '');
    if (!['Active', 'Pending', 'Inactive'].includes(normalised)) return res.status(400).json({ message: 'Invalid status' });

    const before = await Job.findById(req.params.id).lean();
    if (!before) return res.status(404).json({ message: 'Not found' });

    const doc = await Job.findByIdAndUpdate(req.params.id, { status: normalised }, { new: true });
    if (!doc) return res.status(404).json({ message: 'Not found' });

    const wasActive = String(before.status || '').toLowerCase() === 'active';
    const isActive = normalised === 'Active';
    if (!wasActive && isActive) {
      notifyListingActivated({
        module: 'jobs',
        entityId: doc._id,
        listingTitle: doc.title,
      }).catch(() => {});
    }

    res.json(doc);
  } catch (e) { res.status(500).json({ message: e.message }); }
});

// DELETE
router.delete('/:id', adminCheck, async (req, res) => {
  try {
    const doc = await Job.findByIdAndDelete(req.params.id);
    if (!doc) return res.status(404).json({ message: 'Not found' });
    res.json({ message: 'Deleted' });
  } catch (e) { res.status(500).json({ message: e.message }); }
});

module.exports = router;
