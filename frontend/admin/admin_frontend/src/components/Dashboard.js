import React, { useState, useEffect } from 'react';
import { Plus, TrendingUp, FolderOpen, Users, Clock } from 'lucide-react';
import axios from 'axios';
import AddListingModal from './AddListingModal';

const Dashboard = () => {
  const [showAddModal, setShowAddModal] = useState(false);
  const [jobCount, setJobCount] = useState(3);
  const [recentJobs, setRecentJobs] = useState([]);
  const [pendingJobsCount, setPendingJobsCount] = useState(0);
  const [totalListingsCount, setTotalListingsCount] = useState(1284);

  // Fetch jobs and update counts
  useEffect(() => {
    fetchJobs();
  }, []);

  // Set up auto-refresh interval
  useEffect(() => {
    const interval = setInterval(fetchJobs, 5000); // Refresh every 5 seconds
    return () => clearInterval(interval);
  }, []);

  const fetchJobs = async () => {
    try {
      const response = await axios.get("http://localhost:5000/api/jobs");
      const jobs = response.data;
      setJobCount(jobs.length);
      
      // Count pending jobs
      const pendingJobs = jobs.filter(job => job.status && job.status.toLowerCase() === 'pending');
      setPendingJobsCount(pendingJobs.length);
      
      // Calculate total listings (static categories + dynamic jobs)
      const staticListingsCount = 29 + 14 + 7; // Accommodation + Food + Services
      setTotalListingsCount(staticListingsCount + jobs.length);
      
      // Get recent 6 jobs, converted to listing format
      const recentJobsList = jobs.slice(0, 6).map((job) => ({
        title: job.title,
        category: 'Job',
        status: job.status || 'Active',
        added: job.createdAt ? getTimeAgo(new Date(job.createdAt)) : 'Recently'
      }));
      setRecentJobs(recentJobsList);
    } catch (error) {
      console.error("Error fetching jobs:", error);
    }
  };

  // Helper function to calculate time ago
  const getTimeAgo = (date) => {
    const seconds = Math.floor((new Date() - date) / 1000);
    let interval = seconds / 31536000;
    if (interval > 1) return Math.floor(interval) + ' year ago';
    interval = seconds / 2592000;
    if (interval > 1) return Math.floor(interval) + ' month ago';
    interval = seconds / 86400;
    if (interval > 1) return Math.floor(interval) + ' day ago';
    interval = seconds / 3600;
    if (interval > 1) return Math.floor(interval) + ' hour ago';
    interval = seconds / 60;
    if (interval > 1) return Math.floor(interval) + ' minute ago';
    return Math.floor(seconds) + ' second ago';
  };

  const stats = [
    { label: 'Total Listings', value: totalListingsCount.toLocaleString(), change: '+12% from last month', icon: TrendingUp },
    { label: 'Categories', value: '4', change: '', icon: FolderOpen },
    { label: 'Total Users', value: '1,284', change: '+6% from last month', icon: Users },
    { label: 'Pending Reviews', value: pendingJobsCount.toString(), change: '', icon: Clock },
  ];

  const recentListings = [
    { title: 'Cozy Studio Apartment', category: 'Accommodation', status: 'Pending', added: '2 hour ago' },
    { title: 'Italian Restaurant Opening', category: 'Food', status: 'Active', added: '12 hour ago' },
    ...recentJobs,
  ];

  const recentActivity_static = [
    { action: 'New listing added', detail: 'Luxury Villa', time: '1 hour ago' },
    { action: 'Category updated', detail: 'Accommodation', time: '2 hour ago' },
    { action: 'User registered', detail: 'finn@example.com', time: '2 hour ago' },
    { action: 'Listing approved', detail: 'Tech Startup', time: '1 day ago' },
    { action: 'User Registered', detail: 'gill@gmail.com', time: '2 day ago' },
    { action: 'Listing approved', detail: 'Tech Startup', time: '1 day ago' },
  ];

  const categoryStats = [
    { name: 'Accommodation', count: 29, icon: '🏠' },
    { name: 'Food', count: 14, icon: '🍴' },
    { name: 'Services', count: 7, icon: '🔧' },
    { name: 'Jobs', count: jobCount, icon: '💼' },
  ];

  return (
    <div className="dashboard">
      <div className="dashboard-header">
        <div>
          <h1>Dashboard</h1>
          <p>Welcome back! Here's what's happening.</p>
        </div>
        <button 
          className="add-listing-btn"
          onClick={() => setShowAddModal(true)}
        >
          <Plus size={20} />
          New Listing
        </button>
      </div>

      <div className="stats-grid">
        {stats.map((stat, index) => (
          <div key={index} className="stat-card">
            <div className="stat-content">
              <div className="stat-icon">
                <stat.icon size={20} />
              </div>
              <div className="stat-info">
                <p className="stat-label">{stat.label}</p>
                <h3 className="stat-value">{stat.value}</h3>
                {stat.change && <p className="stat-change">{stat.change}</p>}
              </div>
            </div>
          </div>
        ))}
      </div>

      <div className="dashboard-content">
        <div className="dashboard-section">
          <h2>Listings by Category</h2>
          <div className="category-stats">
            {categoryStats.map((category, index) => (
              <div key={index} className="category-card">
                <div className="category-icon">{category.icon}</div>
                <div className="category-info">
                  <h3>{category.count}</h3>
                  <p>{category.name}</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="dashboard-grid">
          <div className="dashboard-section">
            <div className="section-header">
              <h2>Recent Listings</h2>
              <button className="see-all">See all</button>
            </div>
            <div className="listings-table">
              <table>
                <thead>
                  <tr>
                    <th>TITLE</th>
                    <th>CATEGORY</th>
                    <th>STATUS</th>
                    <th>ADDED</th>
                  </tr>
                </thead>
                <tbody>
                  {recentListings.map((listing, index) => (
                    <tr key={index}>
                      <td>{listing.title}</td>
                      <td>{listing.category}</td>
                      <td>
                        <span className={`status ${listing.status.toLowerCase()}`}>
                          {listing.status}
                        </span>
                      </td>
                      <td>{listing.added}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>

          <div className="dashboard-section">
            <div className="section-header">
              <h2>Recent Activity</h2>
              <button className="see-all">See all</button>
            </div>
            <div className="activity-list">
              {recentActivity_static.map((activity, index) => (
                <div key={index} className="activity-item">
                  <div className="activity-content">
                    <p className="activity-action">{activity.action}</p>
                    <p className="activity-detail">{activity.detail}</p>
                  </div>
                  <span className="activity-time">{activity.time}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>

      {showAddModal && (
        <AddListingModal 
          onClose={() => setShowAddModal(false)} 
          refreshDashboard={fetchJobs}
        />
      )}
    </div>
  );
};

export default Dashboard;
