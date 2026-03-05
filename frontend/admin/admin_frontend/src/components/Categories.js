import React, { useState, useEffect } from 'react';
import { Plus, Edit2, Trash2, X } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

const BASE = 'http://10.166.137.12:5000';

const DEFAULT_CATEGORIES = [
  { id: 'accommodation', name: 'Accommodation', icon: '🏠', description: 'Housing, apartments, student housing, and shared accommodations', api: `${BASE}/api/accommodation/admin`, route: '/accommodation-listings', status: 'active' },
  { id: 'food', name: 'Food', icon: '🍴', description: 'Indian grocery stores, restaurants, and food delivery services', api: `${BASE}/api/food/admin`, route: '/food-listings', status: 'active' },
  { id: 'services', name: 'Services', icon: '🔧', description: 'Immigration, legal, financial, and consultation services', api: `${BASE}/api/services/admin`, route: '/services-listings', status: 'disabled' },
  { id: 'jobs', name: 'Jobs', icon: '💼', description: 'Job listings, career opportunities, and employment services', api: `${BASE}/api/jobs/admin`, route: '/jobs-listings', status: 'active' },
];

const CategoryFormModal = ({ title, initial, onClose, onSave }) => {
  const [form, setForm] = useState(initial || { name: '', description: '', icon: '📋', status: 'active' });
  const set = key => e => setForm(p => ({ ...p, [key]: e.target.value }));
  return (
    <div className="modal-overlay">
      <div className="modal-content" style={{ maxWidth: 460 }}>
        <div className="modal-header">
          <h2>{title}</h2>
          <button className="close-btn" onClick={onClose}><X size={22} /></button>
        </div>
        <div className="add-listing-form">
          <div className="form-group">
            <label>Icon (emoji)</label>
            <input value={form.icon} onChange={set('icon')} placeholder="📋" style={{ width: 80 }} />
          </div>
          <div className="form-group">
            <label>Name <span style={{ color: 'red' }}>*</span></label>
            <input value={form.name} onChange={set('name')} placeholder="Category name" />
          </div>
          <div className="form-group">
            <label>Description <span style={{ color: 'red' }}>*</span></label>
            <textarea rows={2} value={form.description} onChange={set('description')} placeholder="Short description…" />
          </div>
          <div className="form-group">
            <label>Status</label>
            <select value={form.status} onChange={set('status')}>
              <option value="active">Active</option>
              <option value="disabled">Disabled</option>
            </select>
          </div>
          <div className="form-actions">
            <button className="cancel-btn" onClick={onClose}>Cancel</button>
            <button className="create-btn" onClick={() => {
              if (!form.name.trim() || !form.description.trim()) { alert('Name and description are required.'); return; }
              onSave(form);
            }}>Save</button>
          </div>
        </div>
      </div>
    </div>
  );
};

const Categories = () => {
  const navigate = useNavigate();

  // Default (built-in) cats — stored locally for status toggle only
  const [defaultCats, setDefaultCats] = useState(() => {
    try {
      const saved = localStorage.getItem('defaultCatStatuses');
      const statuses = saved ? JSON.parse(saved) : {};
      return DEFAULT_CATEGORIES.map(c => ({ ...c, status: statuses[c.id] || c.status }));
    } catch { return DEFAULT_CATEGORIES; }
  });

  // Custom categories from MongoDB
  const [customCats, setCustomCats] = useState([]);

  const [counts,       setCounts]       = useState({});
  const [statusFilter, setStatusFilter] = useState('all');
  const [showAdd,      setShowAdd]      = useState(false);
  const [editCat,      setEditCat]      = useState(null);

  const token   = () => localStorage.getItem('adminToken');
  const headers = () => ({ Authorization: `Bearer ${token()}` });

  // Fetch custom categories from backend
  const fetchCustomCats = async () => {
    try {
      const res = await fetch(`${BASE}/api/custom-categories`, { headers: headers() });
      if (res.ok) {
        const data = await res.json();
        setCustomCats(data.map(c => ({
          _id:         c._id,
          id:          c._id,
          name:        c.name,
          icon:        c.icon,
          description: c.description,
          status:      c.status,
          api:         `${BASE}/api/custom-categories/${c._id}/listings`,
          route:       `/custom-category/${c._id}`,
          isCustom:    true,
        })));
      }
    } catch (e) { console.error(e); }
  };

  useEffect(() => { fetchCustomCats(); }, []);

  // Merge all categories
  const allCategories = [...defaultCats, ...customCats];
  const visible = statusFilter === 'all' ? allCategories : allCategories.filter(c => c.status === statusFilter);

  // Fetch listing counts for each category
  useEffect(() => {
    const fetchCounts = async () => {
      const apiCats = allCategories.filter(c => c.api);
      const results = await Promise.allSettled(
        apiCats.map(c => fetch(c.api, { headers: headers() }).then(r => r.json()).catch(() => ({ count: 0 })))
      );
      const map = {};
      apiCats.forEach((c, i) => {
        const val = results[i].status === 'fulfilled' ? results[i].value : {};
        map[c.id] = val.count || 0;
      });
      setCounts(map);
    };
    if (allCategories.some(c => c.api)) fetchCounts();
  }, [customCats, defaultCats]);

  // ── Add (custom category → backend) ────────────────────────────────────────
  const handleAdd = async form => {
    try {
      const res = await fetch(`${BASE}/api/custom-categories`, {
        method: 'POST',
        headers: { ...headers(), 'Content-Type': 'application/json' },
        body: JSON.stringify({ name: form.name, description: form.description, icon: form.icon, status: form.status }),
      });
      if (res.ok) { await fetchCustomCats(); setShowAdd(false); }
      else { const d = await res.json(); alert(d.message); }
    } catch (e) { alert(e.message); }
  };

  // ── Edit ────────────────────────────────────────────────────────────────────
  const handleEditSave = async form => {
    if (form.isCustom) {
      try {
        const res = await fetch(`${BASE}/api/custom-categories/${form._id}`, {
          method: 'PUT',
          headers: { ...headers(), 'Content-Type': 'application/json' },
          body: JSON.stringify({ name: form.name, description: form.description, icon: form.icon, status: form.status }),
        });
        if (res.ok) { await fetchCustomCats(); setEditCat(null); }
        else { const d = await res.json(); alert(d.message); }
      } catch (e) { alert(e.message); }
    } else {
      // Default cat — update local state + localStorage
      const updated = defaultCats.map(c => c.id === form.id ? { ...c, ...form } : c);
      setDefaultCats(updated);
      setEditCat(null);
    }
  };

  // ── Toggle status ────────────────────────────────────────────────────────────
  const handleToggleStatus = async (id, newStatus, isCustom) => {
    if (isCustom) {
      try {
        await fetch(`${BASE}/api/custom-categories/${id}`, {
          method: 'PUT',
          headers: { ...headers(), 'Content-Type': 'application/json' },
          body: JSON.stringify({ status: newStatus }),
        });
        await fetchCustomCats();
      } catch (e) { console.error(e); }
    } else {
      const updated = defaultCats.map(c => c.id === id ? { ...c, status: newStatus } : c);
      setDefaultCats(updated);
      const statuses = {};
      updated.forEach(c => { statuses[c.id] = c.status; });
      localStorage.setItem('defaultCatStatuses', JSON.stringify(statuses));
    }
  };

  // ── Delete (custom only) ─────────────────────────────────────────────────────
  const handleDelete = async (cat) => {
    if (!cat.isCustom) { alert('Built-in categories cannot be deleted.'); return; }
    if (!window.confirm(`Delete "${cat.name}" and all its listings?`)) return;
    try {
      const res = await fetch(`${BASE}/api/custom-categories/${cat._id}`, {
        method: 'DELETE', headers: headers(),
      });
      if (res.ok) fetchCustomCats();
      else { const d = await res.json(); alert(d.message); }
    } catch (e) { alert(e.message); }
  };

  return (
    <div className="categories">
      <div className="categories-header">
        <div>
          <h1>Categories</h1>
          <p>Manage your app's category structure.</p>
        </div>
        <div className="header-actions">
          <select
            value={statusFilter}
            onChange={e => setStatusFilter(e.target.value)}
            style={{ padding: '8px 14px', borderRadius: 8, border: '1px solid #e5e7eb', fontSize: 14, cursor: 'pointer', background: '#fff' }}
          >
            <option value="all">All Categories</option>
            <option value="active">Active</option>
            <option value="disabled">Disabled</option>
          </select>
          <button className="add-listing-btn" onClick={() => setShowAdd(true)}>
            <Plus size={18} /> New Category
          </button>
        </div>
      </div>

      <div className="categories-grid">
        {visible.map(cat => {
          const count = counts[cat.id] || 0;
          const isActive = cat.status === 'active';
          return (
            <div
              key={cat.id}
              className="category-card-large"
              style={{ position: 'relative', cursor: cat.route ? 'pointer' : 'default' }}
              onClick={() => cat.route && navigate(cat.route)}
            >
              {/* status toggle */}
              <select
                value={cat.status}
                onClick={e => e.stopPropagation()}
                onChange={e => { e.stopPropagation(); handleToggleStatus(cat.id, e.target.value, cat.isCustom); }}
                style={{
                  position: 'absolute', top: 16, right: 16,
                  background: isActive ? '#d1fae5' : '#fee2e2',
                  color: isActive ? '#065f46' : '#991b1b',
                  fontSize: 12, fontWeight: 700, padding: '3px 12px', borderRadius: 20,
                  border: 'none', cursor: 'pointer', outline: 'none',
                }}
              >
                <option value="active">Active</option>
                <option value="disabled">Disabled</option>
              </select>

              {/* header */}
              <div className="category-header" style={{ paddingRight: 80 }}>
                <div className="category-icon-large">{cat.icon}</div>
                <div className="category-meta">
                  <h3>{cat.name}</h3>
                  <p className="category-listings">{count} listings</p>
                </div>
              </div>

              <p className="category-description">{cat.description}</p>

              <hr style={{ border: 'none', borderTop: '1px solid #f3f4f6', margin: '12px 0 10px' }} />

              {/* actions — stop propagation so card click doesn't navigate */}
              <div style={{ display: 'flex', gap: 8 }} onClick={e => e.stopPropagation()}>
                <button
                  title="Edit"
                  onClick={() => setEditCat(cat)}
                  style={{ background: 'none', border: '1px solid #e5e7eb', borderRadius: 6, padding: '5px 9px', cursor: 'pointer', color: '#374151', display: 'flex', alignItems: 'center' }}
                >
                  <Edit2 size={14} />
                </button>
                <button
                  onClick={() => handleDelete(cat)}
                  style={{ background: 'none', border: '1px solid #fee2e2', borderRadius: 6, padding: '5px 12px', cursor: 'pointer', color: '#ef4444', fontWeight: 600, fontSize: 13, display: 'flex', alignItems: 'center', gap: 5 }}
                >
                  <Trash2 size={14} /> Delete
                </button>
              </div>
            </div>
          );
        })}
      </div>

      {showAdd && <CategoryFormModal title="New Category" onClose={() => setShowAdd(false)} onSave={handleAdd} />}
      {editCat && <CategoryFormModal title="Edit Category" initial={editCat} onClose={() => setEditCat(null)} onSave={handleEditSave} />}
    </div>
  );
};

export default Categories;
