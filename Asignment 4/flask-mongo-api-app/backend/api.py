@app.route("/submittodoitem", methods=["POST"])
def submit_todo():
    data = {
        "itemName": request.form["itemName"],
        "itemDescription": request.form["itemDescription"]
    }
    collection.insert_one(data)
    return "Todo item saved"
