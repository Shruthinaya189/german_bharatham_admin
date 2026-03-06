import axios from "axios";
import React, { useEffect, useMemo, useState } from "react";

const BASE = "http://localhost:5000";

const DEFAULT_AMENITIES = ["WiFi", "Parking", "Balcony", "Garden", "Elevator"];

const normalizeCategory = (value) => {
  if (!value) return "Accommodation";
  if (value === "Jobs") return "Job";
  if (value === "Job") return "Job";
  if (value === "Food") return "Food";
  if (value === "Accommodation") return "Accommodation";
  if (value === "Services") return "Services";
  return "Accommodation";
};

const AddListingModal = ({ onClose, refreshJobs, editJob, refreshDashboard, defaultCategory, onSuccess }) => {
  const [formData, setFormData] = useState({
    title: "",
    category: normalizeCategory(defaultCategory),
    location: "",
    description: "",
    contact: "",
    price: "",
    status: "Active",
    amenities: "",

    companyName: "",
    companyLogo: "",
    jobType: "Full Time",
    requirements: "",
    benefits: "",
    applyUrl: "",

    propertyType: "Apartment",

    foodSubCategory: "Restaurant",
    foodType: "",
    foodAddress: "",
    foodCity: "",
    foodState: "",
    foodZipCode: "",
    foodPhone: "",
    foodEmail: "",
    foodWebsite: "",
    foodOpeningHours: "",
    foodPriceRange: "$$",
    foodImageUrl: "",
    deliveryAvailable: false,
    takeoutAvailable: false,
    dineInAvailable: false,
    cateringAvailable: false,
  });

  const [logoFile, setLogoFile] = useState(null);
  const [logoPreview, setLogoPreview] = useState("");

  const [accommodationImages, setAccommodationImages] = useState([]);
  const [accommodationPreviews, setAccommodationPreviews] = useState([]);
  const [customAmenity, setCustomAmenity] = useState("");

  const [cuisineInput, setCuisineInput] = useState("");
  const [specialtyInput, setSpecialtyInput] = useState("");
  const [cuisineList, setCuisineList] = useState([]);
  const [specialtiesList, setSpecialtiesList] = useState([]);

  useEffect(() => {
    if (!editJob && defaultCategory) {
      setFormData((prev) => ({ ...prev, category: normalizeCategory(defaultCategory) }));
    }
  }, [defaultCategory, editJob]);

  useEffect(() => {
    if (!editJob) return;

    const editCategory = normalizeCategory(editJob.category || "Job");
    setFormData((prev) => ({
      ...prev,
      title: editJob.title || "",
      category: editCategory,
      location: editJob.location || editJob.city || "",
      description: editJob.description || "",
      contact: editJob.contact || editJob.phone || "",
      price: editJob.salary || editJob.rent || editJob.price || "",
      status: editJob.status || "Active",
      amenities: Array.isArray(editJob.amenities)
        ? editJob.amenities.join(", ")
        : prev.amenities,
      companyName: editJob.companyName || "",
      companyLogo: editJob.companyLogo || "",
      jobType: editJob.jobType || "Full Time",
      requirements: editJob.requirements || "",
      benefits: editJob.benefits || "",
      applyUrl: editJob.applyUrl || "",
      propertyType: editJob.type || "Apartment",
      foodSubCategory: editJob.subCategory || "Restaurant",
      foodType: editJob.type || "",
      foodAddress: editJob.address || "",
      foodCity: editJob.city || "",
      foodState: editJob.state || "",
      foodZipCode: editJob.zipCode || "",
      foodPhone: editJob.phone || "",
      foodEmail: editJob.email || "",
      foodWebsite: editJob.website || "",
      foodOpeningHours: editJob.openingHours || "",
      foodPriceRange: editJob.priceRange || "$$",
      foodImageUrl: editJob.image || "",
      deliveryAvailable: !!editJob.deliveryAvailable,
      takeoutAvailable: !!editJob.takeoutAvailable,
      dineInAvailable: !!editJob.dineInAvailable,
      cateringAvailable: !!editJob.cateringAvailable,
    }));

    if (editJob.companyLogo) {
      setLogoPreview(
        editJob.companyLogo.startsWith("http")
          ? editJob.companyLogo
          : `${BASE}${editJob.companyLogo}`
      );
    }

    if (Array.isArray(editJob.cuisine)) setCuisineList(editJob.cuisine);
    if (Array.isArray(editJob.specialties)) setSpecialtiesList(editJob.specialties);
  }, [editJob]);

  const selectedAmenities = useMemo(
    () => formData.amenities.split(",").map((x) => x.trim()).filter(Boolean),
    [formData.amenities]
  );

  const allAmenities = useMemo(() => {
    const extra = selectedAmenities.filter((a) => !DEFAULT_AMENITIES.includes(a));
    return [...DEFAULT_AMENITIES, ...extra];
  }, [selectedAmenities]);

  const toBase64 = (file) =>
    new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onloadend = () => resolve(reader.result);
      reader.onerror = reject;
      reader.readAsDataURL(file);
    });

  const handleLogoChange = (e) => {
    const file = e.target.files[0];
    if (!file) return;
    setLogoFile(file);
    const reader = new FileReader();
    reader.onloadend = () => setLogoPreview(reader.result);
    reader.readAsDataURL(file);
  };

  const handleAmenityToggle = (amenity) => {
    let next = [...selectedAmenities];
    if (next.includes(amenity)) next = next.filter((a) => a !== amenity);
    else next.push(amenity);
    setFormData((p) => ({ ...p, amenities: next.join(", ") }));
  };

  const handleAddCustomAmenity = () => {
    const t = customAmenity.trim();
    if (!t) return;
    if (!selectedAmenities.includes(t)) {
      const next = [...selectedAmenities, t];
      setFormData((p) => ({ ...p, amenities: next.join(", ") }));
    }
    setCustomAmenity("");
  };

  const handleAccommodationImages = (e) => {
    const files = Array.from(e.target.files || []).filter((f) =>
      ["image/png", "image/jpeg", "image/jpg"].includes(f.type)
    );
    setAccommodationImages(files);
    setAccommodationPreviews(files.map((f) => URL.createObjectURL(f)));
    e.target.value = "";
  };

  const removeAccommodationImage = (idx) => {
    setAccommodationImages((p) => p.filter((_, i) => i !== idx));
    setAccommodationPreviews((p) => p.filter((_, i) => i !== idx));
  };

  const addCuisine = () => {
    const t = cuisineInput.trim();
    if (!t || cuisineList.includes(t)) return;
    setCuisineList((p) => [...p, t]);
    setCuisineInput("");
  };

  const addSpecialty = () => {
    const t = specialtyInput.trim();
    if (!t || specialtiesList.includes(t)) return;
    setSpecialtiesList((p) => [...p, t]);
    setSpecialtyInput("");
  };

  const submitJob = async () => {
    const payload = new FormData();
    payload.append("title", formData.title);
    payload.append("category", "Job");
    payload.append("companyName", formData.companyName);
    payload.append("location", formData.location);
    payload.append("contact", formData.contact);
    payload.append("description", formData.description);
    payload.append("salary", formData.price);
    payload.append("status", formData.status);
    payload.append("jobType", formData.jobType);
    payload.append("requirements", formData.requirements);
    payload.append("benefits", formData.benefits);
    payload.append("applyUrl", formData.applyUrl);
    if (logoFile) payload.append("logo", logoFile);

    if (editJob && editJob._id) {
      await axios.put(`${BASE}/api/admin/jobs/${editJob._id}`, payload);
      alert("Job Updated Successfully");
    } else {
      await axios.post(`${BASE}/api/admin/jobs`, payload);
      alert("Job Created Successfully");
    }
  };

  const submitAccommodation = async () => {
    const token = localStorage.getItem("adminToken");
    const status = ["Active", "Pending", "Inactive"].includes(formData.status)
      ? formData.status
      : "Pending";

    const firstImage = accommodationImages[0] ? await toBase64(accommodationImages[0]) : "";

    const payload = {
      title: formData.title.trim(),
      category: "Accommodation",
      type: formData.propertyType,
      address: formData.location.trim(),
      city: formData.location.trim(),
      phone: formData.contact.trim(),
      description: formData.description.trim(),
      rent: Number(String(formData.price).replace(/[^0-9.]/g, "")) || 0,
      status,
      furnished: selectedAmenities.includes("Furnished"),
      petsAllowed: selectedAmenities.includes("Pets Allowed"),
      parkingAvailable: selectedAmenities.includes("Parking"),
      image: firstImage,
    };

    const endpoint = editJob && editJob._id
      ? `${BASE}/api/accommodation/admin/${editJob._id}`
      : `${BASE}/api/accommodation/admin`;
    const method = editJob && editJob._id ? "PUT" : "POST";

    const res = await fetch(endpoint, {
      method,
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify(payload),
    });

    if (!res.ok) {
      const err = await res.json().catch(() => ({}));
      throw new Error(err.message || "Failed to save accommodation");
    }

    alert(editJob ? "Accommodation Updated Successfully" : "Accommodation Created Successfully");
  };

  const submitFood = async () => {
    const token = localStorage.getItem("adminToken");

    const payload = {
      title: formData.title.trim(),
      category: "Food",
      subCategory: formData.foodSubCategory,
      type: formData.foodType,
      address: formData.foodAddress.trim(),
      city: formData.foodCity.trim(),
      state: formData.foodState.trim(),
      zipCode: formData.foodZipCode.trim(),
      location: `${formData.foodCity.trim()}, ${formData.foodAddress.trim()}`,
      phone: formData.foodPhone.trim(),
      email: formData.foodEmail.trim(),
      website: formData.foodWebsite.trim(),
      description: formData.description.trim(),
      openingHours: formData.foodOpeningHours.trim(),
      priceRange: formData.foodPriceRange,
      cuisine: cuisineList,
      specialties: specialtiesList,
      deliveryAvailable: formData.deliveryAvailable,
      takeoutAvailable: formData.takeoutAvailable,
      dineInAvailable: formData.dineInAvailable,
      cateringAvailable: formData.cateringAvailable,
      image: formData.foodImageUrl.trim(),
      status: formData.status,
      verified: true,
    };

    const endpoint = editJob && editJob._id
      ? `${BASE}/api/food/admin/${editJob._id}`
      : `${BASE}/api/food/admin`;
    const method = editJob && editJob._id ? "PUT" : "POST";

    const res = await fetch(endpoint, {
      method,
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify(payload),
    });

    if (!res.ok) {
      const err = await res.json().catch(() => ({}));
      throw new Error(err.message || "Failed to save food listing");
    }

    alert(editJob ? "Food Listing Updated Successfully" : "Food Listing Created Successfully");
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      if (formData.category === "Job") {
        await submitJob();
      } else if (formData.category === "Accommodation") {
        await submitAccommodation();
      } else if (formData.category === "Food") {
        await submitFood();
      } else {
        alert("Services form stays the same and is not integrated yet.");
      }

      if (refreshJobs) refreshJobs();
      if (refreshDashboard) refreshDashboard();
      if (onSuccess) onSuccess();
      onClose();
    } catch (error) {
      alert("Something went wrong: " + (error.response?.data?.message || error.message));
    }
  };

  return (
    <div className="modal-overlay">
      <div className="modal-content" style={{ maxHeight: "90vh", overflowY: "auto" }}>
        <div className="modal-header">
          <h2>{editJob ? "Edit Listing" : "Add New Listing"}</h2>
          <button className="modal-close" onClick={onClose}>✕</button>
        </div>

        <form onSubmit={handleSubmit} className="add-listing-form">
          <div className="form-row">
            <div className="form-group">
              <label>Title</label>
              <input
                type="text"
                placeholder={formData.category === "Food" ? "Restaurant or Grocery Store name" : "Room"}
                value={formData.title}
                onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                required
              />
            </div>
            <div className="form-group">
              <label>Category</label>
              <select
                value={formData.category}
                onChange={(e) => setFormData({ ...formData, category: e.target.value })}
              >
                <option value="Accommodation">Accommodation</option>
                <option value="Food">Food</option>
                <option value="Services">Services</option>
                <option value="Job">Job</option>
              </select>
            </div>
          </div>

          {formData.category === "Accommodation" && (
            <>
              <div className="form-row">
                <div className="form-group">
                  <label>Property Type *</label>
                  <select
                    value={formData.propertyType}
                    onChange={(e) => setFormData({ ...formData, propertyType: e.target.value })}
                  >
                    <option value="Apartment">Apartment</option>
                    <option value="Shared Room">Shared Room</option>
                    <option value="Temporary Stays">Temporary Stays</option>
                  </select>
                </div>
                <div className="form-group">
                  <label>Location *</label>
                  <input
                    type="text"
                    placeholder="Munich"
                    value={formData.location}
                    onChange={(e) => setFormData({ ...formData, location: e.target.value })}
                    required
                  />
                </div>
              </div>

              <div className="form-row">
                <div className="form-group">
                  <label>Contact *</label>
                  <input
                    type="text"
                    placeholder="+49 52148 765397"
                    value={formData.contact}
                    onChange={(e) => setFormData({ ...formData, contact: e.target.value })}
                    required
                  />
                </div>
                <div className="form-group">
                  <label>Price *</label>
                  <input
                    type="text"
                    placeholder="€1,000/month"
                    value={formData.price}
                    onChange={(e) => setFormData({ ...formData, price: e.target.value })}
                    required
                  />
                </div>
              </div>

              <div className="form-group">
                <label>Description *</label>
                <textarea
                  rows="3"
                  placeholder="Enter Description"
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  required
                />
              </div>

              <div className="form-row">
                <div className="form-group">
                  <label>Status</label>
                  <select
                    value={formData.status}
                    onChange={(e) => setFormData({ ...formData, status: e.target.value })}
                  >
                    <option value="Active">Active</option>
                    <option value="Pending">Pending</option>
                    <option value="Inactive">Inactive</option>
                  </select>
                </div>
              </div>

              <div className="form-group">
                <label>Amenities</label>
                <p style={{ fontSize: 12, color: "#6b7280", margin: "0 0 8px" }}>
                  Enter any Amenities or Choose Below
                </p>
                <div style={{ display: "flex", flexWrap: "wrap", gap: 8, marginBottom: 10 }}>
                  {allAmenities.map((a) => (
                    <button
                      key={a}
                      type="button"
                      onClick={() => handleAmenityToggle(a)}
                      style={{
                        padding: "5px 14px",
                        borderRadius: 20,
                        fontSize: 13,
                        cursor: "pointer",
                        border: "1px solid #6b9976",
                        background: selectedAmenities.includes(a) ? "#6b9976" : "#fff",
                        color: selectedAmenities.includes(a) ? "#fff" : "#374151",
                        fontWeight: 500,
                      }}
                    >
                      {a}
                    </button>
                  ))}
                </div>
                <div style={{ display: "flex", gap: 8 }}>
                  <input
                    value={customAmenity}
                    onChange={(e) => setCustomAmenity(e.target.value)}
                    placeholder="Type custom amenity..."
                    style={{ flex: 1 }}
                  />
                  <button
                    type="button"
                    onClick={handleAddCustomAmenity}
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

              <div className="form-group">
                <label>Photos (JPG, JPEG, PNG - optional)</label>
                <input type="file" multiple accept=".png,.jpg,.jpeg,image/jpeg,image/png" onChange={handleAccommodationImages} />
                {accommodationPreviews.length > 0 && (
                  <div style={{ display: "flex", flexWrap: "wrap", gap: 8, marginTop: 8 }}>
                    {accommodationPreviews.map((src, i) => (
                      <div key={i} style={{ position: "relative" }}>
                        <img
                          src={src}
                          alt={`preview-${i}`}
                          style={{ width: 80, height: 65, objectFit: "cover", borderRadius: 6, border: "2px solid #6b9976" }}
                        />
                        <button
                          type="button"
                          onClick={() => removeAccommodationImage(i)}
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

          {formData.category === "Food" && (
            <>
              <div className="form-row">
                <div className="form-group">
                  <label>Category *</label>
                  <select
                    value={formData.foodSubCategory}
                    onChange={(e) => setFormData({ ...formData, foodSubCategory: e.target.value })}
                  >
                    <option value="Restaurant">Restaurant</option>
                    <option value="Grocery Store">Grocery Store</option>
                    <option value="Bakery">Bakery</option>
                    <option value="Cafe">Cafe</option>
                    <option value="Supermarket">Supermarket</option>
                    <option value="Food Truck">Food Truck</option>
                    <option value="Deli">Deli</option>
                  </select>
                </div>
                <div className="form-group">
                  <label>Type</label>
                  <input
                    type="text"
                    placeholder="e.g., Indian, Italian"
                    value={formData.foodType}
                    onChange={(e) => setFormData({ ...formData, foodType: e.target.value })}
                  />
                </div>
              </div>

              <div className="form-group">
                <label>Address *</label>
                <input
                  type="text"
                  placeholder="Street address"
                  value={formData.foodAddress}
                  onChange={(e) => setFormData({ ...formData, foodAddress: e.target.value })}
                  required
                />
              </div>

              <div className="form-row">
                <div className="form-group">
                  <label>City *</label>
                  <input
                    type="text"
                    placeholder="Munich"
                    value={formData.foodCity}
                    onChange={(e) => setFormData({ ...formData, foodCity: e.target.value })}
                    required
                  />
                </div>
                <div className="form-group">
                  <label>State/Region</label>
                  <input
                    type="text"
                    placeholder="Bavaria"
                    value={formData.foodState}
                    onChange={(e) => setFormData({ ...formData, foodState: e.target.value })}
                  />
                </div>
                <div className="form-group">
                  <label>Zip Code</label>
                  <input
                    type="text"
                    placeholder="80331"
                    value={formData.foodZipCode}
                    onChange={(e) => setFormData({ ...formData, foodZipCode: e.target.value })}
                  />
                </div>
              </div>

              <div className="form-row">
                <div className="form-group">
                  <label>Phone</label>
                  <input
                    type="text"
                    placeholder="+49 123 456 7890"
                    value={formData.foodPhone}
                    onChange={(e) => setFormData({ ...formData, foodPhone: e.target.value })}
                  />
                </div>
                <div className="form-group">
                  <label>Email</label>
                  <input
                    type="email"
                    placeholder="contact@restaurant.com"
                    value={formData.foodEmail}
                    onChange={(e) => setFormData({ ...formData, foodEmail: e.target.value })}
                  />
                </div>
              </div>

              <div className="form-group">
                <label>Website</label>
                <input
                  type="url"
                  placeholder="https://www.restaurant.com"
                  value={formData.foodWebsite}
                  onChange={(e) => setFormData({ ...formData, foodWebsite: e.target.value })}
                />
              </div>

              <div className="form-group">
                <label>Description</label>
                <textarea
                  rows="3"
                  placeholder="Enter a detailed description..."
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                />
              </div>

              <div className="form-row">
                <div className="form-group">
                  <label>Opening Hours</label>
                  <input
                    type="text"
                    placeholder="e.g., Mon-Fri: 9:00 AM - 10:00 PM"
                    value={formData.foodOpeningHours}
                    onChange={(e) => setFormData({ ...formData, foodOpeningHours: e.target.value })}
                  />
                </div>
                <div className="form-group">
                  <label>Price Range</label>
                  <select
                    value={formData.foodPriceRange}
                    onChange={(e) => setFormData({ ...formData, foodPriceRange: e.target.value })}
                  >
                    <option value="$">$ - Budget Friendly</option>
                    <option value="$$">$$ - Moderate</option>
                    <option value="$$$">$$$ - Expensive</option>
                    <option value="$$$$">$$$$ - Very Expensive</option>
                  </select>
                </div>
              </div>

              <div className="form-group">
                <label>Cuisine Types</label>
                <div style={{ display: "flex", gap: 8 }}>
                  <input
                    value={cuisineInput}
                    onChange={(e) => setCuisineInput(e.target.value)}
                    placeholder="Add cuisine type"
                    style={{ flex: 1 }}
                  />
                  <button type="button" className="create-btn" onClick={addCuisine}>Add</button>
                </div>
                {cuisineList.length > 0 && (
                  <div style={{ display: "flex", flexWrap: "wrap", gap: 8, marginTop: 8 }}>
                    {cuisineList.map((c) => (
                      <span key={c} className="amenity-btn selected" onClick={() => setCuisineList((p) => p.filter((x) => x !== c))}>
                        {c} ✕
                      </span>
                    ))}
                  </div>
                )}
              </div>

              <div className="form-group">
                <label>Specialties</label>
                <div style={{ display: "flex", gap: 8 }}>
                  <input
                    value={specialtyInput}
                    onChange={(e) => setSpecialtyInput(e.target.value)}
                    placeholder="Add specialty item"
                    style={{ flex: 1 }}
                  />
                  <button type="button" className="create-btn" onClick={addSpecialty}>Add</button>
                </div>
                {specialtiesList.length > 0 && (
                  <div style={{ display: "flex", flexWrap: "wrap", gap: 8, marginTop: 8 }}>
                    {specialtiesList.map((s) => (
                      <span key={s} className="amenity-btn selected" onClick={() => setSpecialtiesList((p) => p.filter((x) => x !== s))}>
                        {s} ✕
                      </span>
                    ))}
                  </div>
                )}
              </div>

              <div className="form-group">
                <label>Services Available</label>
                <div style={{ display: "grid", gridTemplateColumns: "repeat(2,minmax(0,1fr))", gap: 8 }}>
                  <label><input type="checkbox" checked={formData.dineInAvailable} onChange={(e) => setFormData({ ...formData, dineInAvailable: e.target.checked })} /> Dine-in</label>
                  <label><input type="checkbox" checked={formData.deliveryAvailable} onChange={(e) => setFormData({ ...formData, deliveryAvailable: e.target.checked })} /> Home Delivery</label>
                  <label><input type="checkbox" checked={formData.takeoutAvailable} onChange={(e) => setFormData({ ...formData, takeoutAvailable: e.target.checked })} /> Takeout</label>
                  <label><input type="checkbox" checked={formData.cateringAvailable} onChange={(e) => setFormData({ ...formData, cateringAvailable: e.target.checked })} /> Catering</label>
                </div>
              </div>

              <div className="form-group">
                <label>Image URL</label>
                <input
                  type="url"
                  placeholder="https://example.com/image.jpg"
                  value={formData.foodImageUrl}
                  onChange={(e) => setFormData({ ...formData, foodImageUrl: e.target.value })}
                />
              </div>

              <div className="form-row">
                <div className="form-group">
                  <label>Status</label>
                  <select
                    value={formData.status}
                    onChange={(e) => setFormData({ ...formData, status: e.target.value })}
                  >
                    <option value="Active">Active</option>
                    <option value="Pending">Pending</option>
                    <option value="Inactive">Inactive</option>
                  </select>
                </div>
              </div>
            </>
          )}

          {formData.category === "Job" && (
            <>
              <div className="form-row">
                <div className="form-group">
                  <label>Location</label>
                  <input
                    type="text"
                    placeholder="Munich"
                    value={formData.location}
                    onChange={(e) => setFormData({ ...formData, location: e.target.value })}
                    required
                  />
                </div>
                <div className="form-group">
                  <label>Contact</label>
                  <input
                    type="text"
                    placeholder="+49 52148 765397"
                    value={formData.contact}
                    onChange={(e) => setFormData({ ...formData, contact: e.target.value })}
                    required
                  />
                </div>
              </div>

              <div className="form-group">
                <label>Description</label>
                <textarea
                  placeholder="Enter Description"
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  rows="4"
                />
              </div>

              <div className="form-row">
                <div className="form-group">
                  <label>Salary</label>
                  <input
                    type="text"
                    placeholder="€3,000/month"
                    value={formData.price}
                    onChange={(e) => setFormData({ ...formData, price: e.target.value })}
                  />
                </div>
                <div className="form-group">
                  <label>Status</label>
                  <select
                    value={formData.status}
                    onChange={(e) => setFormData({ ...formData, status: e.target.value })}
                  >
                    <option value="Active">Active</option>
                    <option value="Pending">Pending</option>
                    <option value="Inactive">Inactive</option>
                  </select>
                </div>
              </div>

              <div className="form-row">
                <div className="form-group">
                  <label>Company Name</label>
                  <input
                    type="text"
                    placeholder="Company Name"
                    value={formData.companyName}
                    onChange={(e) => setFormData({ ...formData, companyName: e.target.value })}
                    required
                  />
                </div>
                <div className="form-group">
                  <label>Company Logo</label>
                  <input type="file" accept="image/*" onChange={handleLogoChange} />
                  {logoPreview && (
                    <div style={{ marginTop: "10px" }}>
                      <img
                        src={logoPreview}
                        alt="Logo Preview"
                        style={{
                          width: "100px",
                          height: "100px",
                          objectFit: "contain",
                          border: "1px solid #ddd",
                          borderRadius: "4px",
                          padding: "5px",
                        }}
                      />
                    </div>
                  )}
                </div>
              </div>

              <div className="form-row">
                <div className="form-group">
                  <label>Type</label>
                  <select
                    value={formData.jobType}
                    onChange={(e) => setFormData({ ...formData, jobType: e.target.value })}
                  >
                    <option value="Full Time">Full Time</option>
                    <option value="Part Time">Part Time</option>
                  </select>
                </div>
                <div className="form-group">
                  <label>Requirements</label>
                  <input
                    type="text"
                    placeholder="Required skills"
                    value={formData.requirements}
                    onChange={(e) => setFormData({ ...formData, requirements: e.target.value })}
                  />
                </div>
              </div>

              <div className="form-group">
                <label>Benefits</label>
                <input
                  type="text"
                  placeholder="Benefits"
                  value={formData.benefits}
                  onChange={(e) => setFormData({ ...formData, benefits: e.target.value })}
                />
              </div>

              <div className="form-group">
                <label>Apply URL</label>
                <input
                  type="text"
                  placeholder="https://company.com/apply"
                  value={formData.applyUrl}
                  onChange={(e) => setFormData({ ...formData, applyUrl: e.target.value })}
                />
              </div>
            </>
          )}

          {formData.category === "Services" && (
            <>
              <div className="form-row">
                <div className="form-group">
                  <label>Location</label>
                  <input
                    type="text"
                    placeholder="Munich"
                    value={formData.location}
                    onChange={(e) => setFormData({ ...formData, location: e.target.value })}
                  />
                </div>
                <div className="form-group">
                  <label>Contact</label>
                  <input
                    type="text"
                    placeholder="+49 52148 765397"
                    value={formData.contact}
                    onChange={(e) => setFormData({ ...formData, contact: e.target.value })}
                  />
                </div>
              </div>
              <div className="form-group">
                <label>Description</label>
                <textarea
                  placeholder="Enter Description"
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  rows="4"
                />
              </div>
              <div className="form-row">
                <div className="form-group">
                  <label>Price</label>
                  <input
                    type="text"
                    placeholder="€1,000/month"
                    value={formData.price}
                    onChange={(e) => setFormData({ ...formData, price: e.target.value })}
                  />
                </div>
                <div className="form-group">
                  <label>Status</label>
                  <select
                    value={formData.status}
                    onChange={(e) => setFormData({ ...formData, status: e.target.value })}
                  >
                    <option value="Active">Active</option>
                    <option value="Pending">Pending</option>
                    <option value="Inactive">Inactive</option>
                  </select>
                </div>
              </div>
            </>
          )}

          <div className="form-actions">
            <button type="button" className="cancel-btn" onClick={onClose}>
              Cancel
            </button>
            <button type="submit" className="create-btn">
              {editJob ? "Update" : "Create"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default AddListingModal;
