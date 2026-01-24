#!/bin/bash
set -e

# Log everything
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "========================================="
echo "Starting Express Frontend Setup"
echo "========================================="

# Update system
echo "Updating system packages..."
apt-get update -y
apt-get upgrade -y

# Install Node.js
echo "Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# Verify installation
node --version
npm --version

# Create application directory
echo "Creating application directory..."
mkdir -p /home/ubuntu/frontend/public
cd /home/ubuntu/frontend

# Create package.json
echo "Creating package.json..."
cat > package.json << 'EOF'
{
  "name": "express-frontend",
  "version": "1.0.0",
  "description": "Express frontend server",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "axios": "^1.6.0",
    "dotenv": "^16.3.1"
  }
}
EOF

# Create .env file
echo "Creating .env file..."
cat > .env << 'EOF'
BACKEND_URL=${backend_url}
PORT=${express_port}
NODE_ENV=production
EOF

# Create server.js
echo "Creating Express server..."
cat > server.js << 'EOF'
const express = require('express');
const axios = require('axios');
const path = require('path');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;
const BACKEND_URL = process.env.BACKEND_URL || 'http://localhost:5000';

app.use(express.json());
app.use(express.static('public'));

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.get('/health', (req, res) => {
    res.json({
        status: 'healthy',
        service: 'express-frontend',
        timestamp: new Date().toISOString()
    });
});

app.get('/api/users', async (req, res) => {
    try {
        const response = await axios.get(`${BACKEND_URL}/api/users`);
        res.json(response.data);
    } catch (error) {
        console.error('Error:', error.message);
        res.status(500).json({ success: false, error: 'Failed to fetch users' });
    }
});

app.get('/api/users/:id', async (req, res) => {
    try {
        const response = await axios.get(`${BACKEND_URL}/api/users/$${req.params.id}`);
        res.json(response.data);
    } catch (error) {
        res.status(error.response?.status || 500).json({ success: false, error: 'Failed to fetch user' });
    }
});

app.post('/api/users', async (req, res) => {
    try {
        const response = await axios.post(`${BACKEND_URL}/api/users`, req.body);
        res.status(201).json(response.data);
    } catch (error) {
        res.status(error.response?.status || 500).json({ success: false, error: 'Failed to create user' });
    }
});

app.delete('/api/users/:id', async (req, res) => {
    try {
        const response = await axios.delete(`${BACKEND_URL}/api/users/$${req.params.id}`);
        res.json(response.data);
    } catch (error) {
        res.status(error.response?.status || 500).json({ success: false, error: 'Failed to delete user' });
    }
});

app.get('/api/backend-health', async (req, res) => {
    try {
        const response = await axios.get(`${BACKEND_URL}/api/health`);
        res.json({ backend_status: 'connected', backend_response: response.data });
    } catch (error) {
        res.status(503).json({ backend_status: 'disconnected', error: error.message });
    }
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Express server running on port $${PORT}`);
    console.log(`Backend URL: ${BACKEND_URL}`);
});
EOF

# Create HTML file
echo "Creating HTML file..."
cat > public/index.html << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Management System</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; padding: 20px; }
        .container { max-width: 1200px; margin: 0 auto; background: white; border-radius: 15px; box-shadow: 0 20px 60px rgba(0,0,0,0.3); overflow: hidden; }
        header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; }
        h1 { font-size: 2.5em; margin-bottom: 10px; }
        .status { display: inline-block; padding: 8px 15px; background: rgba(255,255,255,0.2); border-radius: 20px; font-size: 0.9em; margin-top: 10px; }
        .content { padding: 30px; }
        .form-section { background: #f8f9fa; padding: 25px; border-radius: 10px; margin-bottom: 30px; }
        h2 { color: #667eea; margin-bottom: 20px; font-size: 1.5em; }
        .form-group { margin-bottom: 15px; }
        label { display: block; margin-bottom: 5px; color: #333; font-weight: 600; }
        input, select { width: 100%; padding: 12px; border: 2px solid #e0e0e0; border-radius: 8px; font-size: 1em; }
        input:focus, select:focus { outline: none; border-color: #667eea; }
        button { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 12px 30px; border: none; border-radius: 8px; font-size: 1em; cursor: pointer; font-weight: 600; }
        button:hover { transform: translateY(-2px); box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4); }
        .users-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px; margin-top: 20px; }
        .user-card { background: white; border: 2px solid #e0e0e0; border-radius: 10px; padding: 20px; transition: transform 0.3s; }
        .user-card:hover { transform: translateY(-5px); box-shadow: 0 10px 25px rgba(0,0,0,0.1); }
        .user-name { font-size: 1.3em; color: #333; margin-bottom: 10px; font-weight: 600; }
        .user-info { color: #666; margin-bottom: 5px; }
        .user-role { display: inline-block; background: #667eea; color: white; padding: 5px 15px; border-radius: 15px; font-size: 0.85em; margin-top: 10px; }
        .delete-btn { background: #e74c3c; padding: 8px 20px; margin-top: 15px; font-size: 0.9em; }
        .delete-btn:hover { background: #c0392b; }
        .loading { text-align: center; padding: 40px; color: #999; font-size: 1.2em; }
        .error { background: #fee; color: #c33; padding: 15px; border-radius: 8px; margin-bottom: 20px; }
        .success { background: #efe; color: #3c3; padding: 15px; border-radius: 8px; margin-bottom: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>👥 User Management System</h1>
            <div class="status" id="status">Checking connection...</div>
        </header>
        <div class="content">
            <div id="message"></div>
            <div class="form-section">
                <h2>Add New User</h2>
                <form id="userForm">
                    <div class="form-group">
                        <label for="name">Name:</label>
                        <input type="text" id="name" required>
                    </div>
                    <div class="form-group">
                        <label for="email">Email:</label>
                        <input type="email" id="email" required>
                    </div>
                    <div class="form-group">
                        <label for="role">Role:</label>
                        <select id="role">
                            <option value="Developer">Developer</option>
                            <option value="Designer">Designer</option>
                            <option value="Manager">Manager</option>
                            <option value="User">User</option>
                        </select>
                    </div>
                    <button type="submit">Add User</button>
                </form>
            </div>
            <div>
                <h2>Users List</h2>
                <div id="users" class="users-grid"><div class="loading">Loading users...</div></div>
            </div>
        </div>
    </div>
    <script>
        async function checkBackendHealth() {
            try {
                const res = await fetch('/api/backend-health');
                const data = await res.json();
                const status = document.getElementById('status');
                if (data.backend_status === 'connected') {
                    status.textContent = '✅ Backend Connected';
                    status.style.background = 'rgba(46, 213, 115, 0.3)';
                } else {
                    status.textContent = '❌ Backend Disconnected';
                    status.style.background = 'rgba(231, 76, 60, 0.3)';
                }
            } catch (error) {
                document.getElementById('status').textContent = '❌ Connection Error';
            }
        }
        async function loadUsers() {
            try {
                const res = await fetch('/api/users');
                const data = await res.json();
                const container = document.getElementById('users');
                if (data.success && data.data.length > 0) {
                    container.innerHTML = data.data.map(user => `
                        <div class="user-card">
                            <div class="user-name">$${user.name}</div>
                            <div class="user-info">📧 $${user.email}</div>
                            <div class="user-info">🆔 ID: $${user.id}</div>
                            <span class="user-role">$${user.role}</span>
                            <button class="delete-btn" onclick="deleteUser($${user.id})">Delete</button>
                        </div>
                    `).join('');
                } else {
                    container.innerHTML = '<div class="loading">No users found</div>';
                }
            } catch (error) {
                document.getElementById('users').innerHTML = '<div class="error">Failed to load users</div>';
            }
        }
        async function deleteUser(id) {
            if (!confirm('Are you sure?')) return;
            try {
                const res = await fetch(`/api/users/$${id}`, { method: 'DELETE' });
                const data = await res.json();
                if (data.success) {
                    showMessage('User deleted successfully', 'success');
                    loadUsers();
                }
            } catch (error) {
                showMessage('Error deleting user', 'error');
            }
        }
        document.getElementById('userForm').addEventListener('submit', async (e) => {
            e.preventDefault();
            const formData = {
                name: document.getElementById('name').value,
                email: document.getElementById('email').value,
                role: document.getElementById('role').value
            };
            try {
                const res = await fetch('/api/users', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(formData)
                });
                const data = await res.json();
                if (data.success) {
                    showMessage('User added successfully!', 'success');
                    e.target.reset();
                    loadUsers();
                }
            } catch (error) {
                showMessage('Error adding user', 'error');
            }
        });
        function showMessage(text, type) {
            const msg = document.getElementById('message');
            msg.className = type;
            msg.textContent = text;
            setTimeout(() => msg.textContent = '', 3000);
        }
        checkBackendHealth();
        loadUsers();
        setInterval(checkBackendHealth, 30000);
    </script>
</body>
</html>
HTMLEOF

# Install Node packages
echo "Installing Node.js dependencies..."
chown -R ubuntu:ubuntu /home/ubuntu/frontend
su - ubuntu -c "cd /home/ubuntu/frontend && npm install"

# Create systemd service
echo "Creating systemd service..."
cat > /etc/systemd/system/express.service << 'EOF'
[Unit]
Description=Express Frontend Application
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/frontend
Environment="NODE_ENV=production"
Environment="PORT=${express_port}"
Environment="BACKEND_URL=${backend_url}"
ExecStart=/usr/bin/node server.js
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Start and enable service
echo "Starting Express service..."
systemctl daemon-reload
systemctl start express
systemctl enable express

# Wait for service to start
sleep 5

# Check service status
echo "Checking Express service status..."
systemctl status express --no-pager

echo "========================================="
echo "Express Frontend Setup Complete!"
echo "Service running on port ${express_port}"
echo "Backend URL: ${backend_url}"
echo "========================================="