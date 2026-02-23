import React, { useState } from 'react';
import { X, Upload } from 'lucide-react';

const CreatePostModal = ({ onClose }) => {
  const [postData, setPostData] = useState({
    title: '',
    category: 'Guide',
    readTime: '5',
    content: ''
  });

  const handleSubmit = (e) => {
    e.preventDefault();
    console.log('Post created:', postData);
    onClose();
  };

  return (
    <div className="modal-overlay">
      <div className="modal-content create-post-modal">
        <div className="modal-header">
          <div>
            <h2>Create New Post</h2>
            <p>Create a new post for the community</p>
          </div>
          <div className="header-actions">
            <button className="show-all-btn">Show All Posts</button>
            <button className="close-btn" onClick={onClose}>
              <X size={24} />
            </button>
          </div>
        </div>

        <form onSubmit={handleSubmit} className="create-post-form">
          <div className="form-group">
            <label>Title</label>
            <input
              type="text"
              placeholder="e.g., Complete Guide to Germany - Anmeldung"
              value={postData.title}
              onChange={(e) => setPostData(prev => ({...prev, title: e.target.value}))}
              required
            />
          </div>

          <div className="form-row">
            <div className="form-group">
              <label>Category</label>
              <select
                value={postData.category}
                onChange={(e) => setPostData(prev => ({...prev, category: e.target.value}))}
              >
                <option value="Guide">Guide</option>
                <option value="Announcement">Announcement</option>
                <option value="News">News</option>
                <option value="Tips">Tips</option>
              </select>
            </div>
            <div className="form-group">
              <label>Estimated Read Time (minutes)</label>
              <input
                type="number"
                value={postData.readTime}
                onChange={(e) => setPostData(prev => ({...prev, readTime: e.target.value}))}
                min="1"
                max="60"
              />
            </div>
          </div>

          <div className="form-group">
            <label>Content</label>
            <textarea
              placeholder="Write your Post content here..."
              value={postData.content}
              onChange={(e) => setPostData(prev => ({...prev, content: e.target.value}))}
              rows={12}
              className="content-textarea"
            />
          </div>

          <div className="form-actions">
            <button type="submit" className="publish-btn">
              <Upload size={20} />
              Publish Post
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default CreatePostModal;
