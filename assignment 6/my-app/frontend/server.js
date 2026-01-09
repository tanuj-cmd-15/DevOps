const express = require('express');
const path = require('path');
const axios = require('axios');

const app = express();
const PORT = process.env.PORT || 3000;
const BACKEND_URL = process.env.BACKEND_URL || 'http://localhost:5000';

app.use(express.static('public'));

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.get('/api/proxy/data', async (req, res) => {
    try {
        const response = await axios.get(`${BACKEND_URL}/api/data`);
        res.json(response.data);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch data from backend' });
    }
});

app.get('/api/proxy/health', async (req, res) => {
    try {
        const response = await axios.get(`${BACKEND_URL}/api/health`);
        res.json(response.data);
    } catch (error) {
        res.status(500).json({ error: 'Backend is down' });
    }
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Frontend server running on port ${PORT}`);
    console.log(`Backend URL: ${BACKEND_URL}`);
});