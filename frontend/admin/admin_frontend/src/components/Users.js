import React, { useState, useEffect } from 'react';
const Users = () => {
  const [sortBy, setSortBy] = useState('newest');
  const [filterBy, setFilterBy] = useState('all');
  const [users, setUsers] = useState([]);
  const BASE = "http://10.166.137.12:5000";
  useEffect(() => {
  fetchUsers();
}, []);

const fetchUsers = async () => {
  try {
    const token = localStorage.getItem("adminToken");

    const response = await fetch(`${BASE}/api/user/all-users`, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });

    const data = await response.json();

    if (!response.ok) {
      alert(data.message);
      return;
    }

    setUsers(data);

  } catch (error) {
    console.error("Error fetching users:", error);
  }
};
  const handleUserAction = async (userId, action) => {
  try {
    const token = localStorage.getItem("adminToken");

    await fetch(`${BASE}/api/user/${action}/${userId}`, {
      method: "PUT",
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });

    fetchUsers(); // refresh table

  } catch (error) {
    console.error("Error updating user:", error);
  }
};

  return (
    <div className="users">
      <div className="users-header">
        <div>
          <h1>Users</h1>
          <p>View and manage platform users.</p>
        </div>
        <div className="header-filters">
          <div className="filter-dropdown">
            <select 
              value={sortBy} 
              onChange={(e) => setSortBy(e.target.value)}
              className="filter-select"
            >
              <option value="newest">Newest first</option>
              <option value="oldest">Oldest first</option>
              <option value="alphabetical">A-Z</option>
            </select>
          </div>
          <div className="filter-dropdown">
            <select 
              value={filterBy} 
              onChange={(e) => setFilterBy(e.target.value)}
              className="filter-select"
            >
              <option value="all">All Users</option>
              <option value="active">Active</option>
              <option value="inactive">Inactive</option>
            </select>
          </div>
        </div>
      </div>

      <div className="users-table">
        <table>
          <thead>
            <tr>
              <th>NAME</th>
              <th>EMAIL</th>
              <th>JOINED DATE</th>
              <th>STATUS</th>
              <th>ACTION</th>
            </tr>
          </thead>
          <tbody>
           {users.map((user) => (
  <tr key={user._id}>
    <td>
      <div className="user-info">
        <img 
          src={`https://ui-avatars.com/api/?name=${user.name}&background=6b9976&color=fff`} 
          alt={user.name} 
          className="user-avatar" 
        />
        <span className="user-name">{user.name}</span>
      </div>
    </td>

    <td>{user.email}</td>

    <td>{new Date(user.createdAt).toLocaleDateString()}</td>

    <td>
      <span className={`status ${user.isActive ? "active" : "inactive"}`}>
        {user.isActive ? "Active" : "Inactive"}
      </span>
    </td>

    <td>
      {user.isActive ? (
        <button 
          className="action-btn deactivate-btn"
          onClick={() => handleUserAction(user._id, 'deactivate')}
        >
          Deactivate
        </button>
      ) : (
        <button 
          className="action-btn activate-btn"
          onClick={() => handleUserAction(user._id, 'activate')}
        >
          Activate
        </button>
      )}
    </td>
  </tr>
))}
          </tbody>
        </table>
      </div>

      <div className="pagination">
        <div className="pagination-numbers">
          <button className="pagination-btn active">1</button>
          <button className="pagination-btn">2</button>
          <button className="pagination-btn">3</button>
          <button className="pagination-btn">4</button>
          <span className="pagination-dots">...</span>
        </div>
      </div>
    </div>
  );
};

export default Users;
