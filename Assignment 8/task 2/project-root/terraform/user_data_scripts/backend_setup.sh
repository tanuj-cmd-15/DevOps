#!/bin/bash
set -e

# Log everything
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "========================================="
echo "Starting Flask Backend Setup"
echo "========================================="

# Update system
echo "Updating system packages..."
apt-get update -y
apt-get upgrade -y

# Install Python and dependencies
echo "Installing Python3 and pip..."
apt-get install -y python3 python3-pip python3-venv

# Create application directory
echo "Creating application directory..."
mkdir -p /home/ubuntu/backend
cd /home/ubuntu/backend

# Create Flask application
echo "Creating Flask application..."
cat > app.py << 'EOF'
from flask import Flask, jsonify, request
from flask_cors import CORS
from datetime import datetime
import os

app = Flask(__name__)
CORS(app)

users = [
    {"id": 1, "name": "Alice Johnson", "email": "alice@example.com", "role": "Developer"},
    {"id": 2, "name": "Bob Smith", "email": "bob@example.com", "role": "Designer"},
    {"id": 3, "name": "Carol White", "email": "carol@example.com", "role": "Manager"}
]

@app.route('/')
def home():
    return jsonify({
        "message": "Flask Backend API",
        "version": "1.0.0",
        "timestamp": datetime.now().isoformat()
    })

@app.route('/api/health')
def health():
    return jsonify({
        "status": "healthy",
        "service": "flask-backend",
        "timestamp": datetime.now().isoformat()
    })

@app.route('/api/users', methods=['GET'])
def get_users():
    return jsonify({
        "success": True,
        "data": users,
        "count": len(users)
    })

@app.route('/api/users/<int:user_id>', methods=['GET'])
def get_user(user_id):
    user = next((u for u in users if u['id'] == user_id), None)
    if user:
        return jsonify({"success": True, "data": user})
    return jsonify({"success": False, "error": "User not found"}), 404

@app.route('/api/users', methods=['POST'])
def create_user():
    data = request.get_json()
    if not data or 'name' not in data or 'email' not in data:
        return jsonify({"success": False, "error": "Name and email required"}), 400
    
    new_user = {
        "id": max([u['id'] for u in users]) + 1 if users else 1,
        "name": data['name'],
        "email": data['email'],
        "role": data.get('role', 'User')
    }
    users.append(new_user)
    return jsonify({"success": True, "data": new_user}), 201

@app.route('/api/users/<int:user_id>', methods=['DELETE'])
def delete_user(user_id):
    global users
    user = next((u for u in users if u['id'] == user_id), None)
    if not user:
        return jsonify({"success": False, "error": "User not found"}), 404
    users = [u for u in users if u['id'] != user_id]
    return jsonify({"success": True, "message": "User deleted"})

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)
EOF

# Create requirements.txt
echo "Creating requirements.txt..."
cat > requirements.txt << 'EOF'
Flask==3.0.0
flask-cors==4.0.0
gunicorn==21.2.0
EOF

# Create virtual environment and install dependencies
echo "Setting up Python virtual environment..."
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# Create systemd service
echo "Creating systemd service..."
cat > /etc/systemd/system/flask.service << 'EOF'
[Unit]
Description=Flask Backend Application
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/backend
Environment="PATH=/home/ubuntu/backend/venv/bin"
Environment="PORT=${flask_port}"
ExecStart=/home/ubuntu/backend/venv/bin/gunicorn --bind 0.0.0.0:${flask_port} --workers 2 app:app
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Set proper permissions
echo "Setting permissions..."
chown -R ubuntu:ubuntu /home/ubuntu/backend

# Start and enable service
echo "Starting Flask service..."
systemctl daemon-reload
systemctl start flask
systemctl enable flask

# Wait for service to start
sleep 5

# Check service status
echo "Checking Flask service status..."
systemctl status flask --no-pager

echo "========================================="
echo "Flask Backend Setup Complete!"
echo "Service running on port ${flask_port}"
echo "========================================="