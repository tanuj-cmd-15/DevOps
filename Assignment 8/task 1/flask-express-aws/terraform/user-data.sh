#!/bin/bash
set -e

# Update system
apt-get update
apt-get upgrade -y

# Install Python and pip
apt-get install -y python3 python3-pip python3-venv

# Install Node.js and npm
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Install PM2 globally
npm install -g pm2

# Create application directory
mkdir -p /home/ubuntu/app
cd /home/ubuntu/app

# Create backend directory
mkdir -p backend
cat > backend/app.py << 'EOF'
from flask import Flask, jsonify, request
from flask_cors import CORS
from datetime import datetime
import os

app = Flask(__name__)
CORS(app)

# In-memory data store
tasks = []
task_counter = 1

@app.route('/')
def home():
    return jsonify({
        'message': 'Flask Backend API',
        'version': '1.0.0',
        'timestamp': datetime.now().isoformat()
    })

@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'service': 'flask-backend',
        'timestamp': datetime.now().isoformat()
    })

@app.route('/api/tasks', methods=['GET'])
def get_tasks():
    return jsonify({
        'tasks': tasks,
        'count': len(tasks)
    })

@app.route('/api/tasks', methods=['POST'])
def create_task():
    global task_counter
    data = request.get_json()
    
    if not data or 'title' not in data:
        return jsonify({'error': 'Title is required'}), 400
    
    task = {
        'id': task_counter,
        'title': data['title'],
        'description': data.get('description', ''),
        'completed': False,
        'created_at': datetime.now().isoformat()
    }
    
    tasks.append(task)
    task_counter += 1
    
    return jsonify(task), 201

@app.route('/api/tasks/<int:task_id>', methods=['PUT'])
def update_task(task_id):
    data = request.get_json()
    
    for task in tasks:
        if task['id'] == task_id:
            task['completed'] = data.get('completed', task['completed'])
            task['title'] = data.get('title', task['title'])
            task['description'] = data.get('description', task['description'])
            return jsonify(task)
    
    return jsonify({'error': 'Task not found'}), 404

@app.route('/api/tasks/<int:task_id>', methods=['DELETE'])
def delete_task(task_id):
    global tasks
    tasks = [t for t in tasks if t['id'] != task_id]
    return jsonify({'message': 'Task deleted'}), 200

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)
EOF

cat > backend/requirements.txt << 'EOF'
Flask==3.0.0
flask-cors==4.0.0
gunicorn==21.2.0
EOF

# Create frontend directory
mkdir -p frontend/public
cat > frontend/server.js << 'EOF'
const express = require('express');
const path = require('path');
const app = express();

app.use(express.static('public'));

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Frontend server running on port ${PORT}`);
});
EOF

cat > frontend/package.json << 'EOF'
{
  "name": "express-frontend",
  "version": "1.0.0",
  "description": "Express frontend for Flask backend",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOF

cat > frontend/public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Task Manager - Flask & Express</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }

        .container {
            max-width: 800px;
            margin: 0 auto;
        }

        .header {
            background: white;
            padding: 30px;
            border-radius: 20px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            margin-bottom: 30px;
            text-align: center;
        }

        .header h1 {
            color: #667eea;
            font-size: 2.5em;
            margin-bottom: 10px;
        }

        .header p {
            color: #666;
            font-size: 1.1em;
        }

        .status-bar {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 30px;
        }

        .status-card {
            background: white;
            padding: 20px;
            border-radius: 15px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.1);
            text-align: center;
        }

        .status-card h3 {
            color: #333;
            font-size: 0.9em;
            margin-bottom: 10px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .status-card p {
            font-size: 2em;
            font-weight: bold;
            color: #667eea;
        }

        .status-indicator {
            display: inline-block;
            width: 12px;
            height: 12px;
            border-radius: 50%;
            margin-right: 8px;
            animation: pulse 2s infinite;
        }

        .status-healthy {
            background: #10b981;
        }

        .status-error {
            background: #ef4444;
        }

        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }

        .card {
            background: white;
            padding: 30px;
            border-radius: 20px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            margin-bottom: 20px;
        }

        .input-group {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
        }

        input[type="text"] {
            flex: 1;
            padding: 15px 20px;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            font-size: 16px;
            transition: all 0.3s;
        }

        input[type="text"]:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
        }

        button {
            padding: 15px 30px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.3s;
        }

        button:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 20px rgba(102, 126, 234, 0.4);
        }

        button:active {
            transform: translateY(0);
        }

        .tasks-list {
            list-style: none;
        }

        .task-item {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 12px;
            margin-bottom: 12px;
            display: flex;
            align-items: center;
            gap: 15px;
            transition: all 0.3s;
            border-left: 4px solid #667eea;
        }

        .task-item:hover {
            background: #e9ecef;
            transform: translateX(5px);
        }

        .task-item.completed {
            opacity: 0.6;
            border-left-color: #10b981;
        }

        .task-item.completed .task-title {
            text-decoration: line-through;
        }

        .task-checkbox {
            width: 24px;
            height: 24px;
            cursor: pointer;
            accent-color: #667eea;
        }

        .task-content {
            flex: 1;
        }

        .task-title {
            font-weight: 600;
            color: #333;
            margin-bottom: 5px;
        }

        .task-desc {
            color: #666;
            font-size: 0.9em;
        }

        .task-time {
            color: #999;
            font-size: 0.8em;
        }

        .delete-btn {
            background: #ef4444;
            padding: 8px 16px;
            font-size: 14px;
        }

        .delete-btn:hover {
            background: #dc2626;
        }

        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #999;
        }

        .empty-state svg {
            width: 80px;
            height: 80px;
            margin-bottom: 20px;
            opacity: 0.3;
        }

        .loading {
            text-align: center;
            padding: 40px;
            color: #667eea;
            font-size: 1.2em;
        }

        @media (max-width: 600px) {
            .header h1 {
                font-size: 1.8em;
            }
            
            .input-group {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚀 Task Manager</h1>
            <p>Flask Backend + Express Frontend on AWS EC2</p>
        </div>

        <div class="status-bar">
            <div class="status-card">
                <h3>Backend Status</h3>
                <p id="backendStatus">
                    <span class="status-indicator status-error"></span>
                    Checking...
                </p>
            </div>
            <div class="status-card">
                <h3>Total Tasks</h3>
                <p id="taskCount">0</p>
            </div>
            <div class="status-card">
                <h3>Completed</h3>
                <p id="completedCount">0</p>
            </div>
        </div>

        <div class="card">
            <div class="input-group">
                <input type="text" id="taskTitle" placeholder="Task title..." />
                <input type="text" id="taskDesc" placeholder="Description (optional)..." />
                <button onclick="addTask()">Add Task</button>
            </div>

            <ul id="tasksList" class="tasks-list">
                <li class="loading">Loading tasks...</li>
            </ul>
        </div>
    </div>

    <script>
        const API_URL = `http://${window.location.hostname}:5000`;

        async function checkBackendHealth() {
            try {
                const response = await fetch(`${API_URL}/health`);
                const data = await response.json();
                document.getElementById('backendStatus').innerHTML = 
                    '<span class="status-indicator status-healthy"></span>Online';
            } catch (error) {
                document.getElementById('backendStatus').innerHTML = 
                    '<span class="status-indicator status-error"></span>Offline';
            }
        }

        async function loadTasks() {
            try {
                const response = await fetch(`${API_URL}/api/tasks`);
                const data = await response.json();
                const tasks = data.tasks;

                const tasksList = document.getElementById('tasksList');
                const totalTasks = tasks.length;
                const completedTasks = tasks.filter(t => t.completed).length;

                document.getElementById('taskCount').textContent = totalTasks;
                document.getElementById('completedCount').textContent = completedTasks;

                if (tasks.length === 0) {
                    tasksList.innerHTML = `
                        <li class="empty-state">
                            <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                                    d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                            </svg>
                            <div>No tasks yet. Add your first task!</div>
                        </li>
                    `;
                } else {
                    tasksList.innerHTML = tasks.map(task => `
                        <li class="task-item ${task.completed ? 'completed' : ''}">
                            <input type="checkbox" class="task-checkbox" 
                                ${task.completed ? 'checked' : ''} 
                                onchange="toggleTask(${task.id}, this.checked)">
                            <div class="task-content">
                                <div class="task-title">${escapeHtml(task.title)}</div>
                                ${task.description ? `<div class="task-desc">${escapeHtml(task.description)}</div>` : ''}
                                <div class="task-time">${new Date(task.created_at).toLocaleString()}</div>
                            </div>
                            <button class="delete-btn" onclick="deleteTask(${task.id})">Delete</button>
                        </li>
                    `).join('');
                }
            } catch (error) {
                console.error('Error loading tasks:', error);
                document.getElementById('tasksList').innerHTML = 
                    '<li class="empty-state">Error loading tasks. Please check if the backend is running.</li>';
            }
        }

        async function addTask() {
            const title = document.getElementById('taskTitle').value.trim();
            const description = document.getElementById('taskDesc').value.trim();

            if (!title) {
                alert('Please enter a task title');
                return;
            }

            try {
                await fetch(`${API_URL}/api/tasks`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ title, description })
                });

                document.getElementById('taskTitle').value = '';
                document.getElementById('taskDesc').value = '';
                loadTasks();
            } catch (error) {
                console.error('Error adding task:', error);
                alert('Failed to add task');
            }
        }

        async function toggleTask(id, completed) {
            try {
                await fetch(`${API_URL}/api/tasks/${id}`, {
                    method: 'PUT',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ completed })
                });
                loadTasks();
            } catch (error) {
                console.error('Error updating task:', error);
            }
        }

        async function deleteTask(id) {
            if (!confirm('Are you sure you want to delete this task?')) return;

            try {
                await fetch(`${API_URL}/api/tasks/${id}`, { method: 'DELETE' });
                loadTasks();
            } catch (error) {
                console.error('Error deleting task:', error);
            }
        }

        function escapeHtml(text) {
            const div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }

        document.getElementById('taskTitle').addEventListener('keypress', (e) => {
            if (e.key === 'Enter') addTask();
        });

        checkBackendHealth();
        loadTasks();
        setInterval(checkBackendHealth, 30000);
    </script>
</body>
</html>
EOF

# Set proper permissions
chown -R ubuntu:ubuntu /home/ubuntu/app

# Install backend dependencies
cd /home/ubuntu/app/backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Install frontend dependencies
cd /home/ubuntu/app/frontend
npm install

# Start Flask with Gunicorn (using PM2 for process management)
cd /home/ubuntu/app/backend
sudo -u ubuntu bash -c "cd /home/ubuntu/app/backend && source venv/bin/activate && pm2 start 'gunicorn -w 4 -b 0.0.0.0:5000 app:app' --name flask-backend"

# Start Express with PM2
cd /home/ubuntu/app/frontend
sudo -u ubuntu pm2 start server.js --name express-frontend

# Save PM2 process list
sudo -u ubuntu pm2 save

# Setup PM2 to start on boot
sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u ubuntu --hp /home/ubuntu
sudo -u ubuntu pm2 save

echo "Deployment complete!"