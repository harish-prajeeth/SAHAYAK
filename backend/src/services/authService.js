const jwt = require('jsonwebtoken');
const pool = require('../config/database');
const { cacheGet, cacheSet, cacheDel } = require('../config/redis');
const { MAX_INCOME } = require('../utils/constants');

class AuthService {
    async register(userData) {
        const { aadhaar_hash, name, email, phone, income, education } = userData;

        if (income > MAX_INCOME) {
            throw new Error('Income exceeds eligibility limit of ₹5,00,000');
        }

        const existing = await pool.query(
            'SELECT id FROM users WHERE aadhaar_hash = $1 OR email = $2',
            [aadhaar_hash, email]
        );
        if (existing.rows.length > 0) {
            throw new Error('User already exists');
        }

        const result = await pool.query(
            `INSERT INTO users (aadhaar_hash, name, email, phone, income, education)
             VALUES ($1, $2, $3, $4, $5, $6)
             RETURNING id, name, email, income, education`,
            [aadhaar_hash, name, email, phone, income, education]
        );

        const user = result.rows[0];
        const token = this.generateToken(user.id);
        await cacheSet(`user:${user.id}`, user, 86400);
        return { user, token };
    }

    async login(rawInput) {
        const aadhaarHash = (rawInput || '').trim();

        if (!aadhaarHash || aadhaarHash.length < 3) {
            throw new Error('Please enter a valid Aadhaar or Demo ID (e.g. demo1)');
        }

        const SELECT = 'SELECT id, name, email, phone, income, caste_category, education FROM users';

        // Exact match first, then case-insensitive fallback
        let result = await pool.query(`${SELECT} WHERE aadhaar_hash = $1`, [aadhaarHash]);
        if (result.rows.length === 0) {
            result = await pool.query(`${SELECT} WHERE LOWER(aadhaar_hash) = LOWER($1)`, [aadhaarHash]);
        }

        let user;
        if (result.rows.length > 0) {
            user = result.rows[0];
        } else {
            // Demo mode: auto-provision unknown IDs so no beneficiary is ever
            // blocked at the door (production would use Aadhaar OTP instead).
            const label = aadhaarHash.length <= 20 ? aadhaarHash : `user-${aadhaarHash.slice(-4)}`;
            const created = await pool.query(
                `INSERT INTO users (aadhaar_hash, name, income, caste_category, education)
                 VALUES ($1, $2, $3, $4, $5)
                 RETURNING id, name, email, phone, income, caste_category, education`,
                [aadhaarHash, `Guest (${label})`, 240000, 'SC', 'Graduate']
            );
            user = created.rows[0];
            console.log(`Auto-provisioned new demo user: ${user.name} (id=${user.id})`);
        }

        const token = this.generateToken(user.id);
        await cacheSet(`user:${user.id}`, user, 86400);
        await cacheSet(`user:aadhaar:${aadhaarHash}`, user, 86400);
        return { user, token, isNew: result.rows.length === 0 };
    }

    generateToken(userId) {
        return jwt.sign({ userId }, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRY || '7d' });
    }

    verifyToken(token) {
        return jwt.verify(token, process.env.JWT_SECRET);
    }

    async logout(userId) {
        await cacheDel(`user:${userId}`);
    }

    async getUser(userId) {
        const cached = await cacheGet(`user:${userId}`);
        if (cached) return cached;

        const result = await pool.query(
            'SELECT id, name, email, phone, income, caste_category, education FROM users WHERE id = $1',
            [userId]
        );
        if (result.rows.length === 0) throw new Error('User not found');

        const user = result.rows[0];
        await cacheSet(`user:${userId}`, user, 86400);
        return user;
    }
}

module.exports = new AuthService();
