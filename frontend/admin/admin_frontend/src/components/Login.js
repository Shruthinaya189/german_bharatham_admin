import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Eye, EyeOff } from 'lucide-react';
import API_URL from '../config';

const PROD_API_URL = 'https://german-bharatham-backend.onrender.com';
const LOCAL_API_URL = 'http://127.0.0.1:5000';

const getApiCandidates = () => {
  const candidates = [API_URL, LOCAL_API_URL, PROD_API_URL]
    .filter(Boolean)
    .map((u) => u.replace(/\/$/, ''));
  return [...new Set(candidates)];
};

const Login = ({ onLogin }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);

  const navigate = useNavigate();

  const handleSubmit = async (e) => {
  e.preventDefault();

  try {
    let response;
    let data;
    let lastError;

    for (const baseUrl of getApiCandidates()) {
      try {
        response = await fetch(`${baseUrl}/api/admin/login`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({ email, password }),
        });

        data = await response.json();

        if (!response.ok) {
          // Auth/validation errors should not fall through to another API.
          alert(data?.message || 'Login failed');
          return;
        }

        // Success, persist working API for this browser session.
        localStorage.setItem('adminApiBase', baseUrl);
        break;
      } catch (err) {
        lastError = err;
      }
    }

    if (!response || !data) {
      throw lastError || new Error('Unable to reach backend API');
    }

    // Store token
    // Login success
    localStorage.setItem("adminToken", data.token);

    // Optionally fetch protected admin data right after login
    await fetchProtectedData();

    // Notify app and navigate to dashboard
    onLogin();
    navigate('/dashboard');
  } catch (error) {
    console.error("Login error:", error);
    alert("Unable to connect to server. Please ensure backend is running or internet is available.");
  }
};
const fetchProtectedData = async () => {

  const token = localStorage.getItem("adminToken");
  const preferredBase = localStorage.getItem('adminApiBase');
  const candidates = [preferredBase, ...getApiCandidates()].filter(Boolean);

  let response;
  for (const baseUrl of [...new Set(candidates)]) {
    try {
      response = await fetch(`${baseUrl}/api/admin/dashboard`, {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${token}` // <-- THIS IS REQUIRED
        },
      });
      if (response.ok) break;
    } catch (_) {
      // Try next candidate
    }
  }

  if (!response) {
    throw new Error('Dashboard API unreachable');
  }

const data = await response.json();
console.log(data);
};
  return (
    <div className="login-container">
      <div className="login-sidebar">
        <div className="login-brand">
          <div className="brand-logo-wrap brand-logo-wrap--lg" aria-hidden="true">
            <img className="brand-logo" src="/app_logo.jpeg" alt="" />
          </div>
          <h1>German Bharatham</h1>
          <p>Admin Panel</p>
        </div>
      </div>
      
      <div className="login-form-container">
        <div className="login-form">
          <h2>Welcome</h2>
          
          <form onSubmit={handleSubmit}>
            <div className="form-group">
              <input
                type="email"
                placeholder="Email address"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
            </div>
            
            <div className="form-group password-group">
              <input
                type={showPassword ? 'text' : 'password'}
                placeholder="Password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
              <button
                type="button"
                className="password-toggle"
                onClick={() => setShowPassword(!showPassword)}
              >
                {showPassword ? <Eye size={20} /> : <EyeOff size={20} />}
              </button>
            </div>
            
            <button type="submit" className="sign-in-btn">
              Sign In
            </button>
          </form>
          
          <p className="auth-notice">
            🔒 Authorized access only. This panel is restricted to platform administrators.
          </p>
        </div>
      </div>
    </div>
  );
};

export default Login;
