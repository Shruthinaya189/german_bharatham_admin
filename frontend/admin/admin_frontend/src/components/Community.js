import React, { useState, useEffect } from 'react';
import { Plus, ChevronRight } from 'lucide-react';
import CreatePostModal from './CreatePostModal';

const Community = () => {
  const [view, setView] = useState('list');
  const [posts, setPosts] = useState([]);

  useEffect(() => {
    fetchPosts();
  }, []);

  const fetchPosts = async () => {
    try {
      const response = await fetch("http://10.166.137.12:5000/api/community");
      const data = await response.json();
      setPosts(data);
    } catch (error) {
      console.error("Error fetching posts:", error);
    }
  };

  if (view === 'create') {
    return (
      <CreatePostModal 
        onClose={() => {
          setView('list');
          fetchPosts(); // refresh after create
        }} 
      />
    );
  }

  return (
    <div className="community">
      <div className="community-header">
        <div>
          <h1>Posts by you</h1>
          <p>Posts for the community</p>
        </div>
        <button 
          className="new-post-btn"
          onClick={() => setView('create')}
        >
          <Plus size={20} />
          New Post
        </button>
      </div>

      <div className="posts-list">
        {posts.map((post) => (
          <div key={post._id} className="post-item">
            <div className="post-content">
              <div className="post-header">
                <h3 className="post-title">{post.title}</h3>
                <span className={`post-category ${post.category?.toLowerCase()}`}>
                  {post.category}
                </span>
              </div>
              <div className="post-meta">
                <span className="post-date">
                  {new Date(post.createdAt).toDateString()}
                </span>
                <span className="post-separator">•</span>
                <span className="post-read-time">
                  {post.readTime} min read
                </span>
              </div>
            </div>
            <div className="post-actions">
              <button className="action-btn chevron-btn">
                <ChevronRight size={20} />
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default Community;