import React, { useState } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Login from './components/Login';
import Dashboard from './components/Dashboard';
import Listings from './components/Listings';
import JobListings from './components/JobsListings';
import Categories from './components/Categories';
import AccommodationListings from './components/AccommodationListings';
import FoodListings from './components/FoodListings';
import JobsListings from './components/JobsListings';
import ServicesListings from './components/ServicesListings';
import Users from './components/Users';
import CustomCategoryListings from './components/CustomCategoryListings';
import ContentModeration from './components/ContentModeration';
import Community from './components/Community';
import Settings from './components/Settings';
import Layout from './components/Layout';
import './App.css';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  const handleLogin = () => {
    setIsAuthenticated(true);
  };

  const handleLogout = () => {
    setIsAuthenticated(false);
  };

  if (!isAuthenticated) {
    return <Login onLogin={handleLogin} />;
  }

  return (
    <Router>
      <Layout onLogout={handleLogout}>
        <Routes>
          <Route path="/" element={<Navigate to="/dashboard" />} />
          <Route path="/dashboard" element={<Dashboard />} />
          <Route path="/listings" element={<Listings />} />
          <Route path="/job-listings" element={<JobListings />} />
          <Route path="/categories" element={<Categories />} />
          <Route path="/accommodation-listings" element={<AccommodationListings />} />
          <Route path="/food-listings" element={<FoodListings />} />
          <Route path="/jobs-listings" element={<JobsListings />} />
          <Route path="/services-listings" element={<ServicesListings />} />
          <Route path="/custom-category/:id" element={<CustomCategoryListings />} />
          <Route path="/users" element={<Users />} />
          <Route path="/content-moderation" element={<ContentModeration />} />
          <Route path="/community" element={<Community />} />
          <Route path="/settings" element={<Settings />} />
        </Routes>
      </Layout>
    </Router>
  );
}

export default App;
