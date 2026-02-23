import React from 'react';
import { Plus, Edit, Trash2 } from 'lucide-react';

const Categories = () => {
  const categories = [
    {
      name: 'Accommodation',
      listings: '234 listings',
      description: 'Housing, apartments, student housing, and shared accommodations',
      status: 'Active',
      icon: '🏠'
    },
    {
      name: 'Food',
      listings: '42 listings',
      description: 'Indian grocery stores, restaurants, and food delivery services',
      status: 'Active',
      icon: '🍴'
    },
    {
      name: 'Services',
      listings: '7 listings',
      description: 'Immigration, legal, financial, and consultation services',
      status: 'Disabled',
      icon: '🔧'
    },
    {
      name: 'Jobs',
      listings: '19 listings',
      description: 'Job listings, career opportunities, and employment services',
      status: 'Active',
      icon: '💼'
    }
  ];

  return (
    <div className="categories">
      <div className="categories-header">
        <div>
          <h1>Categories</h1>
          <p>Manage your app's category structure.</p>
        </div>
        <div className="header-actions">
          <select className="filter-select">
            <option>All Categories</option>
            <option>Active</option>
            <option>Disabled</option>
          </select>
          <button className="add-category-btn">
            <Plus size={20} />
            New Category
          </button>
        </div>
      </div>

      <div className="categories-grid">
        {categories.map((category, index) => (
          <div key={index} className="category-card-large">
            <div className="category-header">
              <div className="category-icon-large">{category.icon}</div>
              <div className="category-meta">
                <h3>{category.name}</h3>
                <p className="category-listings">{category.listings}</p>
              </div>
              <div className="category-status">
                <span className={`status ${category.status.toLowerCase()}`}>
                  {category.status}
                </span>
              </div>
            </div>
            
            <p className="category-description">{category.description}</p>
            
            <div className="category-actions">
              <button className="action-btn edit-btn">
                <Edit size={16} />
              </button>
              <button className="action-btn delete-btn">
                <Trash2 size={16} />
                Delete
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default Categories;
