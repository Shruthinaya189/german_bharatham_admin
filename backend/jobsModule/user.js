const express = require("express");
const router = express.Router();
const Job = require("./admin/model/Job");

// GET ALL ACTIVE JOBS (No auth required for users)
router.get("/", async (req, res) => {
  try {
    const { city, jobType, company } = req.query;
    const filter = { status: 'Active' };
    
    if (city) filter.city = { $regex: city, $options: 'i' };
    if (jobType) filter.jobType = { $regex: jobType, $options: 'i' };
    if (company) filter.company = { $regex: company, $options: 'i' };
    
    const data = await Job.find(filter).sort({ createdAt: -1 }).lean();
    res.json({ data, count: data.length });
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

// GET ONE JOB BY ID
router.get("/:id", async (req, res) => {
  try {
    const doc = await Job.findById(req.params.id);
    if (!doc) return res.status(404).json({ message: 'Job not found' });
    res.json(doc);
  } catch (e) {
    res.status(500).json({ message: e.message });
  }
});

module.exports = router;
