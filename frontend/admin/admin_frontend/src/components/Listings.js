import React, { useState } from 'react';
import { Plus, Edit, Trash2, ChevronLeft, ChevronRight } from 'lucide-react';
import AddListingModal from './AddListingModal';

const Listings = () => {
  const [showAddModal, setShowAddModal] = useState(false);

  const listings = [
    { title: 'Cozy Studio Apartment', category: 'Accommodation', location: 'Downtown, Main Street 123', status: 'Pending', created: '2024-11-02' },
    { title: 'Italian Restaurant Opening', category: 'Food', location: 'Food Street, Block A', status: 'Active', created: '2024-11-02' },
    { title: 'Senior Developer Position', category: 'Job', location: 'Tech Park, Building 5', status: 'Active', created: '2024-11-02' },
    { title: 'Plumbing Services', category: 'Services', location: 'Downtown, Main Street 123', status: 'Inactive', created: '2024-11-02' },
    { title: 'Filipino Apartments', category: 'Accommodation', location: 'Downtown, Main Street 123', status: 'Active', created: '2024-11-02' },
    { title: 'Plumbing Services', category: 'Services', location: 'Tech Park, Building 5', status: 'Inactive', created: '2024-11-01' },
    { title: 'Filipino Apartments', category: 'Accommodation', location: 'Tech Park, Building 5', status: 'Active', created: '2024-11-01' },
    { title: 'Plumbing Services', category: 'Services', location: 'Downtown, Main Street 123', status: 'Inactive', created: '2024-11-02' },
    { title: 'Filipino Apartments', category: 'Accommodation', location: 'Downtown, Main Street 123', status: 'Active', created: '2024-11-02' },
    { title: 'Plumbing Services', category: 'Services', location: 'Tech Park, Building 5', status: 'Inactive', created: '2024-11-01' },
    { title: 'Filipino Apartments', category: 'Accommodation', location: 'Tech Park, Building 5', status: 'Active', created: '2024-11-01' }
  ];

  return (
    <div className="listings">
      <div className="listings-header">
        <div>
          <h1>Listings</h1>
          <p>Manage all your listings in one place.</p>
        </div>
        <div className="header-actions">
          <select className="filter-select">
            <option>Newest First</option>
            <option>Oldest First</option>
            <option>A-Z</option>
          </select>
          <select className="filter-select">
            <option>All Listings</option>
            <option>Active</option>
            <option>Pending</option>
            <option>Inactive</option>
          </select>
          <button 
            className="add-listing-btn"
            onClick={() => setShowAddModal(true)}
          >
            <Plus size={20} />
            New Listing
          </button>
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
            {listings.map((listing, index) => (
              <tr key={index}>
                <td className="listing-title">{listing.title}</td>
                <td>{listing.category}</td>
                <td>{listing.location}</td>
                <td>
                  <span className={`status ${listing.status.toLowerCase()}`}>
                    {listing.status}
                  </span>
                </td>
                <td>{listing.created}</td>
                <td>
                  <div className="action-buttons">
                    <button className="action-btn edit-btn">
                      <Edit size={16} />
                    </button>
                    <button className="action-btn delete-btn">
                      <Trash2 size={16} />
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <div className="pagination">
        <div className="pagination-info">
          Showing 1-10 of {listings.length} results
        </div>
        <div className="pagination-controls">
          <button className="pagination-btn">
            <ChevronLeft size={16} />
          </button>
          <button className="pagination-btn active">1</button>
          <button className="pagination-btn">2</button>
          <button className="pagination-btn">3</button>
          <button className="pagination-btn">4</button>
          <button className="pagination-btn">
            <ChevronRight size={16} />
          </button>
        </div>
      </div>

      {showAddModal && (
        <AddListingModal onClose={() => setShowAddModal(false)} />
      )}
    </div>
  );
};

export default Listings;
