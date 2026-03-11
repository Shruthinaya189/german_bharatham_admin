import React, { useState, useEffect, useCallback } from 'react';
import { Plus, Trash2, Edit, Eye, ArrowLeft } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import AddListingModal from './AddListingModal';

const STATUS_COLORS = {
  active: { bg: '#d1fae5', color: '#065f46' },
  pending: { bg: '#fef3c7', color: '#92400e' },
  disabled: { bg: '#fee2e2', color: '#991b1b' },
};

const Badge = ({ label, active }) => (
  <span style={{
    display: 'inline-block', padding: '2px 10px', borderRadius: 12, fontSize: 12, fontWeight: 600,
    background: active ? '#d1fae5' : '#f3f4f6',
    color: active ? '#065f46' : '#6b7280',
    marginRight: 4, marginBottom: 3
  }}>{label}</span>
);

// ── View modal ──────────────────────────────────────────────────────────────
const ViewModal = ({ item, category, fields, onClose }) => {
  const [imgIdx, setImgIdx] = useState(0);
  if (!item) return null;
  const images = item.media?.images || [];
  return (
    <div className="modal-overlay">
      <div className="modal-content modal-large" style={{ maxHeight: '90vh', overflowY: 'auto' }}>
        <div className="modal-header">
          <h2 style={{ color: '#2d5a3d' }}>{item[fields.title] || 'Details'}</h2>
          <button className="close-btn" onClick={onClose}>✕</button>
        </div>
        {images.length > 0 && (
          <div style={{ marginBottom: 16 }}>
            <img src={images[imgIdx]} alt="main" style={{ width: '100%', maxHeight: 240, objectFit: 'cover', borderRadius: 8 }} />
            {images.length > 1 && (
              <div style={{ display: 'flex', gap: 6, marginTop: 6, flexWrap: 'wrap' }}>
                {images.map((img, i) => (
                  <img key={i} src={img} alt="" onClick={() => setImgIdx(i)}
                    style={{ width: 60, height: 48, objectFit: 'cover', borderRadius: 4, cursor: 'pointer', border: i === imgIdx ? '2px solid #6b9976' : '2px solid transparent' }} />
                ))}
              </div>
            )}
          </div>
        )}
        <div style={{ padding: '0 4px', fontSize: 14 }}>
          {fields.rows.map(([label, key]) => {
            let val = key.split('.').reduce((o, k) => o?.[k], item);
            if (val == null) val = '—';
            if (typeof val === 'boolean') val = val ? 'Yes' : 'No';
            if (Array.isArray(val) && typeof val[0] === 'string') {
              return (
                <div key={key} style={{ marginBottom: 10 }}>
                  <span style={{ color: '#1f2937', fontWeight: 700, minWidth: 140, display: 'inline-block' }}>{label}:</span>
                  <div style={{ marginTop: 4 }}>{val.map(v => <Badge key={v} label={v} active />)}</div>
                </div>
              );
            }
            return (
              <div key={key} style={{ display: 'flex', gap: 8, marginBottom: 6 }}>
                <span style={{ color: '#1f2937', fontWeight: 700, minWidth: 140 }}>{label}:</span>
                <span style={{ color: '#6b7280', fontWeight: 400 }}>{String(val)}</span>
              </div>
            );
          })}
        </div>
        <div className="form-actions"><button className="cancel-btn" onClick={onClose}>Close</button></div>
      </div>
    </div>
  );
};

// ── Image editor (used inside EditModal) ──────────────────────────────────
const ImageEditor = ({ images, onChange }) => {
  const handleAdd = e => {
    const valid = Array.from(e.target.files).filter(f => /\.(jpg|jpeg|png)$/i.test(f.name));
    if (valid.length !== e.target.files.length) alert('Only JPG, JPEG, PNG files are allowed.');
    valid.forEach(f => {
      const r = new FileReader();
      r.onloadend = () => onChange(prev => [...prev, r.result]);
      r.readAsDataURL(f);
    });
    e.target.value = '';
  };
  return (
    <div className="form-group">
      <label>Photos <span style={{ color: '#6b7280', fontSize: 12 }}>(JPG, JPEG, PNG)</span></label>
      <input type="file" accept=".jpg,.jpeg,.png,image/jpeg,image/png" multiple onChange={handleAdd} />
      {images.length > 0 && (
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6, marginTop: 6 }}>
          {images.map((img, i) => (
            <div key={i} style={{ position: 'relative' }}>
              <img src={img} alt={`img-${i}`} style={{ width: 72, height: 58, objectFit: 'cover', borderRadius: 6, border: '2px solid #6b9976' }} />
              <button type="button" onClick={() => onChange(prev => prev.filter((_, x) => x !== i))}
                style={{ position: 'absolute', top: -6, right: -6, background: '#ef4444', color: '#fff', border: 'none', borderRadius: '50%', width: 18, height: 18, fontSize: 11, cursor: 'pointer', padding: 0, lineHeight: '18px', textAlign: 'center' }}>✕</button>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

// ── Edit modal ──────────────────────────────────────────────────────────────
const EditModal = ({ item, category, apiBase, onClose, onSuccess }) => {
  const [data, setData] = useState({ ...item, _images: item.media?.images || item.images || [] });
  const [saving, setSaving] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSaving(true);
    try {
      const token = localStorage.getItem('adminToken');
      const payload = { ...data, media: { ...data.media, images: data._images } };
      delete payload._images;
      const res = await fetch(`${apiBase}/${item._id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
        body: JSON.stringify(payload),
      });
      if (res.ok) { onSuccess(); onClose(); }
      else { const e2 = await res.json(); alert('Error: ' + e2.message); }
    } catch (ex) { alert('Error: ' + ex.message); }
    finally { setSaving(false); }
  };

  const field = (label, key, type = 'text') => (
    <div className="form-group" key={key}>
      <label>{label}</label>
      {type === 'textarea' ? (
        <textarea rows={3} value={data[key] || ''} onChange={e => setData(p => ({ ...p, [key]: e.target.value }))} />
      ) : (
        <input type={type} value={data[key] || ''} onChange={e => setData(p => ({ ...p, [key]: e.target.value }))} />
      )}
    </div>
  );

  return (
    <div className="modal-overlay">
      <div className="modal-content modal-large" style={{ maxHeight: '90vh', overflowY: 'auto' }}>
        <div className="modal-header">
          <h2>Edit {category} Listing</h2>
          <button className="close-btn" onClick={onClose}>✕</button>
        </div>
        <form onSubmit={handleSubmit} className="add-listing-form">
          {category === 'Food' && (<>
            {field('Name', 'name')} {field('Restaurant Name', 'restaurantName')}
            {field('City', 'city')} {field('Postal Code', 'postalCode')}
            {field('Area', 'area')} {field('Address', 'address')}
            {field('Contact Phone', 'contactPhone')} {field('Cuisine', 'cuisine')}
            {field('Price Range', 'priceRange')} {field('Opening Hours', 'openingHours')}
            {field('Description', 'description', 'textarea')}
            <ImageEditor images={data._images} onChange={fn => setData(p => ({ ...p, _images: typeof fn === 'function' ? fn(p._images) : fn }))} />
          </>)}
          {category === 'Jobs' && (<>
            {field('Job Title', 'jobTitle')} {field('Company', 'company')}
            {field('City', 'city')} {field('Area', 'area')}
            {field('Contact Phone', 'contactPhone')} {field('Salary', 'salary')}
            {field('Description', 'description', 'textarea')}
            <div className="form-group"><label>Job Type</label>
              <select value={data.jobType || 'Full-time'} onChange={e => setData(p => ({ ...p, jobType: e.target.value }))}>
                {['Full-time','Part-time','Contract','Internship','Freelance'].map(t => <option key={t}>{t}</option>)}
              </select>
            </div>
            <ImageEditor images={data._images} onChange={fn => setData(p => ({ ...p, _images: typeof fn === 'function' ? fn(p._images) : fn }))} />
          </>)}
          {category === 'Services' && (<>
            {field('Service Name', 'serviceName')} {field('Provider Name', 'providerName')}
            {field('City', 'city')} {field('Postal Code', 'postalCode')}
            {field('Area', 'area')} {field('Address', 'address')}
            {field('Contact Phone', 'contactPhone')} {field('Price Range', 'priceRange')}
            {field('Description', 'description', 'textarea')}
            <ImageEditor images={data._images} onChange={fn => setData(p => ({ ...p, _images: typeof fn === 'function' ? fn(p._images) : fn }))} />
          </>)}
          <div className="form-group"><label>Status</label>
            <select value={data.status || 'active'} onChange={e => setData(p => ({ ...p, status: e.target.value }))}>
              <option value="active">Active</option>
              <option value="pending">Pending</option>
              <option value="disabled">Disabled</option>
            </select>
          </div>
          <div className="form-actions">
            <button type="button" className="cancel-btn" onClick={onClose} disabled={saving}>Cancel</button>
            <button type="submit" className="create-btn" disabled={saving}>{saving ? 'Saving…' : 'Save Changes'}</button>
          </div>
        </form>
      </div>
    </div>
  );
};

// ── Main page ────────────────────────────────────────────────────────────────
const GenericCategoryListings = ({ category, apiBase, icon, viewFields }) => {
  const navigate = useNavigate();
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showAdd, setShowAdd] = useState(false);
  const [viewItem, setViewItem] = useState(null);
  const [editItem, setEditItem] = useState(null);
  const [statusFilter, setStatusFilter] = useState('');
  const [searchQuery, setSearchQuery] = useState('');

  const fetchItems = useCallback(async () => {
    setLoading(true);
    try {
      const token = localStorage.getItem('adminToken');
      const url = statusFilter ? `${apiBase}?status=${statusFilter}` : apiBase;
      const res = await fetch(url, { headers: { 'Authorization': `Bearer ${token}` } });
      if (res.ok) { const d = await res.json(); setItems(d.data || []); }
    } catch (e) { console.error(e); }
    finally { setLoading(false); }
  }, [apiBase, statusFilter]);

  useEffect(() => { fetchItems(); }, [fetchItems]);

  const handleDelete = async (id, name) => {
    if (!window.confirm(`Delete "${name}"?`)) return;
    try {
      const token = localStorage.getItem('adminToken');
      const res = await fetch(`${apiBase}/${id}`, { method: 'DELETE', headers: { 'Authorization': `Bearer ${token}` } });
      if (res.ok) fetchItems(); else alert('Failed to delete');
    } catch (e) { alert(e.message); }
  };

  const patchStatus = async (id, status) => {
    try {
      const token = localStorage.getItem('adminToken');
      await fetch(`${apiBase}/${id}/status`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
        body: JSON.stringify({ status }),
      });
      fetchItems();
    } catch (e) { alert(e.message); }
  };

  const getTitle = item => item[viewFields.title] || item[viewFields.titleKey] || 'Untitled';
  const getSub = item => item[viewFields.subKey] || '';
  const getLoc = item => item.location || [item.city, item.area].filter(Boolean).join(', ') || 'N/A';

  const displayItems = searchQuery
    ? items.filter(item => {
        const q = searchQuery.toLowerCase();
        return [
          getTitle(item), getSub(item), getLoc(item),
          item.status, item.contact, item.phone, item.email
        ].some(v => v && String(v).toLowerCase().includes(q));
      })
    : items;

  return (
    <div className="listings">
      <div className="listings-header">
        <div>
          <button onClick={() => navigate('/categories')}
            style={{ 
              background: '#2d5a3d', 
              border: 'none', 
              color: '#fff', 
              cursor: 'pointer', 
              display: 'flex', 
              alignItems: 'center', 
              gap: 6, 
              marginBottom: 8, 
              fontSize: 14,
              padding: '8px 16px',
              borderRadius: 8,
              fontWeight: 500,
              transition: 'all 0.2s'
            }}
            onMouseEnter={(e) => e.currentTarget.style.background = '#234a31'}
            onMouseLeave={(e) => e.currentTarget.style.background = '#2d5a3d'}>
            <ArrowLeft size={16} /> Back to Categories
          </button>
          <h1>{icon} {category} Listings</h1>
          <p>Total: {items.length}</p>
        </div>
        <div className="header-actions">
          <input
            type="text"
            placeholder={`Search ${category.toLowerCase()}...`}
            value={searchQuery}
            onChange={e => setSearchQuery(e.target.value)}
            style={{ padding:'8px 12px', borderRadius:8, border:'1px solid #e5e7eb', fontSize:14, minWidth:200 }}
          />
          <select className="filter-select" value={statusFilter} onChange={e => setStatusFilter(e.target.value)}>
            <option value="">All Status</option>
            <option value="active">Active</option>
            <option value="pending">Pending</option>
            <option value="disabled">Disabled</option>
          </select>
          <button className="add-listing-btn" onClick={() => setShowAdd(true)}>
            <Plus size={18} /> New {category}
          </button>
        </div>
      </div>

      {loading ? (
        <div style={{ textAlign: 'center', padding: 40 }}>Loading…</div>
      ) : displayItems.length === 0 ? (
        <div style={{ textAlign: 'center', padding: 40 }}>No {category.toLowerCase()} listings found.</div>
      ) : (
        <div className="listings-table">
          <table>
            <thead>
              <tr>
                <th>IMAGE</th>
                <th>NAME</th>
                <th>{viewFields.subLabel}</th>
                <th>LOCATION</th>
                <th>CONTACT</th>
                <th>STATUS</th>
                <th>CREATED</th>
                <th>ACTION</th>
              </tr>
            </thead>
            <tbody>
              {displayItems.map(item => (
                <tr key={item._id}>
                  <td>
                    {(() => {
                      const imgSrc = item.companyLogo
                        ? (item.companyLogo.startsWith('data:') || item.companyLogo.startsWith('http') ? item.companyLogo : `http://localhost:5000${item.companyLogo}`)
                        : (item.media?.images?.[0] || item.images?.[0] || item.image || null);
                      return imgSrc
                        ? <img src={imgSrc} alt="" style={{ width: 56, height: 44, objectFit: 'cover', borderRadius: 6, border: '1px solid #e5e7eb' }} />
                        : <div style={{ width: 56, height: 44, background: '#f3f4f6', borderRadius: 6, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 18 }}>📷</div>;
                    })()}
                  </td>
                  <td className="listing-title">{getTitle(item)}</td>
                  <td>{getSub(item) || '—'}</td>
                  <td>{getLoc(item)}</td>
                  <td>{item.contact || item.phone || item.contactPhone || '—'}</td>
                  <td>
                    <select
                      value={item.status || 'active'}
                      onChange={e => patchStatus(item._id, e.target.value)}
                      style={{ 
                        padding: '6px 24px 6px 10px', 
                        borderRadius: 12, 
                        fontSize: 12, 
                        fontWeight: 600, 
                        border: '1px solid #e5e7eb', 
                        backgroundColor: (item.status === 'pending' ? '#fef3c7' : item.status === 'disabled' ? '#fee2e2' : '#d1fae5'),
                        color: (item.status === 'pending' ? '#92400e' : item.status === 'disabled' ? '#991b1b' : '#065f46'),
                        cursor: 'pointer',
                        outline: 'none',
                        appearance: 'auto',
                        WebkitAppearance: 'auto'
                      }}>
                      <option value="active" style={{ backgroundColor: '#d1fae5', color: '#065f46' }}>Active</option>
                      <option value="pending" style={{ backgroundColor: '#fef3c7', color: '#92400e' }}>Pending</option>
                      <option value="disabled" style={{ backgroundColor: '#fee2e2', color: '#991b1b' }}>Disabled</option>
                    </select>
                  </td>
                  <td>{item.createdAt ? new Date(item.createdAt).toLocaleDateString('en-GB') : 'N/A'}</td>
                  <td>
                    <div className="action-buttons">
                      <button className="action-btn" title="View" style={{ color: '#6b9976' }} onClick={() => setViewItem(item)}><Eye size={15} /></button>
                      <button className="action-btn" title="Edit" style={{ color: '#3b82f6' }} onClick={() => setEditItem(item)}><Edit size={15} /></button>
                      <button className="action-btn delete-btn" title="Delete" onClick={() => handleDelete(item._id, getTitle(item))}><Trash2 size={15} /></button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {showAdd && (
        <AddListingModal
          onClose={() => setShowAdd(false)}
          onSuccess={() => fetchItems()}
          defaultCategory={category}
          lockCategory={true}
        />
      )}
      {viewItem && (
        <ViewModal item={viewItem} category={category} fields={viewFields} onClose={() => setViewItem(null)} />
      )}
      {editItem && (
        <EditModal item={editItem} category={category} apiBase={apiBase} onClose={() => setEditItem(null)} onSuccess={fetchItems} />
      )}
    </div>
  );
};

export default GenericCategoryListings;
