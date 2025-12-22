from flask import Flask, jsonify, render_template, request, redirect
from pymongo import MongoClient
import json
import os
from config import MONGO_URI, DATABASE_NAME, COLLECTION_NAME

app = Flask(
    __name__,
    template_folder="../frontend/templates",
    static_folder="../frontend/static"
)


client = MongoClient(MONGO_URI)
db = client[DATABASE_NAME]
collection = db[COLLECTION_NAME]

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
@app.route("/api")
def api_data():
    file_path = os.path.join(BASE_DIR, "backend_data.json")
    with open(file_path, "r") as file:
        data = json.load(file)
    return jsonify(data)


@app.route("/", methods=["GET", "POST"])
def form():
    error = None

    if request.method == "POST":
        try:
            name = request.form["name"]
            email = request.form["email"]

            collection.insert_one({
                "name": name,
                "email": email
            })

            return redirect("/success")

        except Exception as e:
            error = str(e)

    return render_template("form.html", error=error)


@app.route("/success")
def success():
    return render_template("success.html")

if __name__ == "__main__":
    app.run(debug=True)
