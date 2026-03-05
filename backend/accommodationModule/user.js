const express = require("express");
const router = express.Router();
const Accommodation = require("./accomodation");

// GET ALL
router.get("/", async (req, res) => {
  try {
    const data = await Accommodation.find({
      title: { $exists: true, $nin: [null, ""] },
      city: { $exists: true, $nin: [null, ""] }
    }).sort({ createdAt: -1 });
    res.status(200).json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// GET SINGLE
router.get("/:id", async (req, res) => {
  try {
    const data = await Accommodation.findById(req.params.id);
    if (!data)
      return res.status(404).json({ message: "Accommodation not found" });
    res.status(200).json(data);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// POST REVIEW  — body: { userId, score (1-5) }
router.post("/review/:id", async (req, res) => {
  try {
    const { userId, score } = req.body;
    const parsed = parseInt(score, 10);
    if (!parsed || parsed < 1 || parsed > 5) {
      return res.status(400).json({ message: "Score must be 1–5" });
    }

    const acc = await Accommodation.findById(req.params.id);
    if (!acc) return res.status(404).json({ message: "Not found" });

    // Prevent duplicate review from same user
    const existing = acc.reviews.findIndex((r) => r.userId === userId);
    if (existing >= 0) {
      acc.reviews[existing].score = parsed;
    } else {
      acc.reviews.push({ userId: userId || "anonymous", score: parsed });
    }

    // Recalculate average
    const total = acc.reviews.reduce((s, r) => s + r.score, 0);
    acc.avgRating = Math.round((total / acc.reviews.length) * 10) / 10;

    await acc.save();
    res.status(200).json({ avgRating: acc.avgRating, totalReviews: acc.reviews.length });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;