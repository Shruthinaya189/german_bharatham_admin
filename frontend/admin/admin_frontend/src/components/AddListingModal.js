import React, { useState } from 'react';
import { X } from 'lucide-react';

const BASE = 'https://german-bharatham-backend.onrender.com';
const REQ = <span style={{ color: 'red' }}>*</span>;

// ── helpers ──────────────────────────────────────────────────────────────────

const ImageUpload = ({ images, onChange }) => (
  <div className="form-group">
    <label>Photos <span style={{ color: 'red' }}>*</span> <span style={{ color: '#6b7280', fontSize: 12 }}>(JPG, JPEG, PNG — at least 1 required)</span></label>
    <input type="file" accept=".jpg,.jpeg,.png,image/jpeg,image/png" multiple onChange={e => {
      const valid = Array.from(e.target.files).filter(f => /\.(jpg|jpeg|png)$/i.test(f.name));
      if (valid.length !== e.target.files.length) alert('Only JPG, JPEG, and PNG files are allowed.');
      valid.forEach(f => {
        const r = new FileReader();
        r.onloadend = () => onChange(prev => [...prev, r.result]);
        r.readAsDataURL(f);
      });
      e.target.value = '';
    }} />
    {images.length > 0 && (
      <div style={{ display: 'flex', flexWrap: 'wrap', gap: 6, marginTop: 6 }}>
        {images.map((img, i) => (
          <div key={i} style={{ position: 'relative' }}>
            <img src={img} alt={`up-${i}`} style={{ width: 80, height: 65, objectFit: 'cover', borderRadius: 6, border: '2px solid #6b9976' }} />
            <button type="button" onClick={() => onChange(prev => prev.filter((_, x) => x !== i))}
              style={{ position: 'absolute', top: -6, right: -6, background: '#ef4444', color: '#fff', border: 'none', borderRadius: '50%', width: 18, height: 18, fontSize: 11, cursor: 'pointer', padding: 0, lineHeight: '18px', textAlign: 'center' }}>✕</button>
          </div>
        ))}
      </div>
    )}
  </div>
);

const ChipsInput = ({ label, options, selected, onToggle, onTypeAdd }) => {
  const [typed, setTyped] = useState('');
  return (
    <div className="form-group">
      <label>{label}</label>
      <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap', marginBottom: 6 }}>
        {options.map(o => (
          <button key={o} type="button" onClick={() => onToggle(o)}
            style={{ padding: '4px 12px', borderRadius: 20, fontSize: 13, border: '1px solid #6b9976', background: selected.includes(o) ? '#6b9976' : '#fff', color: selected.includes(o) ? '#fff' : '#374151', cursor: 'pointer' }}>
            {o}
          </button>
        ))}
      </div>
      {onTypeAdd && (
        <div style={{ display: 'flex', gap: 6 }}>
          <input value={typed} onChange={e => setTyped(e.target.value)} placeholder="Type custom…" style={{ flex: 1 }} onKeyDown={e => { if (e.key === 'Enter') { e.preventDefault(); if (typed.trim()) { onTypeAdd(typed.trim()); setTyped(''); } } }} />
          <button type="button" onClick={() => { if (typed.trim()) { onTypeAdd(typed.trim()); setTyped(''); } }} style={{ padding: '6px 12px', background: '#6b9976', color: '#fff', border: 'none', borderRadius: 6, cursor: 'pointer' }}>Add</button>
        </div>
      )}
    </div>
  );
};

// ── Category forms ────────────────────────────────────────────────────────────

const AccommodationForm = ({ data, set }) => {
  const amenityOpts = ['Balcony','Terrace','Garden','Lift','Parking','Garage','Cellar','Washing Machine','Dishwasher','Kitchen','Pets Allowed','Smoking Allowed','Anmeldung Possible','Student Friendly','Wheelchair Accessible'];
  return (
    <>
      <div className="form-row">
        <div className="form-group">
          <label>Title {REQ}</label>
          <input value={data.title} onChange={e => set(p => ({...p, title: e.target.value}))} placeholder="Cozy 2-Bedroom Apartment" />
        </div>
        <div className="form-group">
          <label>Property Type {REQ}</label>
          <select value={data.propertyType} onChange={e => set(p => ({...p, propertyType: e.target.value}))}>
            <option value="apartment">Apartment</option>
            <option value="house">House</option>
            <option value="studio">Studio</option>
            <option value="shared_room">Shared Room</option>
            <option value="wg">WG</option>
          </select>
        </div>
      </div>
      <div className="form-row">
        <div className="form-group">
          <label>City {REQ}</label>
          <input value={data.city} onChange={e => set(p => ({...p, city: e.target.value}))} placeholder="Munich" />
        </div>
        <div className="form-group">
          <label>Postal Code {REQ}</label>
          <input value={data.postalCode} onChange={e => set(p => ({...p, postalCode: e.target.value}))} placeholder="80331" />
        </div>
      </div>
      <div className="form-row">
        <div className="form-group">
          <label>Area</label>
          <input value={data.area} onChange={e => set(p => ({...p, area: e.target.value}))} placeholder="Schwabing" />
        </div>
        <div className="form-group">
          <label>Address</label>
          <input value={data.address} onChange={e => set(p => ({...p, address: e.target.value}))} placeholder="Leopoldstraße 1" />
        </div>
      </div>
      <div className="form-group">
        <label>Contact Phone {REQ}</label>
        <input value={data.contactPhone} onChange={e => set(p => ({...p, contactPhone: e.target.value}))} placeholder="+49 170 1234567" />
      </div>
      <div className="form-group">
        <label>Description {REQ}</label>
        <textarea value={data.description} onChange={e => set(p => ({...p, description: e.target.value}))} rows={3} placeholder="Detailed description…" />
      </div>
      <div className="form-row">
        <div className="form-group">
          <label>Cold Rent (€) {REQ}</label>
          <input type="number" value={data.coldRent} onChange={e => set(p => ({...p, coldRent: e.target.value}))} placeholder="800" />
        </div>
        <div className="form-group">
          <label>Warm Rent (€) {REQ}</label>
          <input type="number" value={data.warmRent} onChange={e => set(p => ({...p, warmRent: e.target.value}))} placeholder="1000" />
        </div>
        <div className="form-group">
          <label>Deposit (€) {REQ}</label>
          <input type="number" value={data.deposit} onChange={e => set(p => ({...p, deposit: e.target.value}))} placeholder="2400" />
        </div>
      </div>
      <div className="form-row">
        <div className="form-group">
          <label>Size (sqm) {REQ}</label>
          <input type="number" value={data.sizeSqm} onChange={e => set(p => ({...p, sizeSqm: e.target.value}))} placeholder="50" />
        </div>
        <div className="form-group">
          <label>Bedrooms {REQ}</label>
          <input type="number" value={data.bedrooms} onChange={e => set(p => ({...p, bedrooms: e.target.value}))} placeholder="2" />
        </div>
        <div className="form-group">
          <label>Bathrooms {REQ}</label>
          <input type="number" value={data.bathrooms} onChange={e => set(p => ({...p, bathrooms: e.target.value}))} placeholder="1" />
        </div>
      </div>
      <ChipsInput label="Amenities (select or type)" options={amenityOpts}
        selected={data.amenities}
        onToggle={a => set(p => ({ ...p, amenities: p.amenities.includes(a) ? p.amenities.filter(x => x !== a) : [...p.amenities, a] }))}
        onTypeAdd={a => set(p => ({ ...p, amenities: p.amenities.includes(a) ? p.amenities : [...p.amenities, a] }))}
      />
      <ImageUpload images={data.images} onChange={fn => set(p => ({ ...p, images: fn(p.images) }))} />
    </>
  );
};

const FoodForm = ({ data, set }) => {
  const amenityOpts = ['Vegetarian', 'Vegan', 'Halal', 'Delivery', 'Takeaway', 'Dine-in', 'WiFi', 'Parking'];
  return (
    <>
      <div className="form-row">
        <div className="form-group">
          <label>Name {REQ}</label>
          <input value={data.name} onChange={e => set(p => ({...p, name: e.target.value}))} placeholder="e.g. Spice Garden" />
        </div>
        <div className="form-group">
          <label>Restaurant / Store Name {REQ}</label>
          <input value={data.restaurantName} onChange={e => set(p => ({...p, restaurantName: e.target.value}))} placeholder="Spice Garden GmbH" />
        </div>
      </div>
      <div className="form-row">
        <div className="form-group">
          <label>City {REQ}</label>
          <input value={data.city} onChange={e => set(p => ({...p, city: e.target.value}))} placeholder="Munich" />
        </div>
        <div className="form-group">
          <label>Postal Code {REQ}</label>
          <input value={data.postalCode} onChange={e => set(p => ({...p, postalCode: e.target.value}))} placeholder="80331" />
        </div>
      </div>
      <div className="form-row">
        <div className="form-group">
          <label>Area</label>
          <input value={data.area} onChange={e => set(p => ({...p, area: e.target.value}))} placeholder="Maxvorstadt" />
        </div>
        <div className="form-group">
          <label>Address</label>
          <input value={data.address} onChange={e => set(p => ({...p, address: e.target.value}))} placeholder="Leopoldstraße 1" />
        </div>
      </div>
      <div className="form-row">
        <div className="form-group">
          <label>Contact Phone {REQ}</label>
          <input value={data.contactPhone} onChange={e => set(p => ({...p, contactPhone: e.target.value}))} placeholder="+49 170 1234567" />
        </div>
        <div className="form-group">
          <label>Cuisine</label>
          <input value={data.cuisine} onChange={e => set(p => ({...p, cuisine: e.target.value}))} placeholder="Indian, Italian…" />
        </div>
      </div>
      <div className="form-row">
        <div className="form-group">
          <label>Price Range</label>
          <input value={data.priceRange} onChange={e => set(p => ({...p, priceRange: e.target.value}))} placeholder="€5–€15" />
        </div>
        <div className="form-group">
          <label>Opening Hours</label>
          <input value={data.openingHours} onChange={e => set(p => ({...p, openingHours: e.target.value}))} placeholder="Mon–Sat 10:00–22:00" />
        </div>
      </div>
      <div className="form-group">
        <label>Description {REQ}</label>
        <textarea value={data.description} onChange={e => set(p => ({...p, description: e.target.value}))} rows={3} placeholder="About this place…" />
      </div>
      <ChipsInput label="Features (select or type)" options={amenityOpts}
        selected={data.amenities}
        onToggle={a => set(p => ({ ...p, amenities: p.amenities.includes(a) ? p.amenities.filter(x => x !== a) : [...p.amenities, a] }))}
        onTypeAdd={a => set(p => ({ ...p, amenities: p.amenities.includes(a) ? p.amenities : [...p.amenities, a] }))}
      />
      <ImageUpload images={data.images} onChange={fn => set(p => ({ ...p, images: fn(p.images) }))} />
    </>
  );
};

const JobsForm = ({ data, set }) => {
  const skillOpts = ['JavaScript', 'Python', 'React', 'Node.js', 'Java', 'SQL', 'Excel', 'German', 'English', 'Communication'];
  return (
    <>
      <div className="form-row">
        <div className="form-group">
          <label>Job Title {REQ}</label>
          <input value={data.jobTitle} onChange={e => set(p => ({...p, jobTitle: e.target.value}))} placeholder="Senior Developer" />
        </div>
        <div className="form-group">
          <label>Company {REQ}</label>
          <input value={data.company} onChange={e => set(p => ({...p, company: e.target.value}))} placeholder="Tech GmbH" />
        </div>
      </div>
      <div className="form-row">
        <div className="form-group">
          <label>City {REQ}</label>
          <input value={data.city} onChange={e => set(p => ({...p, city: e.target.value}))} placeholder="Munich" />
        </div>
        <div className="form-group">
          <label>Area</label>
          <input value={data.area} onChange={e => set(p => ({...p, area: e.target.value}))} placeholder="Maxvorstadt" />
        </div>
      </div>
      <div className="form-row">
        <div className="form-group">
          <label>Contact Phone / Email {REQ}</label>
          <input value={data.contactPhone} onChange={e => set(p => ({...p, contactPhone: e.target.value}))} placeholder="+49 170 1234567 or hr@example.com" />
        </div>
        <div className="form-group">
          <label>Job Type</label>
          <select value={data.jobType} onChange={e => set(p => ({...p, jobType: e.target.value}))}>
            <option>Full-time</option>
            <option>Part-time</option>
            <option>Contract</option>
            <option>Internship</option>
            <option>Freelance</option>
          </select>
        </div>
      </div>
      <div className="form-row">
        <div className="form-group">
          <label>Salary</label>
          <input value={data.salary} onChange={e => set(p => ({...p, salary: e.target.value}))} placeholder="€50,000 / year" />
        </div>
        <div className="form-group">
          <label>Address</label>
          <input value={data.address} onChange={e => set(p => ({...p, address: e.target.value}))} placeholder="Office address (optional)" />
        </div>
      </div>
      <div className="form-group">
        <label>Description {REQ}</label>
        <textarea value={data.description} onChange={e => set(p => ({...p, description: e.target.value}))} rows={3} placeholder="Job responsibilities, requirements…" />
      </div>
      <ImageUpload images={data.images || []} onChange={fn => set(p => ({ ...p, images: typeof fn === 'function' ? fn(p.images || []) : fn }))} />
      <ChipsInput label="Skills (select or type)" options={skillOpts}
        selected={data.skills}
        onToggle={s => set(p => ({ ...p, skills: p.skills.includes(s) ? p.skills.filter(x => x !== s) : [...p.skills, s] }))}
        onTypeAdd={s => set(p => ({ ...p, skills: p.skills.includes(s) ? p.skills : [...p.skills, s] }))}
      />
    </>
  );
};

const ServicesForm = ({ data, set }) => {
  const serviceTypes = ['Immigration', 'Legal', 'Financial', 'Tax', 'Consultation', 'Home Services', 'IT Services', 'Education', 'Translation', 'Other'];
  return (
    <>
      <div className="form-row">
        <div className="form-group">
          <label>Service Name {REQ}</label>
          <input value={data.serviceName} onChange={e => set(p => ({...p, serviceName: e.target.value}))} placeholder="Visa Consultation" />
        </div>
        <div className="form-group">
          <label>Provider Name {REQ}</label>
          <input value={data.providerName} onChange={e => set(p => ({...p, providerName: e.target.value}))} placeholder="Max Mustermann" />
        </div>
      </div>
      <div className="form-row">
        <div className="form-group">
          <label>City {REQ}</label>
          <input value={data.city} onChange={e => set(p => ({...p, city: e.target.value}))} placeholder="Munich" />
        </div>
        <div className="form-group">
          <label>Postal Code {REQ}</label>
          <input value={data.postalCode} onChange={e => set(p => ({...p, postalCode: e.target.value}))} placeholder="80331" />
        </div>
      </div>
      <div className="form-row">
        <div className="form-group">
          <label>Area</label>
          <input value={data.area} onChange={e => set(p => ({...p, area: e.target.value}))} placeholder="Maxvorstadt" />
        </div>
        <div className="form-group">
          <label>Address</label>
          <input value={data.address} onChange={e => set(p => ({...p, address: e.target.value}))} placeholder="Street, No." />
        </div>
      </div>
      <div className="form-row">
        <div className="form-group">
          <label>Contact Phone {REQ}</label>
          <input value={data.contactPhone} onChange={e => set(p => ({...p, contactPhone: e.target.value}))} placeholder="+49 170 1234567" />
        </div>
        <div className="form-group">
          <label>Price Range</label>
          <input value={data.priceRange} onChange={e => set(p => ({...p, priceRange: e.target.value}))} placeholder="€50/hour" />
        </div>
      </div>
      <div className="form-group">
        <label>Service Type</label>
        <select value={data.serviceType} onChange={e => set(p => ({...p, serviceType: e.target.value}))}>
          <option value="">— select —</option>
          {serviceTypes.map(t => <option key={t}>{t}</option>)}
        </select>
      </div>
      <div className="form-group">
        <label>Description {REQ}</label>
        <textarea value={data.description} onChange={e => set(p => ({...p, description: e.target.value}))} rows={3} placeholder="What you offer…" />
      </div>
      <ImageUpload images={data.images} onChange={fn => set(p => ({ ...p, images: fn(p.images) }))} />
    </>
  );
};

// ── Main modal ────────────────────────────────────────────────────────────────

const DEFAULTS = {
  Accommodation: { title:'', propertyType:'apartment', city:'', area:'', postalCode:'', address:'', contactPhone:'', description:'', coldRent:'', warmRent:'', deposit:'', sizeSqm:'', bedrooms:'', bathrooms:'', amenities:[], images:[], status:'active' },
  Food: { name:'', restaurantName:'', city:'', area:'', postalCode:'', address:'', contactPhone:'', cuisine:'', description:'', priceRange:'', openingHours:'', amenities:[], images:[], status:'active' },
  Jobs: { jobTitle:'', company:'', city:'', area:'', address:'', contactPhone:'', description:'', salary:'', jobType:'Full-time', skills:[], images:[], status:'active' },
  Services: { serviceName:'', providerName:'', serviceType:'', city:'', area:'', postalCode:'', address:'', contactPhone:'', description:'', priceRange:'', images:[], status:'active' },
};

const CATEGORY_LABELS = ['Accommodation', 'Food', 'Jobs', 'Services'];

const validate = (category, data) => {
  if (category === 'Accommodation') {
    if (!data.title?.trim()) return 'Title is required';
    if (!data.contactPhone?.trim()) return 'Contact Phone is required';
    if (!data.city?.trim()) return 'City is required';
    if (!data.postalCode?.trim()) return 'Postal Code is required';
    if (!data.description?.trim()) return 'Description is required';
    if (!data.coldRent) return 'Cold Rent is required';
    if (!data.warmRent) return 'Warm Rent is required';
    if (!data.deposit) return 'Deposit is required';
    if (!data.sizeSqm) return 'Size (sqm) is required';
    if (!data.bedrooms) return 'Bedrooms is required';
    if (!data.bathrooms) return 'Bathrooms is required';
    if (!data.images || data.images.length === 0) return 'At least one photo (JPG/JPEG/PNG) is required';
  }
  if (category === 'Food') {
    if (!data.name?.trim()) return 'Name is required';
    if (!data.restaurantName?.trim()) return 'Restaurant / Store Name is required';
    if (!data.city?.trim()) return 'City is required';
    if (!data.postalCode?.trim()) return 'Postal Code is required';
    if (!data.contactPhone?.trim()) return 'Contact Phone is required';
    if (!data.description?.trim()) return 'Description is required';
    if (!data.images || data.images.length === 0) return 'At least one photo (JPG/JPEG/PNG) is required';
  }
  if (category === 'Jobs') {
    if (!data.jobTitle?.trim()) return 'Job Title is required';
    if (!data.company?.trim()) return 'Company is required';
    if (!data.city?.trim()) return 'City is required';
    if (!data.contactPhone?.trim()) return 'Contact Phone is required';
    if (!data.description?.trim()) return 'Description is required';
    if (!data.images || data.images.length === 0) return 'At least one photo (JPG/JPEG/PNG) is required';
  }
  if (category === 'Services') {
    if (!data.serviceName?.trim()) return 'Service Name is required';
    if (!data.providerName?.trim()) return 'Provider Name is required';
    if (!data.city?.trim()) return 'City is required';
    if (!data.postalCode?.trim()) return 'Postal Code is required';
    if (!data.contactPhone?.trim()) return 'Contact Phone is required';
    if (!data.description?.trim()) return 'Description is required';
    if (!data.images || data.images.length === 0) return 'At least one photo (JPG/JPEG/PNG) is required';
  }
  return null;
};

const buildPayload = (category, data) => {
  if (category === 'Accommodation') {
    return {
      title: data.title?.trim(),
      propertyType: data.propertyType,
      city: data.city?.trim(),
      area: data.area?.trim() || null,
      postalCode: data.postalCode?.trim(),
      address: data.address?.trim() || null,
      contactPhone: data.contactPhone?.trim(),
      description: data.description?.trim() || null,
      status: data.status,
      rentDetails: { coldRent: +data.coldRent, warmRent: +data.warmRent, deposit: +data.deposit },
      propertyDetails: { sizeSqm: +data.sizeSqm, bedrooms: +data.bedrooms, bathrooms: +data.bathrooms },
      amenities: data.amenities.reduce((a, k) => {
        const key = k.replace(/ ([A-Z])/g, (_, c) => c.toLowerCase()).replace(/^./, c => c.toLowerCase()).replace(/ /g, '');
        a[key] = true; return a;
      }, {}),
      media: { images: data.images || [] },
      adminControls: { isActive: data.status === 'active' },
    };
  }
  if (category === 'Food') {
    return {
      name: data.name?.trim(),
      restaurantName: data.restaurantName?.trim(),
      city: data.city?.trim(),
      area: data.area?.trim() || null,
      postalCode: data.postalCode?.trim(),
      address: data.address?.trim() || null,
      contactPhone: data.contactPhone?.trim(),
      cuisine: data.cuisine?.trim() || null,
      description: data.description?.trim() || null,
      priceRange: data.priceRange?.trim() || null,
      openingHours: data.openingHours?.trim() || null,
      amenities: data.amenities,
      media: { images: data.images || [] },
      status: data.status,
    };
  }
  if (category === 'Jobs') {
    return {
      jobTitle: data.jobTitle?.trim(),
      company: data.company?.trim(),
      city: data.city?.trim(),
      area: data.area?.trim() || null,
      address: data.address?.trim() || null,
      contactPhone: data.contactPhone?.trim(),
      description: data.description?.trim() || null,
      salary: data.salary?.trim() || null,
      jobType: data.jobType,
      skills: data.skills,
      media: { images: data.images || [] },
      status: data.status,
    };
  }
  if (category === 'Services') {
    return {
      serviceName: data.serviceName?.trim(),
      providerName: data.providerName?.trim(),
      serviceType: data.serviceType || null,
      city: data.city?.trim(),
      area: data.area?.trim() || null,
      postalCode: data.postalCode?.trim(),
      address: data.address?.trim() || null,
      contactPhone: data.contactPhone?.trim(),
      description: data.description?.trim() || null,
      priceRange: data.priceRange?.trim() || null,
      media: { images: data.images || [] },
      status: data.status,
    };
  }
};

const API_MAP = {
  Accommodation: `${BASE}/api/accommodation/admin`,
  Food: `${BASE}/api/food/admin`,
  Jobs: `${BASE}/api/jobs/admin`,
  Services: `${BASE}/api/services/admin`,
};

const AddListingModal = ({ onClose, onSuccess, defaultCategory }) => {
  const [category, setCategory] = useState(defaultCategory || 'Accommodation');
  const [formData, setFormData] = useState(DEFAULTS[defaultCategory || 'Accommodation']);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleCategoryChange = (cat) => {
    setCategory(cat);
    setFormData(DEFAULTS[cat]);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const err = validate(category, formData);
    if (err) { alert(err); return; }
    setIsSubmitting(true);
    try {
      const token = localStorage.getItem('adminToken');
      const res = await fetch(API_MAP[category], {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
        body: JSON.stringify(buildPayload(category, formData)),
      });
      if (res.ok) {
        alert(`${category} listing created successfully!`);
        onSuccess && onSuccess(category);
        onClose();
      } else {
        const err2 = await res.json();
        alert('Error: ' + err2.message);
      }
    } catch (ex) {
      alert('Error connecting to server: ' + ex.message);
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="modal-overlay">
      <div className="modal-content modal-large" style={{ minHeight: 520, maxHeight: '90vh', overflowY: 'auto' }}>
        <div className="modal-header">
          <h2>Add New Listing</h2>
          <button className="close-btn" onClick={onClose}><X size={24} /></button>
        </div>

        {/* Category selector */}
        <div style={{ display: 'flex', gap: 8, marginBottom: 20, flexWrap: 'wrap' }}>
          {CATEGORY_LABELS.map(c => (
            <button key={c} type="button" onClick={() => handleCategoryChange(c)}
              style={{ padding: '6px 16px', borderRadius: 20, border: '2px solid #6b9976', background: category === c ? '#6b9976' : '#fff', color: category === c ? '#fff' : '#374151', fontWeight: 600, cursor: 'pointer', fontSize: 13 }}>
              {c === 'Accommodation' ? '🏠' : c === 'Food' ? '🍴' : c === 'Jobs' ? '💼' : '🔧'} {c}
            </button>
          ))}
        </div>

        <form onSubmit={handleSubmit} className="add-listing-form">
          {category === 'Accommodation' && <AccommodationForm data={formData} set={setFormData} />}
          {category === 'Food' && <FoodForm data={formData} set={setFormData} />}
          {category === 'Jobs' && <JobsForm data={formData} set={setFormData} />}
          {category === 'Services' && <ServicesForm data={formData} set={setFormData} />}

          {/* Status */}
          <div className="form-group" style={{ marginTop: 8 }}>
            <label>Status</label>
            <select value={formData.status} onChange={e => setFormData(p => ({...p, status: e.target.value}))}>
              <option value="active">Active</option>
              <option value="pending">Pending</option>
              <option value="disabled">Disabled</option>
            </select>
          </div>

          <div className="form-actions">
            <button type="button" className="cancel-btn" onClick={onClose} disabled={isSubmitting}>Cancel</button>
            <button type="submit" className="create-btn" disabled={isSubmitting}>
              {isSubmitting ? 'Creating…' : 'Create Listing'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default AddListingModal;

