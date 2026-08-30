const express = require('express');
const cors = require('cors');
require('dotenv').config({ override: true });

// Initialize database (creates tables)
require('./config/database');

const app = express();
const PORT = (process.env.PORT && process.env.PORT !== '0') ? process.env.PORT : 5000;

// Middleware
app.use(cors({
    origin: ['http://localhost:3000', 'http://localhost:5173'],
    credentials: true
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
const authRoutes = require('./routes/auth');
const schemeRoutes = require('./routes/schemes');
const partnerRoutes = require('./routes/partners');
const applicationRoutes = require('./routes/applications');
const calculatorRoutes = require('./routes/calculator');
const analyticsRoutes = require('./routes/analytics');

app.use('/api/auth', authRoutes);
app.use('/api/schemes', schemeRoutes);
app.use('/api/partners', partnerRoutes);
app.use('/api/applications', applicationRoutes);
app.use('/api/calculate', calculatorRoutes);
app.use('/api/analytics', analyticsRoutes);

// Health Check
app.get('/api/health', (req, res) => {
    res.json({ status: 'OK', message: 'Surakshit API is running', timestamp: new Date().toISOString() });
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error('Unhandled error:', err);
    res.status(500).json({ success: false, error: 'Internal server error' });
});

// Start Server
app.listen(PORT, () => {
    console.log(`Surakshit API running on http://localhost:${PORT}`);
    console.log(`Health check: http://localhost:${PORT}/api/health`);
});
