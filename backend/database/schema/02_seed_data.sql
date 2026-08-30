-- ============================================
-- SEED DATA: SCHEMES
-- ============================================
INSERT INTO schemes (name, code, description, min_cost, max_cost, max_loan, interest_rate, max_tenure_months, moratorium_months, channel_types) VALUES
('Micro Finance Scheme', 'MFS', 'For small projects up to ₹1.40 lakh', 0, 140000, 125000, 6.5, 36, 3, ARRAY['SCA', 'PSB', 'RRB']),
('Term Loan', 'TL', 'For projects up to ₹50 lakh', 140001, 5000000, 4500000, 8.0, 84, 6, ARRAY['SCA', 'PSB', 'RRB']),
('Educational Loan Scheme', 'ELS', 'For education up to ₹40 lakh', 0, 4000000, 4000000, 6.5, 144, 12, ARRAY['SCA', 'PSB', 'RRB']),
('Aajeevika Microfinance Yojana', 'AMY', 'NBFC-MFI channel for small projects', 0, 140000, 125000, 15.0, 36, 3, ARRAY['NBFC-MFI'])
ON CONFLICT (code) DO NOTHING;

-- ============================================
-- SEED DATA: PARTNERS (PostGIS coordinates)
-- ============================================
INSERT INTO partners (name, type, address, phone, email, location, fund_utilization, npa_rate, is_eligible, supported_schemes) VALUES
('Tamil Nadu SC Finance Corporation', 'SCA', '123, Anna Salai, Chennai - 600001', '044-12345678', 'contact@tnscfc.in', ST_SetSRID(ST_MakePoint(80.2707, 13.0827), 4326), 82.5, 6.2, true, ARRAY[1, 2]),
('State Bank of India - Chennai Main', 'PSB', '456, Rajaji Salai, Chennai - 600001', '044-87654321', 'chennai.main@sbi.co.in', ST_SetSRID(ST_MakePoint(80.2800, 13.0900), 4326), 85.0, 5.1, true, ARRAY[1, 2, 3]),
('Canara Bank - T Nagar', 'PSB', '789, North Usman Road, Chennai - 600017', '044-24345678', 'tnagar@canarabank.com', ST_SetSRID(ST_MakePoint(80.2350, 13.0390), 4326), 78.0, 7.2, false, ARRAY[1, 2]),
('India Bank - Adyar', 'PSB', '321, LB Road, Adyar, Chennai - 600020', '044-24456789', 'adyar@indiabank.co.in', ST_SetSRID(ST_MakePoint(80.2560, 13.0060), 4326), 90.0, 4.5, true, ARRAY[1, 2, 3]),
('TN Rural Livelihoods SCA', 'SCA', '456, Salai Road, Madurai - 625001', '0452-2345678', 'contact@tnrls.in', ST_SetSRID(ST_MakePoint(78.1198, 9.9252), 4326), 88.0, 3.8, true, ARRAY[1, 2]),
('Indian Overseas Bank - Coimbatore', 'PSB', '101, DB Road, Coimbatore - 641002', '0422-2345678', 'cbe@iob.co.in', ST_SetSRID(ST_MakePoint(76.9558, 11.0085), 4326), 92.0, 5.5, true, ARRAY[1, 2, 3]),
('Puduvai Bharathiar Grama Bank', 'RRB', '22, Lawspet, Puducherry - 605004', '0413-2345678', 'contact@pbgb.in', ST_SetSRID(ST_MakePoint(79.8083, 11.9416), 4326), 85.0, 12.0, true, ARRAY[1, 2]),
('Sahaj MFIN Pvt Ltd', 'NBFC-MFI', '78, 100 Feet Road, Nungambakkam, Chennai', '044-34567890', 'info@sahaj.in', ST_SetSRID(ST_MakePoint(80.2475, 13.0625), 4326), 95.0, 2.1, true, ARRAY[4]),
('Serv-Micro Finance', 'NBFC-MFI', '45, Gandhi Nagar, Madurai - 625002', '0452-4567890', 'info@serv.in', ST_SetSRID(ST_MakePoint(78.1198, 9.9312), 4326), 91.0, 2.8, true, ARRAY[4]),
('Ujjivan Small Finance Bank', 'NBFC-MFI', '33, Pondy Bazaar, T Nagar, Chennai', '044-5678901', 'chennai@ujjivan.com', ST_SetSRID(ST_MakePoint(80.2380, 13.0400), 4326), 88.5, 1.9, true, ARRAY[4])
ON CONFLICT DO NOTHING;
