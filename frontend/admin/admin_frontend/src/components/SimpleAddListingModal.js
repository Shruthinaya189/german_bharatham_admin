import React, { useState } from "react";
import { X } from "lucide-react";

const BASE = "http://localhost:5000";

const DEFAULT_AMENITIES = ["WiFi", "Parking", "Balcony", "Garden", "Elevator"];

const SimpleAddListingModal = ({ onClose, onSuccess }) => {
  const [form, setForm] = useState({
    title: "",
    category: "Accommodation",
    propertyType: "Apartment",
    subCategory: "Restaurant", // for Food
    type: "", // cuisine for Food
    location: "",
    address: "", // for Food
    city: "", // for Food
    state: "", // for Food
    zipCode: "", // for Food
    contact: "",
    email: "", // for Food
    website: "", // for Food
    description: "",
    openingHours: "", // for Food
    price: "",
    status: "Active",
    image: "", // for Food
  });

  // Food-specific arrays
  const [cuisine, setCuisine] = useState([]);
  const [specialties, setSpecialties] = useState([]);
  const [cuisineInput, setCuisineInput] = useState("");
  const [specialtyInput, setSpecialtyInput] = useState("");
  
  // Food-specific services
  const [services, setServices] = useState({
    dineInAvailable: false,
    deliveryAvailable: false,
    takeoutAvailable: false,
    cateringAvailable: false,
  });

  const handleCategoryChange = (e) => {
    const cat = e.target.value;
    setForm((prev) => ({
      ...prev,
      category: cat,
      propertyType: cat === "Accommodation" ? "Apartment" : "",
      subCategory: cat === "Food" ? "Restaurant" : "",
      price: cat === "Food" ? "$$" : prev.price,
    }));
  };

  const [selectedAmenities, setSelectedAmenities] = useState([]);
  const [customAmenity, setCustomAmenity] = useState("");
  const [images, setImages] = useState([]);
  const [previews, setPreviews] = useState([]);
  const [submitting, setSubmitting] = useState(false);

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setForm({ ...form, [name]: type === 'checkbox' ? checked : value });
  };

  const handleServiceChange = (e) => {
    const { name, checked } = e.target;
    setServices({ ...services, [name]: checked });
  };

  const handleAddCuisine = (e) => {
    e.preventDefault();
    if (cuisineInput.trim() && !cuisine.includes(cuisineInput.trim())) {
      setCuisine([...cuisine, cuisineInput.trim()]);
      setCuisineInput("");
    }
  };

  const handleRemoveCuisine = (item) => {
    setCuisine(cuisine.filter(c => c !== item));
  };

  const handleAddSpecialty = (e) => {
    e.preventDefault();
    if (specialtyInput.trim() && !specialties.includes(specialtyInput.trim())) {
      setSpecialties([...specialties, specialtyInput.trim()]);
      setSpecialtyInput("");
    }
  };

  const handleRemoveSpecialty = (item) => {
    setSpecialties(specialties.filter(s => s !== item));
  };

  const toggleAmenity = (amenity) => {
    setSelectedAmenities((prev) =>
      prev.includes(amenity)
        ? prev.filter((a) => a !== amenity)
        : [...prev, amenity]
    );
  };

  const addCustomAmenity = () => {
    const trimmed = customAmenity.trim();
    if (trimmed && !selectedAmenities.includes(trimmed)) {
      setSelectedAmenities([...selectedAmenities, trimmed]);
      setCustomAmenity("");
    }
  };

  const handleImageUpload = (e) => {
    const files = Array.from(e.target.files).filter((f) =>
      ["image/png", "image/jpeg", "image/jpg"].includes(f.type)
    );
    if (files.length !== e.target.files.length) {
      alert("Only JPG, JPEG, and PNG files are allowed.");
    }
    setImages(files);
    setPreviews(files.map((f) => URL.createObjectURL(f)));
    e.target.value = "";
  };

  const removeImage = (idx) => {
    setImages((prev) => prev.filter((_, i) => i !== idx));
    setPreviews((prev) => prev.filter((_, i) => i !== idx));
  };

  const validate = () => {
    if (!form.title.trim()) return "Title/Name is required";
    if (form.category === "Food") {
      if (!form.address.trim()) return "Address is required";
      if (!form.city.trim()) return "City is required";
      if (!form.contact.trim()) return "Phone is required";
    } else {
      if (!form.location.trim()) return "Location is required";
      if (!form.contact.trim()) return "Contact is required";
      if (!form.price.trim()) return "Price is required";
    }
    if (!form.description.trim()) return "Description is required";
    return null;
  };

  const toBase64 = (file) =>
    new Promise((resolve, reject) => {
      const r = new FileReader();
      r.onloadend = () => resolve(r.result);
      r.onerror = reject;
      r.readAsDataURL(file);
    });

  const handleSubmit = async () => {
    const err = validate();
    if (err) { alert(err); return; }

    setSubmitting(true);
    try {
      const token = localStorage.getItem("adminToken");

      // Convert image files to base64 so we can send JSON
      const base64Images = await Promise.all(images.map(toBase64));

      let payload, endpoint;

      if (form.category === "Food") {
        // Food-specific payload
        endpoint = `${BASE}/api/food/admin`;
        payload = {
          title: form.title.trim(),
          category: "Food",
          subCategory: form.subCategory,
          type: form.type.trim() || undefined,
          address: form.address.trim(),
          city: form.city.trim(),
          state: form.state.trim() || undefined,
          zipCode: form.zipCode.trim() || undefined,
          location: form.city.trim() + ", " + form.address.trim(),
          phone: form.contact.trim(),
          email: form.email.trim() || undefined,
          website: form.website.trim() || undefined,
          description: form.description.trim(),
          openingHours: form.openingHours.trim() || undefined,
          priceRange: form.price.trim() || undefined,
          cuisine: cuisine.length > 0 ? cuisine : undefined,
          specialties: specialties.length > 0 ? specialties : undefined,
          dineInAvailable: services.dineInAvailable,
          deliveryAvailable: services.deliveryAvailable,
          takeoutAvailable: services.takeoutAvailable,
          cateringAvailable: services.cateringAvailable,
          status: form.status, // Keep capitalized: Active/Pending/Inactive
          image: form.image.trim() || base64Images[0] || undefined,
        };
      } else {
        // Accommodation payload
        endpoint = `${BASE}/api/accommodation/admin`;
        payload = {
          title: form.title.trim(),
          city: form.location.trim(),
          propertyType: form.propertyType || undefined,
          contactPhone: form.contact.trim(),
          description: form.description.trim(),
          status: form.status.toLowerCase(),
          rentDetails: { warmRent: parseFloat(form.price) || 0 },
          amenities: selectedAmenities.reduce((acc, a) => {
            const key = a.toLowerCase().replace(/\s+/g, "_");
            acc[key] = true;
            return acc;
          }, {}),
          media: { images: base64Images },
          adminControls: { isActive: form.status.toLowerCase() === "active" },
        };
      }

      const res = await fetch(endpoint, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(payload),
      });

      if (res.ok) {
        onSuccess && onSuccess();
        onClose();
      } else {
        const data = await res.json().catch(() => ({}));
        alert("Error: " + (data.message || "Failed to create listing"));
      }
    } catch (ex) {
      alert("Error connecting to server: " + ex.message);
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="modal-overlay">
      <div
        className="modal-content modal-large"
        style={{ maxHeight: "90vh", overflowY: "auto" }}
      >
        {/* Header */}
        <div className="modal-header">
          <h2>Add New Listing</h2>
          <button className="close-btn" onClick={onClose}>
            <X size={22} />
          </button>
        </div>

        <div className="add-listing-form">
          {/* ACCOMMODATION FIELDS */}
          {form.category === "Accommodation" && (
            <>
              {/* Row 1: Title + Category */}
              <div className="form-row">
                <div className="form-group">
                  <label>
                    Title <span style={{ color: "red" }}>*</span>
                  </label>
                  <input
                    name="title"
                    placeholder="Room"
                    value={form.title}
                    onChange={handleChange}
                  />
                </div>
                <div className="form-group">
                  <label>Category</label>
                  <select name="category" value={form.category} onChange={handleCategoryChange}>
                    <option>Accommodation</option>
                    <option>Food</option>
                    <option>Jobs</option>
                    <option>Services</option>
                  </select>
                </div>
              </div>

              {/* Property Type */}
              <div className="form-row">
                <div className="form-group">
                  <label>
                    Property Type <span style={{ color: "red" }}>*</span>
                  </label>
                  <select name="propertyType" value={form.propertyType} onChange={handleChange}>
                    <option value="Apartment">Apartment</option>
                    <option value="Shared Room">Shared Room</option>
                    <option value="Temporary Stays">Temporary Stays</option>
                  </select>
                </div>
              </div>

              {/* Row 2: Location + Contact */}
              <div className="form-row">
                <div className="form-group">
                  <label>
                    Location <span style={{ color: "red" }}>*</span>
                  </label>
                  <input
                    name="location"
                    placeholder="Munich"
                    value={form.location}
                    onChange={handleChange}
                  />
                </div>
                <div className="form-group">
                  <label>
                    Contact <span style={{ color: "red" }}>*</span>
                  </label>
                  <input
                    name="contact"
                    placeholder="+49 52148 765397"
                    value={form.contact}
                    onChange={handleChange}
                  />
                </div>
              </div>

              {/* Description */}
              <div className="form-group">
                <label>
                  Description <span style={{ color: "red" }}>*</span>
                </label>
                <textarea
                  name="description"
                  rows={3}
                  placeholder="Enter Description"
                  value={form.description}
                  onChange={handleChange}
                />
              </div>

              {/* Row 3: Price + Status */}
              <div className="form-row">
                <div className="form-group">
                  <label>
                    Price <span style={{ color: "red" }}>*</span>
                  </label>
                  <input
                    name="price"
                    placeholder="€1,000/month"
                    value={form.price}
                    onChange={handleChange}
                  />
                </div>
                <div className="form-group">
                  <label>Status</label>
                  <select name="status" value={form.status} onChange={handleChange}>
                    <option value="Active">Active</option>
                    <option value="Pending">Pending</option>
                    <option value="Inactive">Inactive</option>
                  </select>
                </div>
              </div>

              {/* Amenities */}
              <div className="form-group">
                <label>Amenities</label>
                <p style={{ fontSize: 12, color: "#6b7280", marginBottom: 8, marginTop: 0 }}>
                  Enter any Amenities or Choose Below
                </p>
                <div style={{ display: "flex", flexWrap: "wrap", gap: 8, marginBottom: 10 }}>
                  {[...DEFAULT_AMENITIES, ...selectedAmenities.filter(
                    (a) => !DEFAULT_AMENITIES.includes(a)
                  )].map((amenity) => (
                    <button
                      key={amenity}
                      type="button"
                      onClick={() => toggleAmenity(amenity)}
                      style={{
                        padding: "5px 14px",
                        borderRadius: 20,
                        fontSize: 13,
                        cursor: "pointer",
                        border: "1px solid #6b9976",
                        background: selectedAmenities.includes(amenity) ? "#6b9976" : "#fff",
                        color: selectedAmenities.includes(amenity) ? "#fff" : "#374151",
                        fontWeight: 500,
                      }}
                    >
                      {amenity}
                    </button>
                  ))}
                </div>
                <div style={{ display: "flex", gap: 8 }}>
                  <input
                    placeholder="Type custom amenity…"
                    value={customAmenity}
                    onChange={(e) => setCustomAmenity(e.target.value)}
                    onKeyDown={(e) => {
                      if (e.key === "Enter") { e.preventDefault(); addCustomAmenity(); }
                    }}
                    style={{ flex: 1 }}
                  />
                  <button
                    type="button"
                    onClick={addCustomAmenity}
                    style={{
                      padding: "7px 14px",
                      background: "#6b9976",
                      color: "#fff",
                      border: "none",
                      borderRadius: 6,
                      cursor: "pointer",
                      fontWeight: 600,
                    }}
                  >
                    Add
                  </button>
                </div>
              </div>

              {/* Image Upload */}
              <div className="form-group">
                <label>
                  Photos{" "}
                  <span style={{ color: "#6b7280", fontSize: 12 }}>
                    (JPG, JPEG, PNG)
                  </span>
                </label>
                <input
                  type="file"
                  multiple
                  accept=".png,.jpg,.jpeg,image/jpeg,image/png"
                  onChange={handleImageUpload}
                />
                {previews.length > 0 && (
                  <div style={{ display: "flex", flexWrap: "wrap", gap: 8, marginTop: 8 }}>
                    {previews.map((src, i) => (
                      <div key={i} style={{ position: "relative" }}>
                        <img
                          src={src}
                          alt={`preview-${i}`}
                          style={{
                            width: 80,
                            height: 65,
                            objectFit: "cover",
                            borderRadius: 6,
                            border: "2px solid #6b9976",
                          }}
                        />
                        <button
                          type="button"
                          onClick={() => removeImage(i)}
                          style={{
                            position: "absolute",
                            top: -6,
                            right: -6,
                            background: "#ef4444",
                            color: "#fff",
                            border: "none",
                            borderRadius: "50%",
                            width: 18,
                            height: 18,
                            fontSize: 11,
                            cursor: "pointer",
                            padding: 0,
                            lineHeight: "18px",
                            textAlign: "center",
                          }}
                        >
                          ✕
                        </button>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </>
          )}

          {/* FOOD FIELDS */}
          {form.category === "Food" && (
            <>
              {/* Basic Information */}
              <div className="form-section">
                <h3 className="section-title">Basic Information</h3>
                
                <div className="form-row">
                  <div className="form-group">
                    <label>
                      Name <span style={{ color: "red" }}>*</span>
                    </label>
                    <input
                      name="title"
                      placeholder="Restaurant or Grocery Store name"
                      value={form.title}
                      onChange={handleChange}
                    />
                  </div>
                  <div className="form-group">
                    <label>
                      Category <span style={{ color: "red" }}>*</span>
                    </label>
                    <select name="category" value={form.category} onChange={handleCategoryChange}>
                      <option>Accommodation</option>
                      <option>Food</option>
                      <option>Jobs</option>
                      <option>Services</option>
                    </select>
                  </div>
                </div>

                <div className="form-row">
                  <div className="form-group">
                    <label>SubCategory</label>
                    <select name="subCategory" value={form.subCategory} onChange={handleChange}>
                      <option value="Restaurant">Restaurant</option>
                      <option value="Cafe">Cafe</option>
                      <option value="Grocery Store">Grocery Store</option>
                      <option value="Bakery">Bakery</option>
                      <option value="Supermarket">Supermarket</option>
                    </select>
                  </div>
                  <div className="form-group">
                    <label>Type</label>
                    <input
                      name="type"
                      placeholder="e.g., Indian, Italian, Organic, Veg/Non-Veg"
                      value={form.type}
                      onChange={handleChange}
                    />
                  </div>
                </div>

                <div className="form-group">
                  <label>Price Range</label>
                  <select name="price" value={form.price} onChange={handleChange}>
                    <option value="$">$ - Budget Friendly</option>
                    <option value="$$">$$ - Moderate</option>
                    <option value="$$$">$$$ - Expensive</option>
                    <option value="$$$$">$$$$ - Very Expensive</option>
                  </select>
                </div>
              </div>

              {/* Location Details */}
              <div className="form-section">
                <h3 className="section-title">Location Details</h3>
                
                <div className="form-group">
                  <label>
                    Address <span style={{ color: "red" }}>*</span>
                  </label>
                  <input
                    name="address"
                    placeholder="Street address"
                    value={form.address}
                    onChange={handleChange}
                  />
                </div>

                <div className="form-row">
                  <div className="form-group">
                    <label>
                      City <span style={{ color: "red" }}>*</span>
                    </label>
                    <input
                      name="city"
                      placeholder="Munich"
                      value={form.city}
                      onChange={handleChange}
                    />
                  </div>
                  <div className="form-group">
                    <label>State/Region</label>
                    <input
                      name="state"
                      placeholder="Bavaria"
                      value={form.state}
                      onChange={handleChange}
                    />
                  </div>
                  <div className="form-group">
                    <label>Zip Code</label>
                    <input
                      name="zipCode"
                      placeholder="80331"
                      value={form.zipCode}
                      onChange={handleChange}
                    />
                  </div>
                </div>
              </div>

              {/* Contact Information */}
              <div className="form-section">
                <h3 className="section-title">Contact Information</h3>
                
                <div className="form-row">
                  <div className="form-group">
                    <label>Phone</label>
                    <input
                      name="contact"
                      type="tel"
                      placeholder="+49 123 456 7890"
                      value={form.contact}
                      onChange={handleChange}
                    />
                  </div>
                  <div className="form-group">
                    <label>Email</label>
                    <input
                      name="email"
                      type="email"
                      placeholder="contact@restaurant.com"
                      value={form.email}
                      onChange={handleChange}
                    />
                  </div>
                </div>

                <div className="form-group">
                  <label>Website</label>
                  <input
                    name="website"
                    type="url"
                    placeholder="https://www.restaurant.com"
                    value={form.website}
                    onChange={handleChange}
                  />
                </div>
              </div>

              {/* Details */}
              <div className="form-section">
                <h3 className="section-title">Details</h3>
                
                <div className="form-group">
                  <label>Description</label>
                  <textarea
                    name="description"
                    placeholder="Enter a detailed description..."
                    value={form.description}
                    onChange={handleChange}
                    rows={4}
                  />
                </div>

                <div className="form-group">
                  <label>Opening Hours</label>
                  <input
                    name="openingHours"
                    type="text"
                    placeholder="e.g., Mon-Fri: 9:00 AM - 10:00 PM, Sat-Sun: 10:00 AM - 11:00 PM"
                    value={form.openingHours}
                    onChange={handleChange}
                  />
                </div>
              </div>

              {/* Cuisine & Specialties */}
              <div className="form-section">
                <h3 className="section-title">Cuisine & Specialties</h3>
                
                <div className="form-group">
                  <label>Cuisine Types</label>
                  <div className="tag-input-container">
                    <input
                      type="text"
                      placeholder="Add cuisine type (e.g., Indian, Italian)"
                      value={cuisineInput}
                      onChange={(e) => setCuisineInput(e.target.value)}
                      onKeyPress={(e) => e.key === 'Enter' && handleAddCuisine(e)}
                    />
                    <button 
                      type="button" 
                      className="add-tag-btn"
                      onClick={handleAddCuisine}
                    >
                      Add
                    </button>
                  </div>
                  <div className="tags-list">
                    {cuisine.map((item, idx) => (
                      <span key={idx} className="tag">
                        {item}
                        <button 
                          type="button"
                          onClick={() => handleRemoveCuisine(item)}
                        >
                          ×
                        </button>
                      </span>
                    ))}
                  </div>
                </div>

                <div className="form-group">
                  <label>Specialties</label>
                  <div className="tag-input-container">
                    <input
                      type="text"
                      placeholder="Add specialty item"
                      value={specialtyInput}
                      onChange={(e) => setSpecialtyInput(e.target.value)}
                      onKeyPress={(e) => e.key === 'Enter' && handleAddSpecialty(e)}
                    />
                    <button 
                      type="button" 
                      className="add-tag-btn"
                      onClick={handleAddSpecialty}
                    >
                      Add
                    </button>
                  </div>
                  <div className="tags-list">
                    {specialties.map((item, idx) => (
                      <span key={idx} className="tag">
                        {item}
                        <button 
                          type="button"
                          onClick={() => handleRemoveSpecialty(item)}
                        >
                          ×
                        </button>
                      </span>
                    ))}
                  </div>
                </div>
              </div>

              {/* Services Available */}
              <div className="form-section">
                <h3 className="section-title">Services Available</h3>
                
                <div className="checkbox-group">
                  <label className="checkbox-label">
                    <input
                      type="checkbox"
                      name="dineInAvailable"
                      checked={services.dineInAvailable}
                      onChange={handleServiceChange}
                    />
                    <span>Dine-in</span>
                  </label>
                  <label className="checkbox-label">
                    <input
                      type="checkbox"
                      name="deliveryAvailable"
                      checked={services.deliveryAvailable}
                      onChange={handleServiceChange}
                    />
                    <span>Home Delivery</span>
                  </label>
                  <label className="checkbox-label">
                    <input
                      type="checkbox"
                      name="takeoutAvailable"
                      checked={services.takeoutAvailable}
                      onChange={handleServiceChange}
                    />
                    <span>Takeout</span>
                  </label>
                  <label className="checkbox-label">
                    <input
                      type="checkbox"
                      name="cateringAvailable"
                      checked={services.cateringAvailable}
                      onChange={handleServiceChange}
                    />
                    <span>Catering</span>
                  </label>
                </div>
              </div>

              {/* Image */}
              <div className="form-section">
                <h3 className="section-title">Image</h3>
                
                <div className="form-group">
                  <label>Image URL</label>
                  <input
                    name="image"
                    type="url"
                    placeholder="https://example.com/image.jpg"
                    value={form.image}
                    onChange={handleChange}
                  />
                  <p className="form-help">Enter the URL of the restaurant/store image</p>
                  {form.image && (
                    <div className="image-preview">
                      <img src={form.image} alt="Preview" style={{ maxWidth: '200px', marginTop: '10px', borderRadius: '8px' }} />
                    </div>
                  )}
                </div>
              </div>
            </>
          )}

          {/* OTHER CATEGORIES - Jobs, Services */}
          {(form.category === "Jobs" || form.category === "Services") && (
            <>
              {/* Row 1: Title + Category */}
              <div className="form-row">
                <div className="form-group">
                  <label>
                    Title <span style={{ color: "red" }}>*</span>
                  </label>
                  <input
                    name="title"
                    placeholder="Title"
                    value={form.title}
                    onChange={handleChange}
                  />
                </div>
                <div className="form-group">
                  <label>Category</label>
                  <select name="category" value={form.category} onChange={handleCategoryChange}>
                    <option>Accommodation</option>
                    <option>Food</option>
                    <option>Jobs</option>
                    <option>Services</option>
                  </select>
                </div>
              </div>

              {/* Row 2: Location + Contact */}
              <div className="form-row">
                <div className="form-group">
                  <label>
                    Location <span style={{ color: "red" }}>*</span>
                  </label>
                  <input
                    name="location"
                    placeholder="Munich"
                    value={form.location}
                    onChange={handleChange}
                  />
                </div>
                <div className="form-group">
                  <label>
                    Contact <span style={{ color: "red" }}>*</span>
                  </label>
                  <input
                    name="contact"
                    placeholder="+49 52148 765397"
                    value={form.contact}
                    onChange={handleChange}
                  />
                </div>
              </div>

              {/* Description */}
              <div className="form-group">
                <label>
                  Description <span style={{ color: "red" }}>*</span>
                </label>
                <textarea
                  name="description"
                  rows={3}
                  placeholder="Enter Description"
                  value={form.description}
                  onChange={handleChange}
                />
              </div>

              {/* Row 3: Price + Status */}
              <div className="form-row">
                <div className="form-group">
                  <label>
                    Price <span style={{ color: "red" }}>*</span>
                  </label>
                  <input
                    name="price"
                    placeholder="Price"
                    value={form.price}
                    onChange={handleChange}
                  />
                </div>
                <div className="form-group">
                  <label>Status</label>
                  <select name="status" value={form.status} onChange={handleChange}>
                    <option value="Active">Active</option>
                    <option value="Pending">Pending</option>
                    <option value="Inactive">Inactive</option>
                  </select>
                </div>
              </div>
            </>
          )}

          {/* Actions */}
          <div className="form-actions">
            <button
              type="button"
              className="cancel-btn"
              onClick={onClose}
              disabled={submitting}
            >
              Cancel
            </button>
            <button
              type="button"
              className="create-btn"
              onClick={handleSubmit}
              disabled={submitting}
            >
              {submitting ? "Creating…" : "Create"}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default SimpleAddListingModal;
