import React, { useState } from 'react';
import { Eye, Check, X } from 'lucide-react';
import ReviewListingModal from './ReviewListingModal';

const ContentModeration = () => {
  const [showReviewModal, setShowReviewModal] = useState(false);
  const [selectedListing, setSelectedListing] = useState(null);

  const pendingListings = [
    {
      id: 1,
      title: 'New Great Indian Restaurant',
      category: 'Food',
      location: 'Berlin',
      contact: '+1 3736 37392',
      image: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=300&h=200&fit=crop',
      description: 'Authentic Italian cuisine with fresh ingredients imported from Italy. Family-owned business with 20 years of experience.',
      foodType: 'Veg/Non Veg',
      amenities: ['WiFi', 'Terrace Restaurant'],
      submittedBy: 'Maria Gracia',
      submittedTime: '2 hours ago'
    },
    {
      id: 2,
      title: 'Software Engineer',
      category: 'Job',
      location: '4th Floor, Tech Park',
      contact: '+1 3736 37392',
      image: 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=300&h=200&fit=crop',
      description: 'Looking for an experienced software engineer to join our growing team.',
      submittedBy: 'John Smith',
      submittedTime: '5 hours ago'
    }
  ];

  const handleView = (listing) => {
    setSelectedListing(listing);
    setShowReviewModal(true);
  };

  const handleApprove = (listingId) => {
    console.log('Approved listing:', listingId);
  };

  const handleReject = (listingId) => {
    console.log('Rejected listing:', listingId);
  };

  return (
    <div className="content-moderation">
      <div className="moderation-header">
        <div>
          <h1>Content Moderation</h1>
          <p>Review and approve pending listings.</p>
        </div>
      </div>

      <div className="pending-listings">
        {pendingListings.map((listing) => (
          <div key={listing.id} className="listing-card">
            <div className="listing-image">
              <img src={listing.image} alt={listing.title} />
            </div>
            <div className="listing-details">
              <div className="listing-header">
                <h3>{listing.title}</h3>
                <span className="listing-category">{listing.category}</span>
              </div>
              <div className="listing-info">
                <div className="info-row">
                  <span className="info-label">Location</span>
                  <span className="info-label">Contact</span>
                </div>
                <div className="info-row">
                  <span className="info-value">{listing.location}</span>
                  <span className="info-value">{listing.contact}</span>
                </div>
              </div>
            </div>
            <div className="listing-actions-vertical">
              <button 
                className="action-btn view-btn"
                onClick={() => handleView(listing)}
              >
                <Eye size={16} />
                View
              </button>
              <button 
                className="action-btn approve-btn"
                onClick={() => handleApprove(listing.id)}
              >
                <Check size={16} />
                Approve
              </button>
              <button 
                className="action-btn reject-btn"
                onClick={() => handleReject(listing.id)}
              >
                <X size={16} />
                Reject
              </button>
            </div>
          </div>
        ))}
      </div>

      {showReviewModal && selectedListing && (
        <ReviewListingModal 
          listing={selectedListing}
          onClose={() => setShowReviewModal(false)}
          onApprove={() => {
            handleApprove(selectedListing.id);
            setShowReviewModal(false);
          }}
          onReject={() => {
            handleReject(selectedListing.id);
            setShowReviewModal(false);
          }}
        />
      )}
    </div>
  );
};

export default ContentModeration;
