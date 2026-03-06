const Job = require("../models/jobModel");
const fs = require("fs");
const path = require("path");

// UPLOAD COMPANY LOGO
exports.uploadLogo = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: "No file uploaded" });
    }
    
    // Return the file path that will be accessible via the server
    const logoUrl = `/uploads/company-logos/${req.file.filename}`;
    res.status(200).json({ logoUrl });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// CREATE JOB (Admin)
exports.createJob = async (req, res) => {
  try {
    console.log('=== CREATE JOB DEBUG ===');
    console.log('req.body:', req.body);
    console.log('req.file:', req.file);
    console.log('Content-Type:', req.headers['content-type']);
    
    // Handle file upload if present
    if (req.file) {
      req.body.companyLogo = `/uploads/company-logos/${req.file.filename}`;
    }
    
    // Validate required fields
    if (!req.body.title || req.body.title.trim() === '') {
      return res.status(400).json({ message: 'Title is required and cannot be empty' });
    }
    
    const job = new Job(req.body);
    const savedJob = await job.save();
    console.log('Job created successfully:', savedJob._id);
    res.status(201).json(savedJob);
  } catch (error) {
    console.error('Error creating job:', error);
    res.status(500).json({ message: error.message });
  }
};

// GET ALL JOBS (Admin)
exports.getAllJobs = async (req, res) => {
  try {
    const jobs = await Job.find().sort({ createdAt: -1 });
    res.json(jobs);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// UPDATE JOB
exports.updateJob = async (req, res) => {
  try {
    // Handle file upload if present  
    if (req.file) {
      req.body.companyLogo = `/uploads/company-logos/${req.file.filename}`;
      
      // Delete old logo if exists
      const oldJob = await Job.findById(req.params.id);
      if (oldJob && oldJob.companyLogo && oldJob.companyLogo.startsWith('/uploads/')) {
        const oldPath = path.join(__dirname, '../../', oldJob.companyLogo);
        if (fs.existsSync(oldPath)) {
          fs.unlinkSync(oldPath);
        }
      }
    }
    
    const updatedJob = await Job.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true }
    );
    res.json(updatedJob);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// DELETE JOB
exports.deleteJob = async (req, res) => {
  try {
    const job = await Job.findById(req.params.id);
    
    // Delete associated logo file if exists
    if (job && job.companyLogo && job.companyLogo.startsWith('/uploads/')) {
      const logoPath = path.join(__dirname, '../../', job.companyLogo);
      if (fs.existsSync(logoPath)) {
        fs.unlinkSync(logoPath);
      }
    }
    
    await Job.findByIdAndDelete(req.params.id);
    res.json({ message: "Job deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};