const Accommodation = require("../../accommodationModule/accomodation");
const FoodGrocery = require("../../foodGroceryModule/admin/model/FoodGrocery");
const Job = require("../../jobsModule/admin/model/Job");
const Service = require("../../servicesModule/admin/model/Service");
const User = require("../user/models/User");

// Get dashboard statistics
exports.getDashboardStats = async (req, res) => {
  try {
    // Count total listings from all categories
    const [accommodationCount, foodCount, jobCount, serviceCount, userCount] = await Promise.all([
      Accommodation.countDocuments(),
      FoodGrocery.countDocuments(),
      Job.countDocuments(),
      Service.countDocuments(),
      User.countDocuments({ role: "user" })
    ]);

    const totalListings = accommodationCount + foodCount + jobCount + serviceCount;
    const totalCategories = 4; // Accommodation, Food, Services, Jobs

    // Get pending reviews count (items with status 'Pending')
    const pendingReviews = await Promise.all([
      Accommodation.countDocuments({ status: 'Pending' }),
      FoodGrocery.countDocuments({ status: 'Pending' }),
      Job.countDocuments({ status: 'Pending' }),
      Service.countDocuments({ status: 'Pending' })
    ]);
    const totalPending = pendingReviews.reduce((sum, count) => sum + count, 0);

    // Get recent listings (last 6 from all categories)
    const [recentAccommodations, recentFood, recentJobs, recentServices] = await Promise.all([
      Accommodation.find().sort({ createdAt: -1 }).limit(2).lean(),
      FoodGrocery.find().sort({ createdAt: -1 }).limit(2).lean(),
      Job.find().sort({ createdAt: -1 }).limit(2).lean(),
      Service.find().sort({ createdAt: -1 }).limit(2).lean()
    ]);

    // Format recent listings
    const recentListings = [
      ...recentAccommodations.map(item => ({
        title: item.title,
        category: 'Accommodation',
        status: item.status || 'Active',
        added: formatTimeAgo(item.createdAt)
      })),
      ...recentFood.map(item => ({
        title: item.title,
        category: 'Food',
        status: item.status || 'Active',
        added: formatTimeAgo(item.createdAt)
      })),
      ...recentJobs.map(item => ({
        title: item.title,
        category: 'Job',
        status: item.status || 'Active',
        added: formatTimeAgo(item.createdAt)
      })),
      ...recentServices.map(item => ({
        title: item.title,
        category: 'Services',
        status: item.status || 'Active',
        added: formatTimeAgo(item.createdAt)
      }))
    ];

    // Sort by creation date and take top 6
    recentListings.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    const topRecentListings = recentListings.slice(0, 6);

    res.json({
      stats: {
        totalListings,
        totalCategories,
        totalUsers: userCount,
        pendingReviews: totalPending
      },
      categoryStats: [
        { name: 'Accommodation', count: accommodationCount, icon: '🏠' },
        { name: 'Food', count: foodCount, icon: '🍴' },
        { name: 'Services', count: serviceCount, icon: '🔧' },
        { name: 'Jobs', count: jobCount, icon: '💼' }
      ],
      recentListings: topRecentListings
    });
  } catch (err) {
    console.error('Dashboard stats error:', err);
    res.status(500).json({ message: err.message });
  }
};

// Get all listings from all categories (unified view)
exports.getAllListings = async (req, res) => {
  try {
    console.log('getAllListings called with query:', req.query);
    const { category, status, search, sort = 'newest' } = req.query;

    // Fetch from all collections
    let [accommodations, foods, jobs, services] = await Promise.all([
      Accommodation.find().lean(),
      FoodGrocery.find().lean(),
      Job.find().lean(),
      Service.find().lean()
    ]);

    console.log('Data fetched from DB:');
    console.log('- Accommodations:', accommodations.length);
    console.log('- Foods:', foods.length);
    console.log('- Jobs:', jobs.length);
    console.log('- Services:', services.length);

    // Format all listings with consistent structure
    const allListings = [
      ...accommodations.map(item => ({
        _id: item._id,
        title: item.title,
        category: 'Accommodation',
        location: item.location || `${item.city}, ${item.address}`,
        status: item.status || 'Active',
        created: item.createdAt,
        sourceCollection: 'accommodations'
      })),
      ...foods.map(item => ({
        _id: item._id,
        title: item.title,
        category: 'Food',
        location: item.location || `${item.city}, ${item.address}`,
        status: item.status || 'Active',
        created: item.createdAt,
        sourceCollection: 'foodgrocery'
      })),
      ...jobs.map(item => ({
        _id: item._id,
        title: item.title,
        category: 'Job',
        location: item.location || `${item.city}`,
        status: item.status || 'Active',
        created: item.createdAt,
        sourceCollection: 'jobs'
      })),
      ...services.map(item => ({
        _id: item._id,
        title: item.title,
        category: 'Services',
        location: item.location || `${item.city}, ${item.address || ''}`,
        status: item.status || 'Active',
        created: item.createdAt,
        sourceCollection: 'services'
      }))
    ];

    console.log('Total listings combined:', allListings.length);
    console.log('Sample items by category:');
    console.log('- Food items:', allListings.filter(i => i.category === 'Food').length);
    console.log('- Accommodation items:', allListings.filter(i => i.category === 'Accommodation').length);

    // Filter by category if specified
    let filtered = allListings;
    if (category && category !== 'All Listings') {
      console.log('Filtering by category:', category);
      filtered = filtered.filter(item => item.category.toLowerCase() === category.toLowerCase());
    }

    // Filter by status if specified
    if (status && status !== 'All Listings') {
      filtered = filtered.filter(item => item.status.toLowerCase() === status.toLowerCase());
    }

    // Search filter
    if (search) {
      const searchLower = search.toLowerCase();
      filtered = filtered.filter(item => 
        item.title.toLowerCase().includes(searchLower) ||
        item.location?.toLowerCase().includes(searchLower)
      );
    }

    // Sort
    if (sort === 'newest') {
      filtered.sort((a, b) => new Date(b.created) - new Date(a.created));
    } else if (sort === 'oldest') {
      filtered.sort((a, b) => new Date(a.created) - new Date(b.created));
    } else if (sort === 'a-z') {
      filtered.sort((a, b) => a.title.localeCompare(b.title));
    }

    console.log('Returning', filtered.length, 'listings after filters');
    console.log('Sample listing:', filtered[0]);
    res.json(filtered);
  } catch (err) {
    console.error('Get all listings error:', err);
    res.status(500).json({ message: err.message });
  }
};

// Get category details with listing counts
exports.getCategoryStats = async (req, res) => {
  try {
    const [accommodationCount, foodCount, serviceCount, jobCount] = await Promise.all([
      Accommodation.countDocuments(),
      FoodGrocery.countDocuments(),
      Service.countDocuments(),
      Job.countDocuments()
    ]);

    const categories = [
      {
        name: 'Accommodation',
        listings: `${accommodationCount} listings`,
        description: 'Housing, apartments, student housing, and shared accommodations',
        status: 'Active',
        icon: '🏠',
        count: accommodationCount
      },
      {
        name: 'Food',
        listings: `${foodCount} listings`,
        description: 'Indian grocery stores, restaurants, and food delivery services',
        status: 'Active',
        icon: '🍴',
        count: foodCount
      },
      {
        name: 'Services',
        listings: `${serviceCount} listings`,
        description: 'Immigration, legal, financial, and consultation services',
        status: 'Active',
        icon: '🔧',
        count: serviceCount
      },
      {
        name: 'Jobs',
        listings: `${jobCount} listings`,
        description: 'Job listings, career opportunities, and employment services',
        status: 'Active',
        icon: '💼',
        count: jobCount
      }
    ];

    res.json(categories);
  } catch (err) {
    console.error('Get category stats error:', err);
    res.status(500).json({ message: err.message });
  }
};

// Helper function to format time ago
function formatTimeAgo(date) {
  const seconds = Math.floor((new Date() - new Date(date)) / 1000);
  
  const intervals = {
    year: 31536000,
    month: 2592000,
    week: 604800,
    day: 86400,
    hour: 3600,
    minute: 60
  };

  for (const [unit, secondsInUnit] of Object.entries(intervals)) {
    const interval = Math.floor(seconds / secondsInUnit);
    if (interval >= 1) {
      return `${interval} ${unit}${interval > 1 ? 's' : ''} ago`;
    }
  }
  
  return 'just now';
}
