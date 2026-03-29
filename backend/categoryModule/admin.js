const express = require('express');
const router  = express.Router();
const Category       = require('./Category');
const GenericListing = require('./GenericListing');

const adminCheck = (req, res, next) => {
  if (req.user?.role !== 'admin') return res.status(403).json({ message: 'Admin access required' });
  next();
};

// ── CATEGORIES ──────────────────────────────────────────────────────────────

// GET all custom categories
router.get('/', adminCheck, async (req, res) => {
  try {
    const cats = await Category.find().sort({ createdAt: -1 });
    res.json(cats);
  } catch (e) { res.status(500).json({ message: e.message }); }
});

// POST create a new category
router.post('/', adminCheck, async (req, res) => {
  try {
    const { name, description, icon, status } = req.body;
    if (!name?.trim()) return res.status(400).json({ message: 'Category name is required' });
    const cat = await Category.create({ name: name.trim(), description: description || '', icon: icon || '📋', status: status || 'active' });
    res.status(201).json(cat);
  } catch (e) { res.status(500).json({ message: e.message }); }
});

// PUT update a category
router.put('/:id', adminCheck, async (req, res) => {
  try {
    const cat = await Category.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!cat) return res.status(404).json({ message: 'Category not found' });
    res.json(cat);
  } catch (e) { res.status(500).json({ message: e.message }); }
});

// DELETE a category + all its listings
router.delete('/:id', adminCheck, async (req, res) => {
  try {
    const cat = await Category.findByIdAndDelete(req.params.id);
    if (!cat) return res.status(404).json({ message: 'Category not found' });
    await GenericListing.deleteMany({ categoryId: req.params.id });
    res.json({ message: 'Category and its listings deleted' });
  } catch (e) { res.status(500).json({ message: e.message }); }
});

// ── LISTINGS within a category ───────────────────────────────────────────────

// GET all listings for a category (supports pagination: ?page=1&limit=20)
router.get('/:id/listings', adminCheck, async (req, res) => {
  try {
    const filter = { categoryId: req.params.id };
    if (req.query.status) filter.status = req.query.status;
    const page = Math.max(1, parseInt(req.query.page) || 1);
    const limit = Math.min(200, parseInt(req.query.limit) || 1);
    const skip = (page - 1) * limit;

    const totalCount = await GenericListing.countDocuments(filter);
    const listings = await GenericListing.find(filter).sort({ createdAt: -1 }).skip(skip).limit(limit).lean();

    res.json({ data: listings, count: (listings || []).length, totalCount: totalCount || 0, page, limit });
  } catch (e) { res.status(500).json({ message: e.message }); }
});

// POST create listing in a category
router.post('/:id/listings', adminCheck, async (req, res) => {
  try {
    const cat = await Category.findById(req.params.id);
    if (!cat) return res.status(404).json({ message: 'Category not found' });
    const { title } = req.body;
    if (!title?.trim()) return res.status(400).json({ message: 'Title is required' });
    const listing = await GenericListing.create({
      ...req.body,
      title: title.trim(),
      categoryId:   req.params.id,
      categoryName: cat.name,
    });
    res.status(201).json(listing);
  } catch (e) { res.status(500).json({ message: e.message }); }
});

// PUT update a listing
router.put('/:id/listings/:lid', adminCheck, async (req, res) => {
  try {
    const listing = await GenericListing.findOneAndUpdate(
      { _id: req.params.lid, categoryId: req.params.id },
      req.body,
      { new: true }
    );
    if (!listing) return res.status(404).json({ message: 'Listing not found' });
    res.json(listing);
  } catch (e) { res.status(500).json({ message: e.message }); }
});

// PATCH status
router.patch('/:id/listings/:lid/status', adminCheck, async (req, res) => {
  try {
    let { status } = req.body;
    if (status === 'inactive') status = 'disabled';
    if (!['active', 'disabled', 'pending'].includes(status)) return res.status(400).json({ message: 'Invalid status' });
    const listing = await GenericListing.findOneAndUpdate(
      { _id: req.params.lid, categoryId: req.params.id },
      { status },
      { new: true }
    );
    if (!listing) return res.status(404).json({ message: 'Listing not found' });
    res.json(listing);
  } catch (e) { res.status(500).json({ message: e.message }); }
});

// DELETE a listing
router.delete('/:id/listings/:lid', adminCheck, async (req, res) => {
  try {
    const listing = await GenericListing.findOneAndDelete({ _id: req.params.lid, categoryId: req.params.id });
    if (!listing) return res.status(404).json({ message: 'Listing not found' });
    res.json({ message: 'Deleted' });
  } catch (e) { res.status(500).json({ message: e.message }); }
});

module.exports = router;
