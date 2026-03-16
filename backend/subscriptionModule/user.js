const express = require("express");
const router = express.Router();
const controller = require("./subscriptionController");

router.get("/plans", controller.getPlans);
router.get("/status", controller.getMySubscription);
router.get("/payment-history", controller.getPaymentHistory);
router.post("/checkout-session", controller.createCheckoutSession);

module.exports = router;