const pool = require('../config/database');
const { cacheGet, cacheSet } = require('../config/redis');

class PartnerService {
    async findNearestPartners(userLat, userLng, schemeCode, limit = 5) {
        const cacheKey = `partners:nearby:${schemeCode}:${Math.round(userLat)}:${Math.round(userLng)}`;
        const cached = await cacheGet(cacheKey);
        if (cached) return cached;

        const query = `
            SELECT p.id, p.name, p.type, p.address, p.phone, p.email,
                   ST_Y(p.location) as latitude, ST_X(p.location) as longitude,
                   p.fund_utilization, p.npa_rate, p.supported_schemes,
                   ST_Distance(p.location::geography, ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography) / 1000 as distance_km,
                   CASE WHEN p.fund_utilization >= 80 AND (p.type != 'RRB' OR p.npa_rate < 15) AND (p.type != 'NBFC-MFI' OR p.npa_rate < 3) THEN true ELSE false END as is_eligible
            FROM partners p
            WHERE p.is_eligible = true AND p.fund_utilization >= 80 AND $3 = ANY(p.supported_schemes)
            ORDER BY distance_km ASC LIMIT $4
        `;
        const result = await pool.query(query, [userLng, userLat, schemeCode, limit]);
        const partners = result.rows.map(row => ({
            ...row, distance: Math.round(row.distance_km * 100) / 100, isEligible: row.is_eligible,
            fundStatus: row.fund_utilization >= 80 ? 'Good' : 'Needs Improvement',
            npaStatus: row.npa_rate < 5 ? 'Healthy' : row.npa_rate < 10 ? 'Moderate' : 'High',
            schemeCompatibility: row.supported_schemes.includes(schemeCode)
        }));

        await cacheSet(cacheKey, partners, 300);
        return partners;
    }

    async checkPartnerEligibility(partnerId) {
        const result = await pool.query(
            `SELECT p.id, p.name, p.type, p.address, p.phone, p.email,
                    ST_Y(p.location) as latitude, ST_X(p.location) as longitude,
                    p.fund_utilization, p.npa_rate,
                CASE WHEN p.fund_utilization >= 80 AND (p.type != 'RRB' OR p.npa_rate < 15) AND (p.type != 'NBFC-MFI' OR p.npa_rate < 3) THEN true ELSE false END as is_eligible,
                CASE WHEN p.type = 'RRB' AND p.npa_rate >= 15 THEN 'RRB NPA exceeds 15% limit'
                     WHEN p.type = 'NBFC-MFI' AND p.npa_rate >= 3 THEN 'NBFC-MFI NPA exceeds 3% limit'
                     WHEN p.fund_utilization < 80 THEN 'Fund utilization below 80%' ELSE null END as eligibility_reason
             FROM partners p
             WHERE p.id = $1`, [partnerId]
        );
        return result.rows[0] || null;
    }

    async getPartnerById(partnerId) {
        const result = await pool.query(
            `SELECT p.id, p.name, p.type, p.address, p.phone, p.email,
                    ST_Y(p.location) as latitude, ST_X(p.location) as longitude,
                    p.fund_utilization, p.npa_rate, p.is_eligible, p.supported_schemes,
                    p.created_at, p.updated_at
             FROM partners p
             WHERE p.id = $1`, [partnerId]
        );
        return result.rows[0] || null;
    }

    async getAllPartners() {
        const cached = await cacheGet('partners:all');
        if (cached) return cached;

        const result = await pool.query(
            `SELECT p.id, p.name, p.type, p.address, p.phone, p.email,
                    ST_Y(p.location) as latitude, ST_X(p.location) as longitude,
                    p.fund_utilization, p.npa_rate, p.is_eligible, p.supported_schemes,
                    p.created_at, p.updated_at
             FROM partners p
             ORDER BY fund_utilization DESC`
        );
        await cacheSet('partners:all', result.rows, 3600);
        return result.rows;
    }
}

module.exports = new PartnerService();
