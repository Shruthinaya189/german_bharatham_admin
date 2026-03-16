import React, { useState } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Login from './components/Login';
import Dashboard from './components/Dashboard';
import Listings from './components/Listings';
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
import Subscriptions from './components/Subscriptions';
import ReportedProblems from './components/ReportedProblems';
import Layout from './components/Layout';
import './App.css';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  const handleLogin = () => {
    // Ensure the admin always lands on the dashboard after login,
    // even if the browser URL was previously on another protected route.
    window.history.replaceState({}, '', '/dashboard');
    setIsAuthenticated(true);
  };

  const handleLogout = () => {
    // Clear auth and reset URL so next login starts clean.
    localStorage.removeItem('adminToken');
    window.history.replaceState({}, '', '/');
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
          <Route path="/job-listings" element={<JobsListings />} />
          <Route path="/categories" element={<Categories />} />
          <Route path="/accommodation-listings" element={<AccommodationListings />} />
          <Route path="/food-listings" element={<FoodListings />} />
          <Route path="/jobs-listings" element={<JobsListings />} />
          <Route path="/services-listings" element={<ServicesListings />} />
          <Route path="/custom-category/:id" element={<CustomCategoryListings />} />
          <Route path="/users" element={<Users />} />
          <Route path="/content-moderation" element={<ContentModeration />} />
          <Route path="/community" element={<Community />} />
          <Route path="/subscriptions" element={<Subscriptions />} />
          <Route path="/settings" element={<Settings />} />
          <Route path="/reported-problems" element={<ReportedProblems />} />
        </Routes>
      </Layout>
    </Router>
  );
}

export default App;
