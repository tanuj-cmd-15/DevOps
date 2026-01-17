from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

@app.route("/api/register", methods=["POST"])
def register():
    data = request.json
    name = data.get("name")
    course = data.get("course")
    
    return jsonify({
        "message": f"Student {name} registered for {course}"
    })

@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "healthy"}), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)