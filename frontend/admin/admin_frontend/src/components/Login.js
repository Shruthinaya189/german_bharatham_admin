import React, { useState } from 'react';
import { Eye, EyeOff } from 'lucide-react';
import API_URL from '../config';

const Login = ({ onLogin }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);

  const handleSubmit = async (e) => {
  e.preventDefault();

  try {
    const response = await fetch(`${API_URL}/api/admin/login`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ email, password }),
    });

    const data = await response.json();

    if (!response.ok) {
      alert(data.message);
      return;
    }

    // Store token
    // Login success
localStorage.setItem("adminToken", data.token);

    // Optionally fetch protected admin data right after login
    await fetchProtectedData();

    // Login success
    onLogin();
  } catch (error) {
    console.error("Login error:", error);
    alert("Failed to fetch");
  }
};
const fetchProtectedData = async () => {

  const token = localStorage.getItem("adminToken");

const response = await fetch(`${API_URL}/api/admin/dashboard`, {
  method: "GET",
  headers: {
    "Content-Type": "application/json",
    "Authorization": `Bearer ${token}` // <-- THIS IS REQUIRED
  },
});

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
