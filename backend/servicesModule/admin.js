const express = require('express');
const router = express.Router();
const Service = require('./Service');
const { notifyListingActivated } = require('../userModule/user/services/notificationService');

const adminCheck = (req, res, next) => {
  if (!req.user || req.user.role !== 'admin') return res.status(403).json({ message: 'Admin access required' });
  next();
};

// GET ALL
router.get('/', adminCheck, async (req, res) => {
  try {
    const { status } = req.query;
    const filter = status ? { status } : {};
    const data = await Service.find(filter).sort({ createdAt: -1 }).lean();
    res.json({ data, count: data.length });
  } catch (e) { res.status(500).json({ message: e.message }); }
});

// GET ONE
router.get('/:id', adminCheck, async (req, res) => {
  try {
    const doc = await Service.findById(req.params.id);
    if (!doc) return res.status(404).json({ message: 'Not found' });
    res.json(doc);
  } catch (e) { res.status(500).json({ message: e.message }); }
});

// CREATE
router.post('/', adminCheck, async (req, res) => {
  try {
    const { serviceName, providerName, city, contactPhone } = req.body;
    if (!serviceName || !providerName || !city || !contactPhone) return res.status(400).json({ message: 'Service Name, Provider, City and Contact Phone are required' });

    // New listings must be reviewed before going live.
    req.body.status = 'pending';

    const rawAmenities = req.body.amenities ?? req.body.amenitiesText ?? '';
    const amenities = Array.isArray(rawAmenities)
      ? rawAmenities
          .map((s) => (s ?? '').toString().trim())
          .filter(Boolean)
      : rawAmenities
          .toString()
          .split(/[,;\n]/)
          .map((s) => s.trim())
          .filter(Boolean);

    if (amenities.length === 0) {
      return res.status(400).json({ message: 'Services Offered is required' });
    }

    // Ensure canonical field is stored.
    req.body.amenities = amenities;

    const doc = new Service(req.body);
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
    // If amenities/services-offered is being updated, enforce non-empty.
    const hasAmenitiesUpdate = Object.prototype.hasOwnProperty.call(req.body, 'amenities') ||
      Object.prototype.hasOwnProperty.call(req.body, 'amenitiesText');

    if (hasAmenitiesUpdate) {
      const rawAmenities = req.body.amenities ?? req.body.amenitiesText ?? '';
      const amenities = Array.isArray(rawAmenities)
        ? rawAmenities
            .map((s) => (s ?? '').toString().trim())
            .filter(Boolean)
        : rawAmenities
            .toString()
            .split(/[,;\n]/)
            .map((s) => s.trim())
            .filter(Boolean);

      if (amenities.length === 0) {
        return res.status(400).json({ message: 'Services Offered is required' });
      }

      req.body.amenities = amenities;
      delete req.body.amenitiesText;
    }

    const doc = await Service.findByIdAndUpdate(req.params.id, req.body, { new: true, runValidators: true });
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

    const before = await Service.findById(req.params.id).lean();
    if (!before) return res.status(404).json({ message: 'Not found' });

    const doc = await Service.findByIdAndUpdate(req.params.id, { status: normalised }, { new: true });
    if (!doc) return res.status(404).json({ message: 'Not found' });

    const wasActive = String(before.status || '').toLowerCase() === 'active';
    const isActive = normalised === 'active';
    if (!wasActive && isActive) {
      // Best-effort — don't block the approval if notification insert fails.
      notifyListingActivated({
        module: 'services',
        entityId: doc._id,
        listingTitle: doc.title || doc.serviceName,
      }).catch(() => {});
    }

    res.json(doc);
  } catch (e) { res.status(500).json({ message: e.message }); }
});

// DELETE
router.delete('/:id', adminCheck, async (req, res) => {
  try {
    const doc = await Service.findByIdAndDelete(req.params.id);
    if (!doc) return res.status(404).json({ message: 'Not found' });
    res.json({ message: 'Deleted' });
  } catch (e) { res.status(500).json({ message: e.message }); }
});

module.exports = router;
