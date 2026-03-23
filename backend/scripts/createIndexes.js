/**
 * Database Indexes Creation Script
 * Run this once to create indexes for optimal query performance
 * Usage: node scripts/createIndexes.js
 */

const mongoose = require('mongoose');
require('dotenv').config();

// Import all models that need indexes
const FoodGrocery = require('../foodGroceryModule/admin/model/FoodGrocery');
const Accommodation = require('../accommodationModule/accomodation');
const Job = require('../jobsModule/models/jobModel');
const Service = require('../servicesModule/admin/model/Service');
const User = require('../userModule/user/models/User');
const Guide = require('../communityModule/user/models/Guide');
const Category = require('../categoryModule/Category');

async function createIndexes() {
  try {
    console.log('🔧 Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/german_bharatham');
    console.log('✅ Connected to MongoDB');

    console.log('\n📑 Creating indexes for optimal performance...\n');

    // FoodGrocery indexes
    console.log('Creating FoodGrocery indexes...');
    await FoodGrocery.collection.createIndex({ createdAt: -1 });
    await FoodGrocery.collection.createIndex({ status: 1 });
    await FoodGrocery.collection.createIndex({ category: 1 });
    await FoodGrocery.collection.createIndex({ city: 1 });
    console.log('✅ FoodGrocery indexes created');

    // Accommodation indexes
    console.log('Creating Accommodation indexes...');
    await Accommodation.collection.createIndex({ createdAt: -1 });
    await Accommodation.collection.createIndex({ status: 1 });
    await Accommodation.collection.createIndex({ city: 1 });
    console.log('✅ Accommodation indexes created');

    // Job indexes
    console.log('Creating Job indexes...');
    await Job.collection.createIndex({ createdAt: -1 });
    await Job.collection.createIndex({ status: 1 });
    await Job.collection.createIndex({ category: 1 });
    console.log('✅ Job indexes created');

    // Service indexes
    console.log('Creating Service indexes...');
    await Service.collection.createIndex({ createdAt: -1 });
    await Service.collection.createIndex({ status: 1 });
    await Service.collection.createIndex({ city: 1 });
    console.log('✅ Service indexes created');

    // User indexes
    console.log('Creating User indexes...');
    await User.collection.createIndex({ role: 1 });
    await User.collection.createIndex({ createdAt: -1 });
    await User.collection.createIndex({ isActive: 1 });
    console.log('✅ User indexes created');

    // Guide indexes
    console.log('Creating Guide indexes...');
    await Guide.collection.createIndex({ createdAt: -1 });
    await Guide.collection.createIndex({ category: 1 });
    console.log('✅ Guide indexes created');

    // Category indexes
    console.log('Creating Category indexes...');
    await Category.collection.createIndex({ createdAt: -1 });
    await Category.collection.createIndex({ status: 1 });
    console.log('✅ Category indexes created');

    console.log('\n✨ All indexes created successfully!');
    console.log('Performance improvements:');
    console.log('  • Sorting queries (createdAt) will be much faster');
    console.log('  • Filtering queries (status, role) will be instant');
    console.log('  • City-based searches will be optimized');
    console.log('  • Pagination will work smoothly\n');

    process.exit(0);
  } catch (error) {
    console.error('❌ Error creating indexes:', error.message);
    process.exit(1);
  }
}

createIndexes();
