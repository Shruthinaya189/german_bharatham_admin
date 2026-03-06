import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { Plus, Edit, Trash2, Briefcase } from 'lucide-react';
import AddListingModal from './AddListingModal';

const Listings = () => {
  const [showAddModal, setShowAddModal] = useState(false);
  const [listings, setListings] = useState([]);
  const [editJob, setEditJob] = useState(null);
  const [sortBy, setSortBy] = useState('newest');
  const [filterBy, setFilterBy] = useState('all');

  // Fetch listings from backend
  useEffect(() => {
    fetchListings();
  }, []);

  const fetchListings = async () => {
    try {
      const token = localStorage.getItem('adminToken');
      const headers = { 'Authorization': `Bearer ${token}` };
      
      // Fetch from all three endpoints
      const [jobsRes, accommodationRes, foodRes] = await Promise.all([
        axios.get("http://localhost:5000/api/admin/jobs", { headers }).catch(() => ({ data: [] })),
        axios.get("http://localhost:5000/api/accommodation/admin", { headers }).catch(() => ({ data: { data: [] } })),
        axios.get("http://localhost:5000/api/food/admin", { headers }).catch(() => ({ data: { data: [] } }))
      ]);
      
      // Combine all listings
      const jobs = Array.isArray(jobsRes.data) ? jobsRes.data : [];
      const accommodations = accommodationRes.data.data || [];
      const food = foodRes.data.data || [];
      
      // Normalize data structure
      const normalizedJobs = jobs.map(item => ({
        ...item,
        category: 'Job',
        location: item.location || 'N/A'
      }));
      
      const normalizedAccommodations = accommodations.map(item => ({
        ...item,
        category: 'Accommodation',
        location: item.city || item.location || 'N/A'
      }));
      
      const normalizedFood = food.map(item => ({
        ...item,
        category: 'Food',
        location: item.city || item.location || 'N/A'
      }));
      
      setListings([...normalizedJobs, ...normalizedAccommodations, ...normalizedFood]);
    } catch (error) {
      console.error("Error fetching listings:", error);
      setListings([]);
    }
  };

  // Delete listing
  const handleDelete = async (id, category) => {
    try {
      const token = localStorage.getItem('adminToken');
      const headers = { 'Authorization': `Bearer ${token}` };
      
      let endpoint = '';
      if (category === 'Job') {
        endpoint = `http://localhost:5000/api/admin/jobs/${id}`;
      } else if (category === 'Accommodation') {
        endpoint = `http://localhost:5000/api/accommodation/admin/${id}`;
      } else if (category === 'Food') {
        endpoint = `http://localhost:5000/api/food/admin/${id}`;
      }
      
      if (endpoint) {
        await axios.delete(endpoint, { headers });
        fetchListings(); // refresh list
      }
    } catch (error) {
      console.error("Delete failed:", error);
    }
  };

  // Edit listing
  const handleEdit = (listing) => {
    setEditJob(listing);
    setShowAddModal(true);
  };

  // Filter and sort listings
  const getFilteredListings = () => {
    let filtered = [...listings];

    // Filter by category
    if (filterBy !== 'all') {
      filtered = filtered.filter(item => item.category === filterBy);
    }

    // Sort
    if (sortBy === 'newest') {
      filtered.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    } else if (sortBy === 'oldest') {
      filtered.sort((a, b) => new Date(a.createdAt) - new Date(b.createdAt));
    }

    return filtered;
  };

  const filteredListings = getFilteredListings();
  const categories = ['Accommodation', 'Food', 'Job', 'Services'];

  return (
    <div className="listings">
      <div className="listings-header">
        <div>
          <h1>Listings</h1>
          <p>Manage all your listings in one place.</p>
        </div>
        <div className="header-actions">
          <button
            className="add-listing-btn"
            onClick={() => {
              setEditJob(null);
              setShowAddModal(true);
            }}
          >
            <Plus size={20} />
            New Listing
          </button>
        </div>
      </div>

      {/* Filter Section */}
      <div className="listings-filters">
        <div className="filter-group">
          <select 
            value={sortBy} 
            onChange={(e) => setSortBy(e.target.value)}
            className="filter-dropdown"
          >
            <option value="newest">Newest first</option>
            <option value="oldest">Oldest first</option>
          </select>
        </div>
        <div className="filter-group">
          <select 
            value={filterBy} 
            onChange={(e) => setFilterBy(e.target.value)}
            className="filter-dropdown"
          >
            <option value="all">All Listings</option>
            {categories.map(cat => (
              <option key={cat} value={cat}>{cat}</option>
            ))}
          </select>
        </div>
      </div>

      <div className="listings-table">
        <table>
          <thead>
            <tr>
              <th>TITLE</th>
              <th>CATEGORY</th>
              <th>LOCATION</th>
              <th>STATUS</th>
              <th>CREATED</th>
              <th>ACTION</th>
            </tr>
          </thead>
          <tbody>
            {filteredListings.map((listing) => (
              <tr key={listing._id}>
                <td>{listing.title}</td>
                <td>{listing.category}</td>
                <td>{listing.location}</td>
                <td>
                  <span className={`status-badge ${listing.status?.toLowerCase()}`}>
                    {listing.status}
                  </span>
                </td>
                <td>
                  {listing.createdAt
                    ? new Date(listing.createdAt).toLocaleDateString()
                    : ""}
                </td>
                <td>
                  <div className="action-buttons">
                    <button 
                      className="action-btn edit-btn"
                      onClick={() => handleEdit(listing)}
                    >
                      <Edit size={16} />
                    </button>
                    <button
                      className="action-btn delete-btn"
                      onClick={() => handleDelete(listing._id, listing.category)}
                    >
                      <Trash2 size={16} />
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {showAddModal && (
        <AddListingModal
          editJob={editJob}
          refreshJobs={() => {
            setShowAddModal(false);
            setEditJob(null);
            fetchListings(); // refresh after adding/editing
          }}
          onClose={() => {
            setShowAddModal(false);
            setEditJob(null);
          }}
        />
      )}
    </div>
  );
};

export default Listings;