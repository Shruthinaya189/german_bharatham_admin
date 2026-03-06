import React, { useState, useEffect } from 'react';
import { Plus, Trash2, Eye, ArrowLeft, Search } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import AddFoodGroceryModal from './AddFoodGroceryModal';
import ViewFoodGroceryModal from './ViewFoodGroceryModal';
import EditFoodGroceryModal from './EditFoodGroceryModal';

const BASE = 'http://localhost:5000';

const STATUS_COLORS = {
  Active: { bg: '#d1fae5', color: '#065f46' },
  Pending: { bg: '#fef3c7', color: '#92400e' },
  Inactive: { bg: '#fee2e2', color: '#991b1b' },
};

export default function FoodListings() {
  const navigate = useNavigate();
  const [listings, setListings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [statusFilter, setStatusFilter] = useState('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [showAddModal, setShowAddModal] = useState(false);
  const [viewItem, setViewItem] = useState(null);
  const [editItem, setEditItem] = useState(null);

  const fetchListings = async () => {
    setLoading(true);
    try {
      const token = localStorage.getItem('adminToken');
      const res = await fetch(`${BASE}/api/food/admin`, {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (res.ok) {
        const responseData = await res.json();
        console.log('API Response:', responseData);
        // Handle both formats: array or {data, count}
        const items = Array.isArray(responseData) ? responseData : (responseData.data || []);
        setListings(items);
      }
    } catch (error) {
      console.error('Error fetching food listings:', error);
      setListings([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchListings();
  }, []);

  const handleDelete = async (id) => {
    if (!window.confirm('Are you sure you want to delete this listing?')) return;
    try {
      const token = localStorage.getItem('adminToken');
      const res = await fetch(`${BASE}/api/food/admin/${id}`, {
        method: 'DELETE',
        headers: { 'Authorization': `Bearer ${token}` }
      });
      if (res.ok) {
        fetchListings();
      } else {
        alert('Failed to delete listing');
      }
    } catch (error) {
      alert('Error: ' + error.message);
    }
  };

  const handleStatusChange = async (id, newStatus) => {
    try {
      const token = localStorage.getItem('adminToken');
      const res = await fetch(`${BASE}/api/food/admin/${id}/status`, {
        method: 'PATCH',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ status: newStatus })
      });
      if (res.ok) {
        fetchListings();
      } else {
        alert('Failed to update status');
      }
    } catch (error) {
      alert('Error: ' + error.message);
    }
  };

  const filtered = listings
    .filter(item => statusFilter === 'all' || item.status === statusFilter)
    .filter(item => {
      if (!searchQuery.trim()) return true;
      const query = searchQuery.toLowerCase();
      return (
        (item.title || '').toLowerCase().includes(query) ||
        (item.city || '').toLowerCase().includes(query) ||
        (item.subCategory || '').toLowerCase().includes(query)
      );
    });

  return (
    <div className="category-listings">
      <div className="listings-header">
        <div>
          <button onClick={() => navigate('/categories')} className="back-button">
            <ArrowLeft size={20} />
            <span>Back to Categories</span>
          </button>
          <h1>🍴 Food Listings</h1>
          <p>Total: {filtered.length}</p>
        </div>
        <div className="header-actions">
          <div className="search-box" style={{ position: 'relative' }}>
            <Search size={20} style={{ position: 'absolute', left: '14px', top: '50%', transform: 'translateY(-50%)', color: '#9ca3af' }} />
            <input
              type="text"
              placeholder="Search by name, city, or category..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              style={{
                paddingLeft: '44px',
                paddingRight: '16px',
                paddingTop: '10px',
                paddingBottom: '10px',
                border: '1px solid #e5e7eb',
                borderRadius: '8px',
                fontSize: '15px',
                width: '320px',
                outline: 'none'
              }}
            />
          </div>
          <select 
            className="filter-select" 
            value={statusFilter} 
            onChange={(e) => setStatusFilter(e.target.value)}
          >
            <option value="all">All Status</option>
            <option value="Active">Active</option>
            <option value="Pending">Pending</option>
            <option value="Inactive">Inactive</option>
          </select>
          <button className="add-listing-btn" onClick={() => setShowAddModal(true)}>
            <Plus size={20} />
            New Food
          </button>
        </div>
      </div>

      {loading ? (
        <div style={{ textAlign: 'center', padding: '40px', color: '#6b7280' }}>
          Loading...
        </div>
      ) : filtered.length === 0 ? (
        <div style={{ textAlign: 'center', padding: '40px', color: '#6b7280' }}>
          No food listings found.
        </div>
      ) : (
        <div className="listings-table">
          <table>
            <thead>
              <tr>
                <th>NAME</th>
                <th>SUB CATEGORY</th>
                <th>CITY</th>
                <th>PHONE</th>
                <th>STATUS</th>
                <th>CREATED</th>
                <th>ACTION</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((item) => (
                <tr key={item._id}>
                  <td className="listing-title">{item.title || 'Untitled'}</td>
                  <td>{item.subCategory || 'N/A'}</td>
                  <td>{item.city || 'N/A'}</td>
                  <td>{item.phone || 'N/A'}</td>
                  <td>
                    <select
                      className="status-badge"
                      value={item.status}
                      onChange={(e) => handleStatusChange(item._id, e.target.value)}
                      style={{
                        backgroundColor: STATUS_COLORS[item.status]?.bg || '#f3f4f6',
                        color: STATUS_COLORS[item.status]?.color || '#6b7280',
                        border: 'none',
                        padding: '4px 8px',
                        borderRadius: '12px',
                        fontSize: '12px',
                        fontWeight: '600',
                        cursor: 'pointer'
                      }}
                    >
                      <option value="Active">Active</option>
                      <option value="Pending">Pending</option>
                      <option value="Inactive">Inactive</option>
                    </select>
                  </td>
                  <td>{item.createdAt ? new Date(item.createdAt).toLocaleDateString('en-GB') : 'N/A'}</td>
                  <td>
                    <div className="action-buttons">
                      <button 
                        className="action-btn view-btn" 
                        onClick={() => setViewItem(item)}
                        title="View"
                      >
                        <Eye size={16} />
                      </button>
                      <button 
                        className="action-btn delete-btn" 
                        onClick={() => handleDelete(item._id)}
                        title="Delete"
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
      )}

      {showAddModal && (
        <AddFoodGroceryModal 
          onClose={() => setShowAddModal(false)} 
          onSuccess={() => {
            setShowAddModal(false);
            fetchListings();
          }}
        />
      )}

      {viewItem && (
        <ViewFoodGroceryModal 
          item={viewItem}
          onClose={() => setViewItem(null)}
        />
      )}

      {editItem && (
        <EditFoodGroceryModal 
          item={editItem}
          onClose={() => setEditItem(null)}
          onSuccess={() => {
            setEditItem(null);
            fetchListings();
          }}
        />
      )}
    </div>
  );
}
