const express = require("express");
const axios = require("axios");
const app = express();

app.use(express.urlencoded({ extended: true }));
app.use(express.json());

// Backend EC2 PUBLIC DNS
const BACKEND_URL =
  "http://ec2-13-200-235-203.ap-south-1.compute.amazonaws.com:5000";

app.get("/", (req, res) => {
  res.send(`
    <h2>Student Registration</h2>
    <form method="POST" action="/submit">
      <input name="name" placeholder="Name" required />
      <input name="course" placeholder="Course" required />
      <button>Submit</button>
    </form>
  `);
});

app.post("/submit", async (req, res) => {
  try {
    await axios.post(`${BACKEND_URL}/api/contact`, {
      name: req.body.name,
      course: req.body.course
    });
    res.send("Form submitted successfully ✅");
  } catch (err) {
    console.error(err.message);
    res.send("Backend connection failed ❌");
  }
});

app.listen(3000, () => {
  console.log("Frontend running on port 3000");
});
