const pool = require('../config/database');

/**
 * Find Nearest Eligible Partners using PostGIS ST_Distance
 */
async function findNearestPartners(userLat, userLng, schemeCode, limit = 5) {
    const query = `
        SELECT 
            p.id, p.name, p.type, p.address, p.phone, p.email,
            p.fund_utilization, p.npa_rate,
            ST_Distance(
                p.location::geography, 
                ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography
            ) / 1000 as distance_km,
            CASE 
                WHEN p.fund_utilization >= 80 
                 AND (p.type != 'RRB' OR p.npa_rate < 15)
                 AND (p.type != 'NBFC-MFI' OR p.npa_rate < 3)
                THEN true ELSE false 
            END as is_eligible
        FROM partners p
        WHERE 
            p.is_eligible = true
            AND p.fund_utilization >= 80
            AND $3 = ANY(p.supported_schemes)
        ORDER BY distance_km ASC
        LIMIT $4
    `;
    
    const result = await pool.query(query, [userLng, userLat, schemeCode, limit]);
    
    return result.rows.map(row => ({
        ...row,
        distance: Math.round(row.distance_km * 100) / 100,
        isEligible: row.is_eligible,
        fundStatus: row.fund_utilization >= 80 ? 'Good' : 'Needs Improvement',
        npaStatus: row.npa_rate < 5 ? 'Healthy' : row.npa_rate < 10 ? 'Moderate' : 'High'
    }));
}

/**
 * Check Individual Partner Eligibility
 */
async function checkPartnerEligibility(partnerId) {
    const result = await pool.query(
        `SELECT id, name, type, fund_utilization, npa_rate,
            CASE WHEN fund_utilization >= 80 AND (type != 'RRB' OR npa_rate < 15) AND (type != 'NBFC-MFI' OR npa_rate < 3) THEN true ELSE false END as is_eligible,
            CASE WHEN type = 'RRB' AND npa_rate >= 15 THEN 'RRB NPA exceeds 15% limit'
                 WHEN type = 'NBFC-MFI' AND npa_rate >= 3 THEN 'NBFC-MFI NPA exceeds 3% limit'
                 WHEN fund_utilization < 80 THEN 'Fund utilization below 80%'
                 ELSE null END as eligibility_reason
         FROM partners WHERE id = $1`, [partnerId]
    );
    return result.rows[0] || null;
}

async function getPartnerById(partnerId) {
    const result = await pool.query('SELECT * FROM partners WHERE id = $1', [partnerId]);
    return result.rows[0] || null;
}

module.exports = { findNearestPartners, checkPartnerEligibility, getPartnerById };
