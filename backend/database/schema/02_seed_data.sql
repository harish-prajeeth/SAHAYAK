-- ============================================
-- SEED DATA: SCHEMES (10 total)
-- ============================================
INSERT INTO schemes (name, code, description, min_cost, max_cost, max_loan, interest_rate, max_tenure_months, moratorium_months, channel_types) VALUES
('Micro Finance Scheme', 'MFS', 'For small projects up to ₹1.40 lakh. Ideal for micro-enterprises and self-employment ventures.', 0, 140000, 125000, 6.5, 36, 3, ARRAY['SCA', 'PSB', 'RRB']),
('Term Loan', 'TL', 'For projects from ₹1.40 lakh to ₹50 lakh. Suitable for business expansion and new ventures.', 140001, 5000000, 4500000, 8.0, 84, 6, ARRAY['SCA', 'PSB', 'RRB']),
('Educational Loan Scheme', 'ELS', 'For higher education expenses up to ₹40 lakh. Covers tuition, hostel, and other educational costs.', 0, 4000000, 4000000, 6.5, 144, 12, ARRAY['SCA', 'PSB', 'RRB']),
('Aajeevika Microfinance Yojana', 'AMY', 'NBFC-MFI channel for small projects up to ₹1.40 lakh. Quick processing through microfinance institutions.', 0, 140000, 125000, 15.0, 36, 3, ARRAY['NBFC-MFI']),
('Stand-Up India Loan', 'SUI', 'For SC/ST and women entrepreneurs for greenfield enterprises. Loan from ₹10 lakh to ₹1 crore.', 1000000, 10000000, 10000000, 9.5, 120, 18, ARRAY['SCA', 'PSB']),
('PM Mudra Yojana - Shishu', 'PMY-S', 'Up to ₹50,000 for micro enterprises in the nascent stage.', 0, 50000, 50000, 10.0, 60, 3, ARRAY['SCA', 'PSB', 'RRB', 'NBFC-MFI']),
('PM Mudra Yojana - Kishore', 'PMY-K', '₹50,001 to ₹5 lakh for established micro enterprises.', 50001, 500000, 500000, 10.0, 84, 6, ARRAY['SCA', 'PSB', 'RRB', 'NBFC-MFI']),
('PM Mudra Yojana - Tarun', 'PMY-T', '₹5 lakh to ₹10 lakh for well-established enterprises.', 500001, 1000000, 1000000, 10.0, 84, 6, ARRAY['SCA', 'PSB', 'RRB']),
('SC/ST Hub Scheme', 'SCST-H', 'Special scheme for SC/ST entrepreneurs with subsidized interest rates and flexible repayment.', 0, 2000000, 1800000, 5.0, 84, 12, ARRAY['SCA']),
('Artisan Credit Card', 'ACC', 'For traditional artisans and craftspeople. Quick processing and low documentation.', 0, 200000, 180000, 7.0, 60, 3, ARRAY['SCA', 'PSB', 'RRB'])
ON CONFLICT (code) DO NOTHING;

-- ============================================
-- SEED DATA: PARTNERS (15 total, PostGIS)
-- ============================================
INSERT INTO partners (name, type, address, phone, email, location, fund_utilization, npa_rate, is_eligible, supported_schemes) VALUES
('Tamil Nadu SC Finance Corporation', 'SCA', '123, Anna Salai, Chennai - 600001', '044-12345678', 'contact@tnscfc.in', ST_SetSRID(ST_MakePoint(80.2707, 13.0827), 4326), 82.5, 6.2, true, ARRAY['MFS','TL','SUI','SCST-H']),
('State Bank of India - Chennai Main', 'PSB', '456, Rajaji Salai, Chennai - 600001', '044-87654321', 'chennai.main@sbi.co.in', ST_SetSRID(ST_MakePoint(80.2800, 13.0900), 4326), 85.0, 5.1, true, ARRAY['MFS','TL','ELS','PMY-S','PMY-K','PMY-T']),
('Canara Bank - T Nagar', 'PSB', '789, North Usman Road, Chennai - 600017', '044-24345678', 'tnagar@canarabank.com', ST_SetSRID(ST_MakePoint(80.2350, 13.0390), 4326), 78.0, 7.2, false, ARRAY['MFS','TL','ELS','PMY-S','PMY-K']),
('Andhra Pradesh SC Finance Corp', 'SCA', '10 MG Road, Vijayawada - 520001', '0866-1234567', 'info@apscfc.in', ST_SetSRID(ST_MakePoint(80.6480, 16.5062), 4326), 88.3, 4.5, true, ARRAY['MFS','TL','SUI','SCST-H']),
('SBI - Bangalore Main', 'PSB', '21, MG Road, Bangalore - 560001', '080-87654321', 'bangalore.main@sbi.co.in', ST_SetSRID(ST_MakePoint(77.5946, 12.9716), 4326), 91.2, 3.8, true, ARRAY['MFS','TL','ELS','PMY-S','PMY-K','PMY-T']),
('Karnataka Grameena Vikas Bank', 'RRB', '5, Station Road, Hubli - 580020', '0836-2345678', 'info@kgvb.in', ST_SetSRID(ST_MakePoint(75.1240, 15.3647), 4326), 82.0, 8.5, true, ARRAY['MFS','TL','PMY-S','PMY-K']),
('HDFC Bank - Hyderabad', 'PSB', '100, Banjara Hills, Hyderabad - 500034', '040-67890123', 'hyderabad@hdfcbank.com', ST_SetSRID(ST_MakePoint(78.4867, 17.3850), 4326), 95.0, 2.1, true, ARRAY['MFS','TL','ELS','PMY-S','PMY-K','PMY-T']),
('Kerala SC Development Finance', 'SCA', '50, MG Road, Thiruvananthapuram - 695001', '0471-3456789', 'info@kscdf.in', ST_SetSRID(ST_MakePoint(76.9366, 8.5241), 4326), 87.0, 5.3, true, ARRAY['MFS','TL','SUI','SCST-H']),
('IDBI Bank - Cochin', 'PSB', '25, Market Road, Kochi - 682011', '0484-4567890', 'cochin@idbi.co.in', ST_SetSRID(ST_MakePoint(76.2673, 9.9312), 4326), 89.5, 4.1, true, ARRAY['MFS','TL','ELS','PMY-S','PMY-K','PMY-T']),
('Mizo Rural Bank', 'RRB', '12, Aizawl Bazaar, Aizawl - 796001', '0389-5678901', 'info@mizoruralbank.in', ST_SetSRID(ST_MakePoint(92.7176, 23.7271), 4326), 75.0, 12.0, false, ARRAY['MFS','TL','PMY-S','PMY-K']),
('Bihar SC Finance Corporation', 'SCA', '30, Gandhi Maidan, Patna - 800001', '0612-6789012', 'info@bscfc.in', ST_SetSRID(ST_MakePoint(85.1376, 25.6093), 4326), 84.0, 6.8, true, ARRAY['MFS','TL','SUI','SCST-H']),
('Punjab National Bank - Delhi', 'PSB', '7, Parliament Street, New Delhi - 110001', '011-78901234', 'delhi@pnbindia.in', ST_SetSRID(ST_MakePoint(77.2090, 28.6139), 4326), 93.0, 3.5, true, ARRAY['MFS','TL','ELS','PMY-S','PMY-K','PMY-T']),
('Gujarat SC Finance Board', 'SCA', '45, Ashram Road, Ahmedabad - 380009', '079-89012345', 'info@gsfc.in', ST_SetSRID(ST_MakePoint(72.5714, 23.0225), 4326), 86.5, 5.0, true, ARRAY['MFS','TL','SUI','SCST-H']),
('UCO Bank - Kolkata', 'PSB', '10, BTM Sarani, Kolkata - 700001', '033-90123456', 'kolkata@ucobank.co.in', ST_SetSRID(ST_MakePoint(88.3639, 22.5726), 4326), 80.5, 7.0, true, ARRAY['MFS','TL','ELS','PMY-S','PMY-K','PMY-T']),
('Assam Gramin Vikash Bank', 'RRB', '15, Fancy Bazaar, Guwahati - 781001', '0361-0123456', 'info@agvb.in', ST_SetSRID(ST_MakePoint(91.7362, 26.1445), 4326), 79.0, 10.5, false, ARRAY['MFS','TL','PMY-S','PMY-K'])
ON CONFLICT DO NOTHING;

-- ============================================
-- SEED DATA: USERS
-- ============================================
INSERT INTO users (aadhaar_hash, name, email, phone, income, caste_category, education) VALUES
('demo1', 'Priya Sharma', 'priya@example.com', '9876543210', 280000, 'SC', 'Graduate'),
('demo2', 'Ravi Kumar', 'ravi@example.com', '9876543211', 350000, 'OBC', 'Post-Graduate'),
('demo3', 'Anita Devi', 'anita@example.com', '9876543212', 180000, 'SC', 'Secondary'),
('demo4', 'Suresh Patel', 'suresh@example.com', '9876543213', 450000, 'General', 'Graduate')
ON CONFLICT (aadhaar_hash) DO NOTHING;

-- ============================================
-- SEED DATA: APPLICATIONS
-- ============================================
INSERT INTO applications (user_id, scheme_id, partner_id, project_type, project_cost, loan_amount, status, current_stage) VALUES
(1, 1, 1, 'Business', 120000, 110000, 'submitted', 'SCA_DISTRICT'),
(1, 7, 2, 'Business', 350000, 300000, 'under_review', 'SCA_HEAD'),
(2, 2, 5, 'Agriculture', 2500000, 2200000, 'approved', 'LOI'),
(3, 6, 1, 'Business', 45000, 45000, 'draft', NULL)
ON CONFLICT DO NOTHING;

-- ============================================
-- SEED DATA: APPLICATION STATUS HISTORY
-- ============================================
INSERT INTO application_status_history (application_id, stage, status, notes) VALUES
-- App 1: Priya's Micro Finance (submitted)
(1, 'DRAFT', 'created', 'Application drafted'),
(1, 'SCA_DISTRICT', 'submitted', 'Submitted to district SCA'),
-- App 2: Priya's PM Mudra Kishore (under review)
(2, 'DRAFT', 'created', 'Application drafted'),
(2, 'SCA_DISTRICT', 'submitted', 'Submitted'),
(2, 'SCA_HEAD', 'forwarded', 'Forwarded to SCA Head Office'),
-- App 3: Ravi's Term Loan (approved - LOI stage)
(3, 'DRAFT', 'created', 'Application drafted'),
(3, 'SCA_DISTRICT', 'submitted', 'Submitted'),
(3, 'SCA_HEAD', 'forwarded', 'Forwarded to SCA Head'),
(3, 'NSFDC_DESK', 'verified', 'Verified by NSFDC desk'),
(3, 'PCC', 'approved', 'Approved by PCC'),
(3, 'CMD', 'approved', 'Approved by CMD'),
(3, 'LOI', 'issued', 'Letter of Intent issued'),
-- App 4: Anita's PM Mudra Shishu (draft)
(4, 'DRAFT', 'created', 'Application drafted');
