import React, { useState } from 'react';
import { X } from 'lucide-react';

const AddListingModal = ({ onClose }) => {
  const [formData, setFormData] = useState({
    title: '',
    category: 'Accommodation',
    location: '',
    contact: '',
    description: '',
    price: '',
    status: 'Active',
    amenities: []
  });

  const amenityOptions = ['WiFi', 'Parking', 'Balcony', 'Garden', 'Elevator'];

  const handleAmenityToggle = (amenity) => {
    setFormData(prev => ({
      ...prev,
      amenities: prev.amenities.includes(amenity)
        ? prev.amenities.filter(a => a !== amenity)
        : [...prev.amenities, amenity]
    }));
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    console.log('Form submitted:', formData);
    onClose();
  };

  return (
    <div className="modal-overlay">
      <div className="modal-content">
        <div className="modal-header">
          <h2>Add New Listing</h2>
          <button className="close-btn" onClick={onClose}>
            <X size={24} />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="add-listing-form">
          <div className="form-row">
            <div className="form-group">
              <label>Title</label>
              <input
                type="text"
                placeholder="Room"
                value={formData.title}
                onChange={(e) => setFormData(prev => ({...prev, title: e.target.value}))}
                required
              />
            </div>
            <div className="form-group">
              <label>Category</label>
              <select
                value={formData.category}
                onChange={(e) => setFormData(prev => ({...prev, category: e.target.value}))}
              >
                <option value="Accommodation">Accommodation</option>
                <option value="Food">Food</option>
                <option value="Services">Services</option>
                <option value="Job">Job</option>
              </select>
            </div>
          </div>

          <div className="form-row">
            <div className="form-group">
              <label>Location</label>
              <input
                type="text"
                placeholder="Munich"
                value={formData.location}
                onChange={(e) => setFormData(prev => ({...prev, location: e.target.value}))}
                required
              />
            </div>
            <div className="form-group">
              <label>Contact</label>
              <input
                type="text"
                placeholder="+49 52148 765397"
                value={formData.contact}
                onChange={(e) => setFormData(prev => ({...prev, contact: e.target.value}))}
                required
              />
            </div>
          </div>

          <div className="form-group">
            <label>Description</label>
            <textarea
              placeholder="Enter Description"
              value={formData.description}
              onChange={(e) => setFormData(prev => ({...prev, description: e.target.value}))}
              rows={4}
            />
          </div>

          <div className="form-row">
            <div className="form-group">
              <label>Price</label>
              <input
                type="text"
                placeholder="€1,000/month"
                value={formData.price}
                onChange={(e) => setFormData(prev => ({...prev, price: e.target.value}))}
              />
            </div>
            <div className="form-group">
              <label>Status</label>
              <select
                value={formData.status}
                onChange={(e) => setFormData(prev => ({...prev, status: e.target.value}))}
              >
                <option value="Active">Active</option>
                <option value="Pending">Pending</option>
                <option value="Inactive">Inactive</option>
              </select>
            </div>
          </div>

          <div className="form-group">
            <label>Amenities</label>
            <p className="form-help">Enter any Amenities or Choose Below</p>
            <div className="amenities-grid">
              {amenityOptions.map((amenity) => (
                <button
                  key={amenity}
                  type="button"
                  className={`amenity-btn ${formData.amenities.includes(amenity) ? 'selected' : ''}`}
                  onClick={() => handleAmenityToggle(amenity)}
                >
                  {amenity}
                </button>
              ))}
            </div>
          </div>

          <div className="form-actions">
            <button type="button" className="cancel-btn" onClick={onClose}>
              Cancel
            </button>
            <button type="submit" className="create-btn">
              Create
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default AddListingModal;
