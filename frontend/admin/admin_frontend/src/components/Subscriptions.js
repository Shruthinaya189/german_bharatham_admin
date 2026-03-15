import React, { useEffect, useState } from 'react';
import API_URL from '../config';

const Subscriptions = () => {
  const [items, setItems] = useState([]);
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(true);

  const BASE = API_URL;

  const fetchSubscriptions = async () => {
    setLoading(true);
    setError(null);
    try {
      const token = localStorage.getItem('adminToken');
      const res = await fetch(`${BASE}/api/subscriptions/admin`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });
      const text = await res.text();
      let data;
      try {
        data = text ? JSON.parse(text) : null;
      } catch (_) {
        data = null;
      }
      if (!res.ok) {
        const message = (data && data.message)
          ? data.message
          : (text && text.trim().startsWith('<!DOCTYPE'))
            ? `Failed (HTTP ${res.status}) - backend returned HTML (likely not redeployed)`
            : `Failed (HTTP ${res.status})`;
        setError(message);
        setItems([]);
        return;
      }
      setItems(Array.isArray(data) ? data : []);
    } catch (e) {
      setError(e?.message || 'Failed to load subscriptions');
      setItems([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchSubscriptions();
  }, []);

  return (
    <div className="users">
      <div className="users-header">
        <div>
          <h1>Subscriptions</h1>
          <p>View all user subscriptions.</p>
        </div>
        <div className="header-filters">
          <button className="action-btn activate-btn" onClick={fetchSubscriptions}>
            Refresh
          </button>
        </div>
      </div>

      <div className="users-table">
        <table>
          <thead>
            <tr>
              <th>USER ID</th>
              <th>STATUS</th>
              <th>PLAN</th>
              <th>PERIOD END</th>
              <th>PROVIDER</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr><td colSpan={5} style={{ textAlign: 'center', padding: 24, color: '#6b7280' }}>Loading…</td></tr>
            ) : error ? (
              <tr><td colSpan={5} style={{ textAlign: 'center', padding: 24, color: '#b00020' }}>{error}</td></tr>
            ) : items.length === 0 ? (
              <tr><td colSpan={5} style={{ textAlign: 'center', padding: 24, color: '#6b7280' }}>No subscriptions found.</td></tr>
            ) : items.map((s) => (
              <tr key={s._id}>
                <td style={{ fontFamily: 'monospace', fontSize: 12 }}>{s.userId}</td>
                <td>{s.status}</td>
                <td>{s.planId || '-'}</td>
                <td>{s.currentPeriodEnd ? new Date(s.currentPeriodEnd).toLocaleString() : '-'}</td>
                <td>{s.provider}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {!loading && !error && items.length > 0 && (
        <p style={{ fontSize: 13, color: '#6b7280', padding: '8px 0', textAlign: 'right' }}>
          Total: {items.length}
        </p>
      )}
    </div>
  );
};

export default Subscriptions;