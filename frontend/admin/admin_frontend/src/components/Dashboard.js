import React, { useState } from 'react';
import { Plus, TrendingUp, FolderOpen, Users, Clock } from 'lucide-react';
import AddListingModal from './AddListingModal';

const Dashboard = () => {
  const [showAddModal, setShowAddModal] = useState(false);

  const stats = [
    { label: 'Total Listings', value: '1,284', change: '+12% from last month', icon: TrendingUp },
    { label: 'Categories', value: '1,284', change: '', icon: FolderOpen },
    { label: 'Total Users', value: '1,284', change: '+6% from last month', icon: Users },
    { label: 'Pending Reviews', value: '2', change: '', icon: Clock },
  ];

  const recentListings = [
    { title: 'Cozy Studio Apartment', category: 'Accommodation', status: 'Pending', added: '2 hour ago' },
    { title: 'Italian Restaurant Opening', category: 'Food', status: 'Active', added: '12 hour ago' },
    { title: 'Senior Developer Position', category: 'Job', status: 'Active', added: '1 day ago' },
    { title: 'Plumbing Services', category: 'Services', status: 'Inactive', added: '1 day ago' },
    { title: 'Filipino Apartments', category: 'Accommodation', status: 'Active', added: '1 day ago' },
    { title: 'Plumbing Services', category: 'Services', status: 'Inactive', added: '1 day ago' },
  ];

  const recentActivity = [
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
    { name: 'Jobs', count: 3, icon: '💼' },
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
              {recentActivity.map((activity, index) => (
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
        <AddListingModal onClose={() => setShowAddModal(false)} />
      )}
    </div>
  );
};

export default Dashboard;
