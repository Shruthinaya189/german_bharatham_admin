import React, { useState } from 'react';
import { Plus, Eye, Edit, Trash2 } from 'lucide-react';
import CreatePostModal from './CreatePostModal';

const Community = () => {
  const [showCreateModal, setShowCreateModal] = useState(false);

  const posts = [
    {
      title: 'Complete Guide to German Registration - Anmeldung',
      category: 'Guide',
      date: 'Jan 20, 2026',
      readTime: '4 min read',
      status: 'published'
    },
    {
      title: 'New Community Guidelines Update',
      category: 'Announcement',
      date: 'Jan 20, 2026',
      readTime: '4 min read',
      status: 'published'
    }
  ];

  return (
    <div className="community">
      <div className="community-header">
        <div>
          <h1>Posts by you</h1>
          <p>Posts for the Community</p>
        </div>
        <button 
          className="new-post-btn"
          onClick={() => setShowCreateModal(true)}
        >
          <Plus size={20} />
          New Post
        </button>
      </div>

      <div className="posts-list">
        {posts.map((post, index) => (
          <div key={index} className="post-item">
            <div className="post-content">
              <div className="post-header">
                <h3 className="post-title">{post.title}</h3>
                <span className={`post-category ${post.category.toLowerCase()}`}>
                  {post.category}
                </span>
              </div>
              <div className="post-meta">
                <span className="post-date">{post.date}</span>
                <span className="post-separator">•</span>
                <span className="post-read-time">{post.readTime}</span>
              </div>
            </div>
            <div className="post-actions">
              <button className="action-btn view-btn">
                <Eye size={16} />
              </button>
              <button className="action-btn edit-btn">
                <Edit size={16} />
              </button>
              <button className="action-btn delete-btn">
                <Trash2 size={16} />
              </button>
            </div>
          </div>
        ))}
      </div>

      {showCreateModal && (
        <CreatePostModal onClose={() => setShowCreateModal(false)} />
      )}
    </div>
  );
};

export default Community;
