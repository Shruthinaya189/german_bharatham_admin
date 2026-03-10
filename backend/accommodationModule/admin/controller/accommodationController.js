const Accommodation = require("../../accomodation");
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

// Get all accommodations
exports.getAllAccommodations = async (req, res) => {
  try {
    const items = await Accommodation.find().sort({ createdAt: -1 });
    res.json({ data: items, count: items.length });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Get single accommodation by ID
exports.getAccommodationById = async (req, res) => {
  try {
    const item = await Accommodation.findById(req.params.id);
    if (!item) return res.status(404).json({ message: "Item not found" });
    res.json(item);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Create new accommodation
exports.createAccommodation = async (req, res) => {
  try {
    const body = { ...req.body };

    // Auto-geocode from city or address
    const locationQuery = body.city || body.address;
    if (locationQuery) {
      const coords = await geocode(locationQuery);
      if (coords.latitude) {
        body.latitude  = coords.latitude;
        body.longitude = coords.longitude;
      }
    }

    const item = new Accommodation(body);
    const saved = await item.save();
    res.status(201).json(saved);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

// Update accommodation
exports.updateAccommodation = async (req, res) => {
  try {
    const body = { ...req.body };

    // Re-geocode if city/address changed
    const locationQuery = body.city || body.address;
    if (locationQuery) {
      const coords = await geocode(locationQuery);
      if (coords.latitude) {
        body.latitude  = coords.latitude;
        body.longitude = coords.longitude;
      }
    }

    const updated = await Accommodation.findByIdAndUpdate(
      req.params.id,
      body,
      { new: true }
    );
    if (!updated) return res.status(404).json({ message: "Item not found" });
    res.json(updated);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

// Delete accommodation
exports.deleteAccommodation = async (req, res) => {
  try {
    const deleted = await Accommodation.findByIdAndDelete(req.params.id);
    if (!deleted) return res.status(404).json({ message: "Item not found" });
    res.json({ message: "Deleted successfully" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
