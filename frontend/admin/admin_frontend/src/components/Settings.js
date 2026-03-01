import React, { useState } from 'react';
import { ChevronUp, ChevronDown, Save, Lock } from 'lucide-react';

const Settings = () => {
  const [contentManagementOpen, setContentManagementOpen] = useState(true);
  const [changePasswordOpen, setChangePasswordOpen] = useState(true);

  const [contentData, setContentData] = useState({
    aboutUs: 'German Bharatham is a platform connecting the German-Indian community with local services, accommodations, food, and job opportunities.',
    contactEmail: 'contact@germanbharatham.com',
    contactPhone: '+49 123 456 7890',
    contactAddress: 'Berlin, Germany',
    privacyPolicy: 'We respect your privacy and are committed to protecting your personal data. This privacy policy will inform you about how we look after your personal data.',
    termsConditions: 'By accessing this platform, you agree to be bound by these terms and conditions. Please read them carefully before using our services.'
  });

  const [passwordData, setPasswordData] = useState({
    currentPassword: '',
    newPassword: '',
    confirmPassword: ''
  });

  const handleSaveSettings = () => {
    console.log('Saving settings:', contentData);
  };

  const handleUpdatePassword = () => {
    console.log('Updating password');
  };

  return (
    <div className="settings">
      <div className="settings-header">
        <h1>Settings</h1>
        <p>Manage app content and policies</p>
      </div>

      <div className="settings-content">
        {/* Content Management Section */}
        <div className="settings-accordion">
          <div 
            className="accordion-header"
            onClick={() => setContentManagementOpen(!contentManagementOpen)}
          >
            <h2>Content Management</h2>
            {contentManagementOpen ? <ChevronUp size={20} /> : <ChevronDown size={20} />}
          </div>
          
          {contentManagementOpen && (
            <div className="accordion-content">
              {/* About Us */}
              <div className="content-item">
                <div className="content-item-header">
                  <span className="content-label">About Us</span>
                  <span className="last-updated">Last Updated on 2024-09-11</span>
                </div>
                <textarea
                  value={contentData.aboutUs}
                  onChange={(e) => setContentData(prev => ({...prev, aboutUs: e.target.value}))}
                  rows={3}
                  className="content-textarea-field"
                />
              </div>

              {/* Contact Information */}
              <div className="content-item">
                <div className="content-item-header">
                  <span className="content-label">Contact Information</span>
                  <span className="last-updated">Last Updated on 2024-09-11</span>
                </div>
                <div className="contact-info-display">
                  <p>Email: {contentData.contactEmail}</p>
                  <p>Phone: {contentData.contactPhone}</p>
                  <p>Address: {contentData.contactAddress}</p>
                </div>
              </div>

              {/* Privacy Policy */}
              <div className="content-item">
                <div className="content-item-header">
                  <span className="content-label">Privacy Policy</span>
                  <span className="last-updated">Last Updated on 2024-09-11</span>
                </div>
                <textarea
                  value={contentData.privacyPolicy}
                  onChange={(e) => setContentData(prev => ({...prev, privacyPolicy: e.target.value}))}
                  rows={3}
                  className="content-textarea-field"
                />
              </div>

              {/* Terms & Conditions */}
              <div className="content-item">
                <div className="content-item-header">
                  <span className="content-label">Terms & Conditions</span>
                  <span className="last-updated">Last Updated on 2024-09-11</span>
                </div>
                <textarea
                  value={contentData.termsConditions}
                  onChange={(e) => setContentData(prev => ({...prev, termsConditions: e.target.value}))}
                  rows={3}
                  className="content-textarea-field"
                />
              </div>

              <button className="save-all-btn" onClick={handleSaveSettings}>
                <Save size={18} />
                Save All Settings
              </button>
            </div>
          )}
        </div>

        {/* Change Password Section */}
        <div className="settings-accordion">
          <div 
            className="accordion-header"
            onClick={() => setChangePasswordOpen(!changePasswordOpen)}
          >
            <h2>Change Password</h2>
            {changePasswordOpen ? <ChevronUp size={20} /> : <ChevronDown size={20} />}
          </div>
          
          {changePasswordOpen && (
            <div className="accordion-content">
              <div className="password-form">
                <div className="form-group">
                  <label>Current Password</label>
                  <input
                    type="password"
                    placeholder="Enter your current password"
                    value={passwordData.currentPassword}
                    onChange={(e) => setPasswordData(prev => ({...prev, currentPassword: e.target.value}))}
                  />
                </div>
                <div className="form-group">
                  <label>New Password</label>
                  <input
                    type="password"
                    placeholder="Enter new Password"
                    value={passwordData.newPassword}
                    onChange={(e) => setPasswordData(prev => ({...prev, newPassword: e.target.value}))}
                  />
                </div>
                <div className="form-group">
                  <label>Confirm New Password</label>
                  <input
                    type="password"
                    placeholder="Confirm new Password"
                    value={passwordData.confirmPassword}
                    onChange={(e) => setPasswordData(prev => ({...prev, confirmPassword: e.target.value}))}
                  />
                </div>
                <div className="password-actions">
                  <button className="cancel-btn">Cancel</button>
                  <button className="update-password-btn" onClick={handleUpdatePassword}>
                    <Lock size={16} />
                    Update Password
                  </button>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default Settings;
