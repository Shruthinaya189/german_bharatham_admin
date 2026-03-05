const FoodGrocery = require("../model/FoodGrocery");

// Get all food/grocery items - most recent first
exports.getAllFoodGrocery = async (req, res) => {
  try {
    const items = await FoodGrocery.find().sort({ createdAt: -1 });
    console.log(`📊 Found ${items.length} food/grocery items`);
    // Return in format expected by Dashboard: {data, count}
    res.json({ data: items, count: items.length });
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
