const express = require('express');
const router = express.Router();
const Job = require('./models/jobModel');
const { notifyListingActivated } = require('../userModule/user/services/notificationService');

const adminCheck = (req, res, next) => {
  if (!req.user || req.user.role !== 'admin') return res.status(403).json({ message: 'Admin access required' });
  next();
};

// GET ALL
router.get('/', adminCheck, async (req, res) => {
  try {
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

    const [data, totalCount] = await Promise.all([
      Job.find(filter)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .lean()
        .select('_id title companyName company companyLogo jobType location contact salary requirements benefits applyUrl status createdAt'),
      Object.keys(filter).length === 0 ? Job.estimatedDocumentCount() : Job.countDocuments(filter)
    ]);

    res.json({
      data,
      count: data.length,
      totalCount,
      page,
      limit,
      totalPages: Math.ceil(totalCount / limit)
    });
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
    req.body.status = 'pending';

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
    const doc = await Job.findByIdAndUpdate(req.params.id, req.body, { new: true, runValidators: true });
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

    const before = await Job.findById(req.params.id).lean();
    if (!before) return res.status(404).json({ message: 'Not found' });

    const doc = await Job.findByIdAndUpdate(req.params.id, { status: normalised }, { new: true });
    if (!doc) return res.status(404).json({ message: 'Not found' });

    const wasActive = String(before.status || '').toLowerCase() === 'active';
    const isActive = normalised === 'active';
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
