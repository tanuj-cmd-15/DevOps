from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route("/api/contact", methods=["GET", "POST"])
def contact():
    if request.method == "POST":
        data = request.json or request.form
        print("Received from frontend:", data, flush=True)
        return jsonify({"message": "POST data received successfully"})
    
    # GET request (browser test)
    return jsonify({
        "status": "Backend is running",
        "message": "Use POST method to submit data"
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
