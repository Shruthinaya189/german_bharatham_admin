import React, { useState } from 'react';

const Users = () => {
  const [sortBy, setSortBy] = useState('newest');
  const [filterBy, setFilterBy] = useState('all');

  const users = [
    { 
      id: 1, 
      name: 'Finn', 
      email: 'finn@gmail.com', 
      joinedDate: '2024-11-02', 
      status: 'Active',
      avatar: 'https://ui-avatars.com/api/?name=Finn&background=6b9976&color=fff'
    },
    { 
      id: 2, 
      name: 'Priti', 
      email: 'priti@gmail.com', 
      joinedDate: '2024-11-02', 
      status: 'Active',
      avatar: 'https://ui-avatars.com/api/?name=Priti&background=6b9976&color=fff'
    },
    { 
      id: 3, 
      name: 'Jay Sri', 
      email: 'jai@gmail.com', 
      joinedDate: '2024-11-02', 
      status: 'Active',
      avatar: 'https://ui-avatars.com/api/?name=Jay+Sri&background=6b9976&color=fff'
    },
    { 
      id: 4, 
      name: 'Priyanka', 
      email: 'priti@gmail.com', 
      joinedDate: '2024-11-02', 
      status: 'Inactive',
      avatar: 'https://ui-avatars.com/api/?name=Priyanka&background=6b9976&color=fff'
    },
    { 
      id: 5, 
      name: 'Ferno', 
      email: 'pritxyz@gmail.com', 
      joinedDate: '2024-11-02', 
      status: 'Active',
      avatar: 'https://ui-avatars.com/api/?name=Ferno&background=6b9976&color=fff'
    },
    { 
      id: 6, 
      name: 'Ken', 
      email: 'servebiz@gmail.com', 
      joinedDate: '2024-11-01', 
      status: 'Inactive',
      avatar: 'https://ui-avatars.com/api/?name=Ken&background=6b9976&color=fff'
    },
    { 
      id: 7, 
      name: 'Priya', 
      email: 'priyak@gmail.com', 
      joinedDate: '2024-11-01', 
      status: 'Active',
      avatar: 'https://ui-avatars.com/api/?name=Priya&background=6b9976&color=fff'
    },
    { 
      id: 8, 
      name: 'Saran Kumar', 
      email: 'sarankq@gmail.com', 
      joinedDate: '2024-11-02', 
      status: 'Inactive',
      avatar: 'https://ui-avatars.com/api/?name=Saran+Kumar&background=6b9976&color=fff'
    },
    { 
      id: 9, 
      name: 'Hari', 
      email: 'priti@gmail.com', 
      joinedDate: '2024-11-02', 
      status: 'Active',
      avatar: 'https://ui-avatars.com/api/?name=Hari&background=6b9976&color=fff'
    },
    { 
      id: 10, 
      name: 'Abc', 
      email: 'abc@gmail.com', 
      joinedDate: '2024-11-01', 
      status: 'Inactive',
      avatar: 'https://ui-avatars.com/api/?name=Abc&background=6b9976&color=fff'
    },
    { 
      id: 11, 
      name: 'Kiran', 
      email: 'kiran@gmail.com', 
      joinedDate: '2024-11-01', 
      status: 'Active',
      avatar: 'https://ui-avatars.com/api/?name=Kiran&background=6b9976&color=fff'
    }
  ];

  const handleUserAction = (userId, action) => {
    console.log(`${action} user:`, userId);
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
              <tr key={user.id}>
                <td>
                  <div className="user-info">
                    <img src={user.avatar} alt={user.name} className="user-avatar" />
                    <span className="user-name">{user.name}</span>
                  </div>
                </td>
                <td>{user.email}</td>
                <td>{user.joinedDate}</td>
                <td>
                  <span className={`status ${user.status.toLowerCase()}`}>
                    {user.status}
                  </span>
                </td>
                <td>
                  {user.status === 'Active' ? (
                    <button 
                      className="action-btn deactivate-btn"
                      onClick={() => handleUserAction(user.id, 'deactivate')}
                    >
                      Deactivate
                    </button>
                  ) : (
                    <button 
                      className="action-btn activate-btn"
                      onClick={() => handleUserAction(user.id, 'activate')}
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
