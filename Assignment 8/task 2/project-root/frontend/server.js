const express = require('express');
const axios = require('axios');
const path = require('path');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;
const BACKEND_URL = process.env.BACKEND_URL || 'http://localhost:5000';

app.use(express.json());
app.use(express.static('public'));

// Home route - serves the HTML page
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Health check
app.get('/health', (req, res) => {
    res.json({
        status: 'healthy',
        service: 'express-frontend',
        timestamp: new Date().toISOString()
    });
});

// Proxy route to backend - Get all users
app.get('/api/users', async (req, res) => {
    try {
        const response = await axios.get(`${BACKEND_URL}/api/users`);
        res.json(response.data);
    } catch (error) {
        console.error('Error fetching users:', error.message);
        res.status(500).json({
            success: false,
            error: 'Failed to fetch users from backend',
            details: error.message
        });
    }
});

// Proxy route - Get single user
app.get('/api/users/:id', async (req, res) => {
    try {
        const response = await axios.get(`${BACKEND_URL}/api/users/${req.params.id}`);
        res.json(response.data);
    } catch (error) {
        console.error('Error fetching user:', error.message);
        res.status(error.response?.status || 500).json({
            success: false,
            error: 'Failed to fetch user from backend',
            details: error.message
        });
    }
});

// Proxy route - Create user
app.post('/api/users', async (req, res) => {
    try {
        const response = await axios.post(`${BACKEND_URL}/api/users`, req.body);
        res.status(201).json(response.data);
    } catch (error) {
        console.error('Error creating user:', error.message);
        res.status(error.response?.status || 500).json({
            success: false,
            error: 'Failed to create user',
            details: error.message
        });
    }
});

// Proxy route - Delete user
app.delete('/api/users/:id', async (req, res) => {
    try {
        const response = await axios.delete(`${BACKEND_URL}/api/users/${req.params.id}`);
        res.json(response.data);
    } catch (error) {
        console.error('Error deleting user:', error.message);
        res.status(error.response?.status || 500).json({
            success: false,
            error: 'Failed to delete user',
            details: error.message
        });
    }
});

// Backend health check
app.get('/api/backend-health', async (req, res) => {
    try {
        const response = await axios.get(`${BACKEND_URL}/api/health`);
        res.json({
            backend_status: 'connected',
            backend_response: response.data
        });
    } catch (error) {
        res.status(503).json({
            backend_status: 'disconnected',
            error: error.message
        });
    }
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Express server running on port ${PORT}`);
    console.log(`Backend URL: ${BACKEND_URL}`);
});