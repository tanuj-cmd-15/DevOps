const express = require("express");
const axios = require("axios");
const app = express();

// Get backend URL from environment variable or use default
const BACKEND_URL = process.env.BACKEND_URL || "http://localhost:5000";

app.set("view engine", "ejs");
app.use(express.urlencoded({ extended: true }));
app.use(express.json());

app.get("/", (req, res) => {
  res.render("index");
});

app.post("/register", async (req, res) => {
  try {
    const response = await axios.post(`${BACKEND_URL}/api/register`, {
      name: req.body.name,
      course: req.body.course
    });
    
    res.send(`<h2 style="text-align:center; color:green;">${response.data.message}</h2>`);
  } catch (error) {
    res.send(`<h2 style="text-align:center; color:red;">Error: ${error.message}</h2>`);
  }
});

app.get("/health", (req, res) => {
  res.json({ status: "healthy" });
});

app.listen(3000, () => {
  console.log("Frontend running on port 3000");
  console.log(`Backend URL: ${BACKEND_URL}`);
});