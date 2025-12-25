const express = require("express");
const axios = require("axios");
const app = express();

app.set("view engine", "ejs");
app.use(express.static("public"));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get("/", (req, res) => {
  res.render("signup");
});

app.post("/signup", async (req, res) => {
  try {
    const response = await axios.post("http://backend:5000/api/signup", {
      name: req.body.name,
      email: req.body.email,
      password: req.body.password
    });

    res.send(`<h2 style="text-align:center;color:green;">${response.data.message}</h2>`);
  } catch (err) {
    res.send("<h2 style='color:red;text-align:center;'>Backend Error</h2>");
  }
});

app.listen(3000, () => {
  console.log("Frontend running on port 3000");
});
