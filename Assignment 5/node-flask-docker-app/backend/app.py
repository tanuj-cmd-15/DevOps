from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route("/api/signup", methods=["POST"])
def signup():
    data = request.json
    name = data.get("name")
    email = data.get("email")

    return jsonify({
        "message": f"User {name} registered successfully!"
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
