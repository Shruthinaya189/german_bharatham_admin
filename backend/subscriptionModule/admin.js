const express = require("express");
const router = express.Router();
const controller = require("./subscriptionController");

router.get("/", controller.listAllSubscriptions);

module.exports = router;