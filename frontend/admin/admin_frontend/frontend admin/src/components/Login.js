import React, { useState } from 'react';
import { Eye, EyeOff } from 'lucide-react';

const Login = ({ onLogin }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);

  const handleSubmit = (e) => {
    e.preventDefault();
    // Simple validation - in real app, you'd validate against backend
    if (email && password) {
      onLogin();
    }
  };

  return (
    <div className="login-container">
      <div className="login-sidebar">
        <div className="login-brand">
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
                {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
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
