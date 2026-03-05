const express = require("express");
const router = express.Router();
const Accommodation = require("./accomodation");

// GET ALL (with stats)
router.get("/", async (req, res) => {
  try {
    if (req.user.role !== "admin") {
      return res.status(403).json({ message: "Admin access required" });
    }

    // Only fetch from MongoDB, no in-memory data
    const accommodations = await Accommodation.find()
      .select('-__v')
      .sort({ createdAt: -1 })
      .lean();
    
    const count = await Accommodation.countDocuments();
    const activeCount = await Accommodation.countDocuments({ 
      title: { $exists: true, $ne: null },
      city: { $exists: true, $ne: null }
    });

    res.status(200).json({
      data: accommodations || [],
      count: count || 0,
      activeCount: activeCount || 0
    });
  } catch (error) {
    console.error('GET all accommodations error:', error);
    res.status(500).json({ message: error.message });
  }
});

// GET ONE
router.get("/:id", async (req, res) => {
  try {
    if (req.user.role !== "admin") {
      return res.status(403).json({ message: "Admin access required" });
    }

    const accommodation = await Accommodation.findById(req.params.id);
    if (!accommodation) {
      return res.status(404).json({ message: "Not found" });
    }

    res.status(200).json(accommodation);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// CREATE
router.post("/", async (req, res) => {
  try {
    if (req.user.role !== "admin") {
      return res.status(403).json({ message: "Admin access required" });
    }

    const title = (req.body.title || '').trim();
    const city = (req.body.city || '').trim();
    const contactPhone = (req.body.contactPhone || '').trim();

    if (!title || !city) {
      return res.status(400).json({ message: 'Title and City are required' });
    }
    if (!contactPhone) {
      return res.status(400).json({ message: 'Contact Phone is required so users can call or WhatsApp the owner' });
    }

    // Prepare payload with proper type conversions
    const payload = {
      title,
      city,
      description: req.body.description ? String(req.body.description).trim() : null,
      propertyType: req.body.propertyType ? String(req.body.propertyType).trim() : null,
      postalCode: req.body.postalCode ? String(req.body.postalCode).trim() : null,
      address: req.body.address ? String(req.body.address).trim() : null,
      latitude: req.body.latitude ? parseFloat(req.body.latitude) : null,
      longitude: req.body.longitude ? parseFloat(req.body.longitude) : null,
      
      rentDetails: req.body.rentDetails ? {
        coldRent: req.body.rentDetails.coldRent ? parseFloat(req.body.rentDetails.coldRent) : null,
        warmRent: req.body.rentDetails.warmRent ? parseFloat(req.body.rentDetails.warmRent) : null,
        additionalCosts: req.body.rentDetails.additionalCosts ? parseFloat(req.body.rentDetails.additionalCosts) : null,
        deposit: req.body.rentDetails.deposit ? parseFloat(req.body.rentDetails.deposit) : null,
        electricityIncluded: Boolean(req.body.rentDetails.electricityIncluded),
        heatingIncluded: Boolean(req.body.rentDetails.heatingIncluded),
        internetIncluded: Boolean(req.body.rentDetails.internetIncluded)
      } : {},
      
      propertyDetails: req.body.propertyDetails ? {
        sizeSqm: req.body.propertyDetails.sizeSqm ? parseFloat(req.body.propertyDetails.sizeSqm) : null,
        bedrooms: req.body.propertyDetails.bedrooms ? parseInt(req.body.propertyDetails.bedrooms, 10) : null,
        bathrooms: req.body.propertyDetails.bathrooms ? parseInt(req.body.propertyDetails.bathrooms, 10) : null,
        totalFloors: req.body.propertyDetails.totalFloors ? parseInt(req.body.propertyDetails.totalFloors, 10) : null
      } : {},
      
      amenities: req.body.amenities ? {
        balcony: Boolean(req.body.amenities.balcony),
        terrace: Boolean(req.body.amenities.terrace),
        garden: Boolean(req.body.amenities.garden),
        lift: Boolean(req.body.amenities.lift),
        parking: Boolean(req.body.amenities.parking),
        garage: Boolean(req.body.amenities.garage),
        cellar: Boolean(req.body.amenities.cellar),
        washingMachine: Boolean(req.body.amenities.washingMachine),
        dishwasher: Boolean(req.body.amenities.dishwasher),
        kitchen: Boolean(req.body.amenities.kitchen),
        petsAllowed: Boolean(req.body.amenities.petsAllowed),
        smokingAllowed: Boolean(req.body.amenities.smokingAllowed),
        anmeldungPossible: Boolean(req.body.amenities.anmeldungPossible),
        studentFriendly: Boolean(req.body.amenities.studentFriendly),
        wheelchairAccessible: Boolean(req.body.amenities.wheelchairAccessible)
      } : {},
      
      locationHighlights: req.body.locationHighlights ? {
        nearUniversity: Boolean(req.body.locationHighlights.nearUniversity),
        nearSupermarket: Boolean(req.body.locationHighlights.nearSupermarket),
        nearHospital: Boolean(req.body.locationHighlights.nearHospital),
        nearPublicTransport: Boolean(req.body.locationHighlights.nearPublicTransport),
        ubahnDistanceMeters: req.body.locationHighlights.ubahnDistanceMeters ? parseInt(req.body.locationHighlights.ubahnDistanceMeters, 10) : null,
        sbahnDistanceMeters: req.body.locationHighlights.sbahnDistanceMeters ? parseInt(req.body.locationHighlights.sbahnDistanceMeters, 10) : null,
        busDistanceMeters: req.body.locationHighlights.busDistanceMeters ? parseInt(req.body.locationHighlights.busDistanceMeters, 10) : null
      } : {},
      
      media: req.body.media ? {
        images: Array.isArray(req.body.media.images) ? req.body.media.images : [],
        videoUrl: req.body.media.videoUrl ? String(req.body.media.videoUrl).trim() : null,
        floorPlan: req.body.media.floorPlan ? String(req.body.media.floorPlan).trim() : null
      } : {},
      
      adminControls: req.body.adminControls ? {
        viewsCount: req.body.adminControls.viewsCount ? parseInt(req.body.adminControls.viewsCount, 10) : 0,
        favouritesCount: req.body.adminControls.favouritesCount ? parseInt(req.body.adminControls.favouritesCount, 10) : 0
      } : {},

      contactPhone: req.body.contactPhone ? String(req.body.contactPhone).trim() : null,
      status: ['active', 'disabled', 'pending'].includes(req.body.status) ? req.body.status : 'active'
    };

    const newAccommodation = new Accommodation(payload);
    await newAccommodation.save();

    // Verify accommodation was saved to MongoDB
    const savedAccommodation = await Accommodation.findById(newAccommodation._id);
    if (!savedAccommodation) {
      console.error('Failed to verify saved accommodation:', newAccommodation._id);
      return res.status(500).json({ message: "Accommodation save verification failed" });
    }

    console.log('Accommodation created successfully:', savedAccommodation._id);
    res.status(201).json(savedAccommodation);
  } catch (error) {
    console.error('CREATE accommodation error:', error);
    if (error.name === "ValidationError") {
      return res.status(400).json({ message: error.message });
    }
    res.status(500).json({ message: error.message });
  }
});

// PATCH status
router.patch('/:id/status', async (req, res) => {
  try {
    if (req.user.role !== 'admin') return res.status(403).json({ message: 'Admin access required' });
    const { status } = req.body;
    const normalised = status === 'inactive' ? 'disabled' : status;
    if (!['active', 'disabled', 'pending'].includes(normalised)) return res.status(400).json({ message: 'Invalid status' });
    const isActive = normalised === 'active';
    const doc = await Accommodation.findByIdAndUpdate(
      req.params.id,
      { status: normalised, 'adminControls.isActive': isActive },
      { new: true }
    );
    if (!doc) return res.status(404).json({ message: 'Not found' });
    res.json(doc);
  } catch (e) { res.status(500).json({ message: e.message }); }
});

// UPDATE
router.put("/:id", async (req, res) => {
  try {
    if (req.user.role !== "admin") {
      return res.status(403).json({ message: "Admin access required" });
    }

    const updated = await Accommodation.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true }
    );

    if (!updated)
      return res.status(404).json({ message: "Not found" });

    res.status(200).json(updated);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// DELETE
router.delete("/:id", async (req, res) => {
  try {
    if (req.user.role !== "admin") {
      return res.status(403).json({ message: "Admin access required" });
    }

    const deleted = await Accommodation.findByIdAndDelete(req.params.id);

    if (!deleted)
      return res.status(404).json({ message: "Not found" });

    res.status(200).json({ message: "Deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;