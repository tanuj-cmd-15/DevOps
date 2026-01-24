from flask import Flask, jsonify, request
from flask_cors import CORS
from datetime import datetime
import os

app = Flask(__name__)
CORS(app)

# In-memory data store
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
        return jsonify({
            "success": True,
            "data": user
        })
    return jsonify({
        "success": False,
        "error": "User not found"
    }), 404

@app.route('/api/users', methods=['POST'])
def create_user():
    data = request.get_json()
    
    if not data or 'name' not in data or 'email' not in data:
        return jsonify({
            "success": False,
            "error": "Name and email are required"
        }), 400
    
    new_user = {
        "id": max([u['id'] for u in users]) + 1 if users else 1,
        "name": data['name'],
        "email": data['email'],
        "role": data.get('role', 'User')
    }
    
    users.append(new_user)
    
    return jsonify({
        "success": True,
        "data": new_user,
        "message": "User created successfully"
    }), 201

@app.route('/api/users/<int:user_id>', methods=['DELETE'])
def delete_user(user_id):
    global users
    user = next((u for u in users if u['id'] == user_id), None)
    
    if not user:
        return jsonify({
            "success": False,
            "error": "User not found"
        }), 404
    
    users = [u for u in users if u['id'] != user_id]
    
    return jsonify({
        "success": True,
        "message": "User deleted successfully"
    })

@app.errorhandler(404)
def not_found(error):
    return jsonify({
        "success": False,
        "error": "Endpoint not found"
    }), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({
        "success": False,
        "error": "Internal server error"
    }), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)