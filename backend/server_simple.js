const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Basic middleware
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/api/health', (req, res) => {
    res.json({
        status: 'OK',
        message: 'Phone Store API is running',
        timestamp: new Date().toISOString()
    });
});

// Test endpoint
app.get('/api/test', (req, res) => {
    res.json({ message: 'Server is working!' });
});

// Start server
app.listen(PORT, () => {
    console.log(`🚀 Simple server is running on port ${PORT}`);
    console.log(`📱 Test API: http://localhost:${PORT}/api/health`);
});

module.exports = app;