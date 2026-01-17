from flask import Flask, render_template, jsonify
import requests
import os

app = Flask(__name__)

# Backend service URL (will be updated for Kubernetes)
BACKEND_URL = os.getenv('BACKEND_URL', 'http://localhost:3000')

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/data')
def get_data():
    try:
        response = requests.get(f'{BACKEND_URL}/api/message')
        return jsonify(response.json())
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)