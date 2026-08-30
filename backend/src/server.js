require('dotenv').config({ override: true });
const express = require('express');
const cors = require('cors');

// Initialize database
require('./config/database');

// Initialize Redis
const { connectRedis } = require('./config/redis');
connectRedis();

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
app.use('/api/auth', require('./routes/auth'));
app.use('/api/schemes', require('./routes/schemes'));
app.use('/api/partners', require('./routes/partners'));
app.use('/api/applications', require('./routes/applications'));
app.use('/api/calculate', require('./routes/calculator'));
app.use('/api/analytics', require('./routes/analytics'));

// Health Check
app.get('/api/health', (req, res) => {
    res.json({ status: 'OK', message: 'Surakshit API is running', timestamp: new Date().toISOString() });
});

// Error handling
const errorHandler = require('./middleware/errorHandler');
app.use(errorHandler);

app.listen(PORT, () => {
    console.log(`Surakshit API running on http://localhost:${PORT}`);
});
