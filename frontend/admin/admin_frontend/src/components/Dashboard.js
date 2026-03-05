import React, { useState, useEffect, useCallback } from 'react';
import { Plus, TrendingUp, FolderOpen, Users, Clock } from 'lucide-react';
import SimpleAddListingModal from './SimpleAddListingModal';

const BASE = 'http://10.233.141.31:5000';
const CATEGORY_APIS = {
  Accommodation: `${BASE}/api/accommodation/admin`,
  Food:          `${BASE}/api/food/admin`,
  Jobs:          `${BASE}/api/jobs/admin`,
  Services:      `${BASE}/api/services/admin`,
};

const Dashboard = () => {
  const [showAddModal, setShowAddModal]     = useState(false);
  const [totalCount, setTotalCount]         = useState(0);
  const [categoryCounts, setCategoryCounts] = useState({ Accommodation: 0, Food: 0, Jobs: 0, Services: 0 });
  const [userCount, setUserCount]           = useState(0);
  const [categoryCount, setCategoryCount]   = useState(4);
  const [recentListings, setRecentListings] = useState([]);

  useEffect(() => { fetchAll(); }, []);

  const fetchAll = useCallback(async () => {
    const token   = localStorage.getItem('adminToken');
    const headers = { Authorization: `Bearer ${token}` };

    // ── 1. Listing counts + data for built-in categories ───────────────────
    const listingResults = await Promise.allSettled(
      Object.entries(CATEGORY_APIS).map(([cat, url]) =>
        fetch(url, { headers })
          .then(r => r.json())
          .then(d => ({ cat, count: d.count || 0, data: d.data || [] }))
      )
    );

    const counts   = { Accommodation: 0, Food: 0, Jobs: 0, Services: 0 };
    const allItems = [];
    listingResults.forEach(r => {
      if (r.status !== 'fulfilled') return;
      const { cat, count, data } = r.value;
      counts[cat] = count;
      data.forEach(item => allItems.push({
        title:     item.title || item.name || item.jobTitle || item.serviceName || 'Untitled',
        category:  cat,
        status:    (item.status === 'active' || item.adminControls?.isActive) ? 'Active' : 'Inactive',
        createdAt: item.createdAt,
      }));
    });

    // ── 2. Custom category listings ──────────────────────────────────────────
    try {
      const catsRes = await fetch(`${BASE}/api/custom-categories`, { headers });
      if (catsRes.ok) {
        const customCats = await catsRes.json();
        // Fetch each category's listing count
        const customResults = await Promise.allSettled(
          customCats.map(c =>
            fetch(`${BASE}/api/custom-categories/${c._id}/listings`, { headers })
              .then(r => r.json())
              .then(d => ({ cat: c.name, count: d.count || 0, data: d.data || [] }))
          )
        );
        customResults.forEach(r => {
          if (r.status !== 'fulfilled') return;
          const { cat, count, data } = r.value;
          counts[cat] = count;
          data.forEach(item => allItems.push({
            title: item.title || 'Untitled', category: cat,
            status: item.status === 'active' ? 'Active' : 'Inactive',
            createdAt: item.createdAt,
          }));
        });
        // Update category count (4 built-in + customs)
        setCategoryCount(4 + customCats.length);
      }
    } catch {}

    allItems.sort((a, b) => new Date(b.createdAt || 0) - new Date(a.createdAt || 0));
    setCategoryCounts(counts);
    setTotalCount(Object.values(counts).reduce((s, c) => s + c, 0));
    setRecentListings(allItems.slice(0, 6));

    // ── 3. User count (customers only, no admins) ────────────────────────────
    try {
      const ur = await fetch(`${BASE}/api/user/all-users`, { headers });
      if (ur.ok) {
        const ud = await ur.json();
        setUserCount(Array.isArray(ud) ? ud.length : 0);
      }
    } catch {}
  }, []);

  const stats = [
    { label: 'Total Listings', value: totalCount,    icon: TrendingUp },
    { label: 'Categories',     value: categoryCount, icon: FolderOpen },
    { label: 'Total Users',    value: userCount,     icon: Users      },
    { label: 'Pending Reviews',value: 0,             icon: Clock      },
  ];

  const categoryStats = [
    { name: 'Accommodation', count: categoryCounts.Accommodation, icon: '🏠' },
    { name: 'Food',          count: categoryCounts.Food,          icon: '🍴' },
    { name: 'Services',      count: categoryCounts.Services,      icon: '🔧' },
    { name: 'Jobs',          count: categoryCounts.Jobs,          icon: '💼' },
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
                  {recentListings.length === 0 ? (
                    <tr><td colSpan={4} style={{ textAlign: 'center', color: '#6b7280', padding: 16 }}>No listings yet.</td></tr>
                  ) : recentListings.map((listing, index) => (
                    <tr key={index}>
                      <td>{listing.title}</td>
                      <td>{listing.category}</td>
                      <td>
                        <span className={`status ${listing.status.toLowerCase()}`}>
                          {listing.status}
                        </span>
                      </td>
                      <td>{listing.createdAt ? new Date(listing.createdAt).toLocaleDateString('en-GB') : '—'}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>

          <div className="dashboard-section">
            <div className="section-header">
              <h2>Recent Activity</h2>
            </div>
            <div className="activity-list">
              {recentListings.slice(0, 5).map((listing, index) => (
                <div key={index} className="activity-item">
                  <div className="activity-content">
                    <p className="activity-action">Listing added</p>
                    <p className="activity-detail">{listing.title}</p>
                  </div>
                  <span className="activity-time">{listing.createdAt ? new Date(listing.createdAt).toLocaleDateString('en-GB') : '—'}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>

      {showAddModal && (
        <SimpleAddListingModal
          onClose={() => setShowAddModal(false)}
          onSuccess={() => { setShowAddModal(false); fetchAll(); }}
        />
      )}
    </div>
  );
};

export default Dashboard;
