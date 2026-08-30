const db = require('../config/database');

/**
 * Haversine distance between two points
 */
function haversineDistance(lat1, lon1, lat2, lon2) {
    const R = 6371;
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLon = (lon2 - lon1) * Math.PI / 180;
    const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
              Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
              Math.sin(dLon/2) * Math.sin(dLon/2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    return R * c;
}

/**
 * Find Nearest Eligible Partners
 */
function findNearestPartners(userLat, userLng, schemeCode, limit = 5) {
    const allPartners = db.prepare(
        'SELECT * FROM partners WHERE is_eligible = 1'
    ).all();
    
    const results = allPartners
        .filter(p => {
            const supportedSchemes = (p.supported_schemes || '').split(',').map(s => s.trim());
            if (!supportedSchemes.includes(schemeCode)) return false;
            if (p.fund_utilization < 80) return false;
            if (p.type === 'RRB' && p.npa_rate >= 15) return false;
            if (p.type === 'NBFC-MFI' && p.npa_rate >= 3) return false;
            return true;
        })
        .map(p => ({
            ...p,
            distance: Math.round(haversineDistance(userLat, userLng, p.latitude, p.longitude) * 100) / 100,
            isEligible: true,
            fundStatus: p.fund_utilization >= 80 ? 'Good' : 'Needs Improvement',
            npaStatus: p.npa_rate < 5 ? 'Healthy' : p.npa_rate < 10 ? 'Moderate' : 'High'
        }))
        .sort((a, b) => a.distance - b.distance)
        .slice(0, limit);
    
    return results;
}

/**
 * Check Individual Partner Eligibility
 */
function checkPartnerEligibility(partnerId) {
    const partner = db.prepare('SELECT * FROM partners WHERE id = ?').get(partnerId);
    if (!partner) return null;
    
    let isEligible = true;
    let reason = null;
    
    if (partner.fund_utilization < 80) {
        isEligible = false;
        reason = 'Fund utilization below 80%';
    } else if (partner.type === 'RRB' && partner.npa_rate >= 15) {
        isEligible = false;
        reason = 'RRB NPA exceeds 15% limit';
    } else if (partner.type === 'NBFC-MFI' && partner.npa_rate >= 3) {
        isEligible = false;
        reason = 'NBFC-MFI NPA exceeds 3% limit';
    }
    
    return { ...partner, is_eligible: isEligible, eligibility_reason: reason };
}

function getPartnerById(partnerId) {
    return db.prepare('SELECT * FROM partners WHERE id = ?').get(partnerId);
}

module.exports = { findNearestPartners, checkPartnerEligibility, getPartnerById };
