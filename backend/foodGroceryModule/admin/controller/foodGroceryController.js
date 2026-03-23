const FoodGrocery = require("../model/FoodGrocery");
const axios = require("axios");

// ── Geocode an address string → { latitude, longitude } using Nominatim ──────
async function geocode(address) {
  try {
    const url = `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(address)}&limit=1`;
    const { data } = await axios.get(url, {
      headers: { "User-Agent": "GermanBharathamApp/1.0" },
      timeout: 8000,
    });
    if (data && data.length > 0) {
      return {
        latitude:  parseFloat(data[0].lat),
        longitude: parseFloat(data[0].lon),
      };
    }
  } catch (_) {
    // Geocoding failure must not block the save
  }
  return {};
}

// Get all food/grocery items - paginated
exports.getAllFoodGrocery = async (req, res) => {
  try {
    const page = Math.max(1, parseInt(req.query.page) || 1);
    const limit = Math.min(100, Math.max(1, parseInt(req.query.limit) || 20));
    const skip = (page - 1) * limit;

    const query = {};
    // optional status filter
    if (req.query.status) query.status = req.query.status;

    const [total, items] = await Promise.all([
      FoodGrocery.countDocuments(query),
      FoodGrocery.find(query).sort({ createdAt: -1 }).skip(skip).limit(limit)
    ]);

    const totalPages = Math.ceil(total / limit);
    res.json({ data: items, count: total, page, limit, totalPages });
  } catch (err) {
    console.error('Error fetching food items:', err);
    res.status(500).json({ message: err.message });
  }
};

// Get single food/grocery item by ID
exports.getFoodGroceryById = async (req, res) => {
  try {
    const item = await FoodGrocery.findById(req.params.id);
    if (!item) return res.status(404).json({ message: "Item not found" });
    res.json(item);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Create new food/grocery item
exports.createFoodGrocery = async (req, res) => {
  try {
    // Ensure proper data structure
    const itemData = {
      ...req.body,
      category: "Food", // Always set category to Food
      location: req.body.location || `${req.body.city}, ${req.body.address}`, // Ensure location field exists
      status: req.body.status || "Pending" // Default to Pending
    };

    // Auto-geocode from city or address
    const locationQuery = itemData.city || itemData.address;
    if (locationQuery) {
      const coords = await geocode(locationQuery);
      if (coords.latitude) {
        itemData.latitude  = coords.latitude;
        itemData.longitude = coords.longitude;
      }
    }
    
    const item = new FoodGrocery(itemData);
    const saved = await item.save();
    res.status(201).json(saved);
  } catch (err) {
    console.error('Error creating food/grocery item:', err);
    res.status(400).json({ message: err.message });
  }
};

// Update food/grocery item
exports.updateFoodGrocery = async (req, res) => {
  try {
    // Ensure location is updated if address or city changes
    const updateData = {
      ...req.body,
      category: "Food" // Maintain category
    };
    
    if (req.body.city || req.body.address) {
      updateData.location = `${req.body.city || ''}, ${req.body.address || ''}`.trim();
    }

    // Re-geocode if city/address changed
    const locationQuery = req.body.city || req.body.address;
    if (locationQuery) {
      const coords = await geocode(locationQuery);
      if (coords.latitude) {
        updateData.latitude  = coords.latitude;
        updateData.longitude = coords.longitude;
      }
    }
    
    const updated = await FoodGrocery.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true }
    );
    if (!updated) return res.status(404).json({ message: "Item not found" });
    res.json(updated);
  } catch (err) {
    console.error('Error updating food/grocery item:', err);
    res.status(400).json({ message: err.message });
  }
};

// Delete food/grocery item
exports.deleteFoodGrocery = async (req, res) => {
  try {
    const deleted = await FoodGrocery.findByIdAndDelete(req.params.id);
    if (!deleted) return res.status(404).json({ message: "Item not found" });
    res.json({ message: "Deleted successfully" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Update status only
exports.updateStatus = async (req, res) => {
  try {
    const { status } = req.body;
    if (!status) {
      return res.status(400).json({ message: "Status is required" });
    }
    
    const updated = await FoodGrocery.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true }
    );
    
    if (!updated) {
      return res.status(404).json({ message: "Item not found" });
    }
    
    res.json(updated);
  } catch (err) {
    console.error('Error updating status:', err);
    res.status(500).json({ message: err.message });
  }
};