import React from 'react';
import { X, MapPin, Phone, Mail, Globe, Clock, DollarSign, Star, Edit } from 'lucide-react';

const ViewFoodGroceryModal = ({ item, onClose, onEdit }) => {
  return (
    <div className="modal-overlay">
      <div className="modal-content view-modal">
        <div className="modal-header">
          <h2>Listing Details</h2>
          <div className="header-actions">
            <button className="edit-btn" onClick={onEdit}>
              <Edit size={18} />
              Edit
            </button>
            <button className="close-btn" onClick={onClose}>
              <X size={24} />
            </button>
          </div>
        </div>

        <div className="view-content">
          {/* Image */}
          {item.image && (
            <div className="view-image">
              <img src={item.image} alt={item.title || item.name} />
            </div>
          )}

          {/* Basic Info */}
          <div className="view-section">
            <div className="view-header-info">
              <div>
                <h1>{item.title || item.name}</h1>
                <div className="badges">
                  <span className="category-badge">{item.subCategory || item.category}</span>
                  {item.type && <span className="type-badge">{item.type}</span>}
                  {item.featured && <span className="featured-badge">Featured</span>}
                  <span className={`status-badge ${item.verified ? 'active' : 'inactive'}`}>
                    {item.verified ? 'Verified' : 'Not Verified'}
                  </span>
                </div>
              </div>
              <div className="rating-display">
                <Star fill="#FFD700" color="#FFD700" size={24} />
                <span className="rating-value">{item.rating ? item.rating.toFixed(1) : '0.0'}</span>
              </div>
            </div>
          </div>

          {/* Location */}
          <div className="view-section">
            <h3>
              <MapPin size={18} />
              Location
            </h3>
            <div className="info-grid">
              <div className="info-item">
                <span className="info-label">Address:</span>
                <span className="info-value">{item.address}</span>
              </div>
              {item.city && (
                <div className="info-item">
                  <span className="info-label">City:</span>
                  <span className="info-value">{item.city}</span>
                </div>
              )}
              {item.state && (
                <div className="info-item">
                  <span className="info-label">State/Region:</span>
                  <span className="info-value">{item.state}</span>
                </div>
              )}
              {item.zipCode && (
                <div className="info-item">
                  <span className="info-label">Zip Code:</span>
                  <span className="info-value">{item.zipCode}</span>
                </div>
              )}
            </div>
          </div>

          {/* Contact */}
          <div className="view-section">
            <h3>
              <Phone size={18} />
              Contact Information
            </h3>
            <div className="info-grid">
              {item.phone && (
                <div className="info-item">
                  <span className="info-label">Phone:</span>
                  <span className="info-value">
                    <a href={`tel:${item.phone}`}>{item.phone}</a>
                  </span>
                </div>
              )}
              {item.email && (
                <div className="info-item">
                  <span className="info-label">Email:</span>
                  <span className="info-value">
                    <a href={`mailto:${item.email}`}>{item.email}</a>
                  </span>
                </div>
              )}
              {item.website && (
                <div className="info-item">
                  <span className="info-label">Website:</span>
                  <span className="info-value">
                    <a href={item.website} target="_blank" rel="noopener noreferrer">
                      {item.website}
                    </a>
                  </span>
                </div>
              )}
            </div>
          </div>

          {/* Description */}
          {item.description && (
            <div className="view-section">
              <h3>Description</h3>
              <p className="description-text">{item.description}</p>
            </div>
          )}

          {/* Details */}
          <div className="view-section">
            <h3>Details</h3>
            <div className="info-grid">
              {item.openingHours && (
                <div className="info-item">
                  <span className="info-label">
                    <Clock size={16} />
                    Opening Hours:
                  </span>
                  <span className="info-value">{item.openingHours}</span>
                </div>
              )}
              {item.priceRange && (
                <div className="info-item">
                  <span className="info-label">
                    <DollarSign size={16} />
                    Price Range:
                  </span>
                  <span className="info-value">{item.priceRange}</span>
                </div>
              )}
            </div>
          </div>

          {/* Cuisine */}
          {item.cuisine && item.cuisine.length > 0 && (
            <div className="view-section">
              <h3>Cuisine Types</h3>
              <div className="tags-display">
                {item.cuisine.map((cuisine, idx) => (
                  <span key={idx} className="display-tag">{cuisine}</span>
                ))}
              </div>
            </div>
          )}

          {/* Specialties */}
          {item.specialties && item.specialties.length > 0 && (
            <div className="view-section">
              <h3>Specialties</h3>
              <div className="tags-display">
                {item.specialties.map((specialty, idx) => (
                  <span key={idx} className="display-tag">{specialty}</span>
                ))}
              </div>
            </div>
          )}

          {/* Services */}
          <div className="view-section">
            <h3>Services Available</h3>
            <div className="services-list">
              <div className={`service-item ${item.deliveryAvailable ? 'available' : 'unavailable'}`}>
                <span className="service-indicator"></span>
                Home Delivery
              </div>
              <div className={`service-item ${item.takeoutAvailable ? 'available' : 'unavailable'}`}>
                <span className="service-indicator"></span>
                Takeout
              </div>
            </div>
          </div>

          {/* Metadata */}
          <div className="view-section metadata">
            <div className="info-grid">
              <div className="info-item">
                <span className="info-label">Created:</span>
                <span className="info-value">
                  {new Date(item.createdAt).toLocaleDateString('en-GB', { 
                    year: 'numeric', 
                    month: 'long', 
                    day: 'numeric' 
                  })}
                </span>
              </div>
              <div className="info-item">
                <span className="info-label">Last Updated:</span>
                <span className="info-value">
                  {new Date(item.updatedAt).toLocaleDateString('en-GB', { 
                    year: 'numeric', 
                    month: 'long', 
                    day: 'numeric' 
                  })}
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ViewFoodGroceryModal;
