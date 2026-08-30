const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const db = require('../config/database');

// User Registration
router.post('/register', async (req, res) => {
    const { aadhaar_hash, name, email, phone, income, education } = req.body;
    
    try {
        const existing = db.prepare(
            'SELECT id FROM users WHERE aadhaar_hash = ? OR email = ?'
        ).get(aadhaar_hash, email);
        
        if (existing) {
            return res.status(400).json({ success: false, error: 'User already exists' });
        }

        const result = db.prepare(
            `INSERT INTO users (aadhaar_hash, name, email, phone, income, education) 
             VALUES (?, ?, ?, ?, ?, ?)`
        ).run(aadhaar_hash, name, email, phone, income, education);
        
        const user = { id: result.lastInsertRowid, name, email };
        const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET, { expiresIn: '24h' });
        
        res.json({ success: true, token, user });
    } catch (error) {
        console.error('Registration error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// User Login (Aadhaar based)
router.post('/login', async (req, res) => {
    const { aadhaar_hash } = req.body;
    
    try {
        const user = db.prepare('SELECT * FROM users WHERE aadhaar_hash = ?').get(aadhaar_hash);
        
        if (!user) {
            return res.status(401).json({ success: false, error: 'User not found' });
        }
        
        const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET, { expiresIn: '24h' });
        res.json({ success: true, token, user: { id: user.id, name: user.name, email: user.email, phone: user.phone, income: user.income, caste_category: user.caste_category, education: user.education } });
    } catch (error) {
        console.error('Login error:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

module.exports = router;
