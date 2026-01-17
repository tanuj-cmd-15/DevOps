const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ status: 'healthy' });
});

// Main API endpoint
app.get('/api/message', (req, res) => {
    res.json({
        message: 'Hello from Express Backend running on Kubernetes!',
        timestamp: new Date().toISOString(),
        service: 'backend-service'
    });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Backend server running on port ${PORT}`);
});