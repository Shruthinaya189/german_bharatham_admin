import React, { useState, useEffect } from 'react';
import { Plus, Eye, Edit, Trash2 } from 'lucide-react';
import CreatePostModal from './CreatePostModal';

const Community = () => {
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [posts, setPosts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchCommunityPosts = async () => {
      try {
        setLoading(true);
        const response = await fetch('http://10.166.137.12:5000/api/community');
        if (!response.ok) {
          throw new Error('Failed to fetch community posts');
        }
        const data = await response.json();
        setPosts(data);
      } catch (err) {
        setError(err.message);
        console.error(err);
      } finally {
        setLoading(false);
      }
    };

    fetchCommunityPosts();
  }, []);

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

      {loading && <p>Loading posts...</p>}
      {error && <p style={{ color: 'red' }}>Error: {error}</p>}
      
      {!loading && !error && (
        <div className="posts-list">
          {posts.length === 0 ? (
            <p>No posts yet</p>
          ) : (
            posts.map((post, index) => (
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
            ))
          )}
        </div>
      )}

      {showCreateModal && (
        <CreatePostModal onClose={() => setShowCreateModal(false)} />
      )}
    </div>
  );
};

export default Community;
