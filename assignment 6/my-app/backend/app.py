from flask import Flask, jsonify
from flask_cors import CORS
from datetime import datetime

app = Flask(__name__)
CORS(app)

@app.route('/')
def home():
    return jsonify({
        'message': 'Flask Backend is running!',
        'timestamp': datetime.now().isoformat()
    })

@app.route('/api/health')
def health():
    return jsonify({'status': 'healthy', 'service': 'backend'})

@app.route('/api/data')
def get_data():
    return jsonify({
        'users': [
            {'id': 1, 'name': 'Alice', 'role': 'Developer'},
            {'id': 2, 'name': 'Bob', 'role': 'Designer'},
            {'id': 3, 'name': 'Charlie', 'role': 'Manager'}
        ]
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)