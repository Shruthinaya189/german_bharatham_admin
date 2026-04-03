import React, { useEffect, useMemo, useState } from 'react';
import { Eye, Check, X } from 'lucide-react';
import ReviewListingModal from './ReviewListingModal';
import SkeletonLoader from './SkeletonLoader';
import API_URL from '../config';

const ContentModeration = () => {
  const [showReviewModal, setShowReviewModal] = useState(false);
  const [selectedListing, setSelectedListing] = useState(null);
  const [pendingListings, setPendingListings] = useState([]);
  const [loading, setLoading] = useState(true);

  const ENDPOINTS = useMemo(() => ([
    { category: 'Accommodation', apiBase: `${API_URL}/api/accommodation/admin` },
    { category: 'Food', apiBase: `${API_URL}/api/admin/foodgrocery` },
    { category: 'Jobs', apiBase: `${API_URL}/api/jobs/admin` },
    { category: 'Services', apiBase: `${API_URL}/api/services/admin` },
  ]), []);

  const authHeaders = () => {
    const token = localStorage.getItem('adminToken');
    return { 'Authorization': `Bearer ${token}` };
  };

  const computeImage = (category, raw) => {
    const img = raw.companyLogo || raw.media?.images?.[0] || raw.images?.[0] || raw.image || null;
    if (img) return img;
    if (category === 'Services') return '/service-default.jpg';
    return null;
  };

  const mapListing = (category, apiBase, raw) => {
    const title = raw.title || raw.serviceName || raw.name || raw.jobTitle || 'Untitled';
    const location = raw.location || raw.city || raw.address || raw.zipCode || '';
    const contact = raw.contact || raw.phone || raw.contactPhone || raw.email || '—';
    const images = raw.media?.images || raw.images || (raw.image ? [raw.image] : []);
    const image = computeImage(category, raw);
    const amenities = raw.amenities || [];
    const description = raw.description || '';

    return {
      id: raw._id,
      apiBase,
      raw,
      title,
      category,
      location,
      contact,
      images,
      image,
      description,
      amenities: Array.isArray(amenities) ? amenities : [],
    };
  };

  const fetchPending = async () => {
    setLoading(true);
    try {
      const headers = authHeaders();
      const results = await Promise.all(
        ENDPOINTS.map(async ({ category, apiBase }) => {
          // Fetch all and filter client-side so we don't miss older records with different status casing.
          const res = await fetch(apiBase, { headers });
          if (!res.ok) return [];
          const json = await res.json();
          const data = Array.isArray(json) ? json : (json.data || []);
          const pending = data.filter(x => String(x.status || '').toLowerCase() === 'pending');
          return pending.map(raw => mapListing(category, apiBase, raw));
        })
      );
      setPendingListings(results.flat());
    } catch (e) {
      console.error(e);
      setPendingListings([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { fetchPending(); }, []);

  const handleView = (listing) => {
    setSelectedListing(listing);
    setShowReviewModal(true);
  };

  const updateStatus = async (listing, status) => {
    try {
      const token = localStorage.getItem('adminToken');
      const res = await fetch(`${listing.apiBase}/${listing.id}/status`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
        body: JSON.stringify({ status }),
      });
      if (!res.ok) {
        const e2 = await res.json().catch(() => ({}));
        throw new Error(e2.message || 'Failed to update status');
      }
      await fetchPending();
    } catch (e) {
      alert(e.message);
    }
  };

  const handleApprove = (listing) => updateStatus(listing, 'active');

  const handleReject = async (listing) => {
    try {
      const token = localStorage.getItem('adminToken');
      const res = await fetch(`${listing.apiBase}/${listing.id}`, {
        method: 'DELETE',
        headers: { 'Authorization': `Bearer ${token}` },
      });
      if (!res.ok) {
        const e2 = await res.json().catch(() => ({}));
        throw new Error(e2.message || 'Failed to delete listing');
      }
      await fetchPending();
    } catch (e) {
      alert(e.message);
    }
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
        {loading ? (
          <SkeletonLoader rows={3} columns={5} type="list" />
        ) : pendingListings.length === 0 ? (
          <div style={{ padding: 30, textAlign: 'center' }}>No pending listings.</div>
        ) : pendingListings.map((listing) => (
          <div key={listing.id} className="listing-card">
            <div className="listing-image">
              {listing.image ? (
                <img src={listing.image} alt={listing.title} />
              ) : (
                <div style={{ width: '100%', height: '100%', background: '#f3f4f6', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 22 }}>📷</div>
              )}
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
                onClick={() => handleApprove(listing)}
              >
                <Check size={16} />
                Approve
              </button>
              <button 
                className="action-btn reject-btn"
                onClick={() => handleReject(listing)}
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
            handleApprove(selectedListing);
            setShowReviewModal(false);
          }}
          onReject={() => {
            handleReject(selectedListing);
            setShowReviewModal(false);
          }}
        />
      )}
    </div>
  );
};

export default ContentModeration;
