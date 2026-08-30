const db = require('../src/config/database');

console.log('Seeding database...');

// Clear existing data
db.exec('DELETE FROM application_status_history');
db.exec('DELETE FROM applications');
db.exec('DELETE FROM partners');
db.exec('DELETE FROM schemes');
db.exec('DELETE FROM users');

// Seed Users
const insertUser = db.prepare(
    'INSERT INTO users (aadhaar_hash, name, email, phone, income, caste_category, education) VALUES (?, ?, ?, ?, ?, ?, ?)'
);

const users = [
    ['demo1', 'Priya Sharma', 'priya@example.com', '9876543210', 280000, 'SC', 'Graduate'],
    ['demo2', 'Ravi Kumar', 'ravi@example.com', '9876543211', 350000, 'OBC', 'Post-Graduate'],
    ['demo3', 'Anita Devi', 'anita@example.com', '9876543212', 180000, 'SC', 'Secondary'],
    ['demo4', 'Suresh Patel', 'suresh@example.com', '9876543213', 450000, 'General', 'Graduate'],
];

users.forEach(u => insertUser.run(...u));
console.log(`Inserted ${users.length} users`);

// Seed Schemes
const insertScheme = db.prepare(
    `INSERT INTO schemes (name, code, description, min_cost, max_cost, max_loan, interest_rate, max_tenure_months, moratorium_months, channel_types) 
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
);

const schemes = [
    ['Micro Finance Scheme', 'MFS', 'For small projects up to ₹1.40 lakh. Ideal for micro-enterprises and self-employment ventures.', 0, 140000, 125000, 6.5, 36, 3, 'SCA,PSB,RRB'],
    ['Term Loan', 'TL', 'For projects from ₹1.40 lakh to ₹50 lakh. Suitable for business expansion and new ventures.', 140001, 5000000, 4500000, 8.0, 84, 6, 'SCA,PSB,RRB'],
    ['Educational Loan Scheme', 'ELS', 'For higher education expenses up to ₹40 lakh. Covers tuition, hostel, and other educational costs.', 0, 4000000, 4000000, 6.5, 144, 12, 'SCA,PSB,RRB'],
    ['Aajeevika Microfinance Yojana', 'AMY', 'NBFC-MFI channel for small projects up to ₹1.40 lakh. Quick processing through microfinance institutions.', 0, 140000, 125000, 15.0, 36, 3, 'NBFC-MFI'],
    ['Stand-Up India Loan', 'SUI', 'For SC/ST and women entrepreneurs for greenfield enterprises. Loan from ₹10 lakh to ₹1 crore.', 1000000, 10000000, 10000000, 9.5, 120, 18, 'SCA,PSB'],
    ['PM Mudra Yojana - Shishu', 'PMY-S', 'Up to ₹50,000 for micro enterprises in the nascent stage.', 0, 50000, 50000, 10.0, 60, 3, 'SCA,PSB,RRB,NBFC-MFI'],
    ['PM Mudra Yojana - Kishore', 'PMY-K', '₹50,001 to ₹5 lakh for established micro enterprises.', 50001, 500000, 500000, 10.0, 84, 6, 'SCA,PSB,RRB,NBFC-MFI'],
    ['PM Mudra Yojana - Tarun', 'PMY-T', '₹5 lakh to ₹10 lakh for well-established enterprises.', 500001, 1000000, 1000000, 10.0, 84, 6, 'SCA,PSB,RRB'],
    ['SC/ST Hub Scheme', 'SCST-H', 'Special scheme for SC/ST entrepreneurs with subsidized interest rates and flexible repayment.', 0, 2000000, 1800000, 5.0, 84, 12, 'SCA'],
    ['Artisan Credit Card', 'ACC', 'For traditional artisans and craftspeople. Quick processing and low documentation.', 0, 200000, 180000, 7.0, 60, 3, 'SCA,PSB,RRB'],
];

schemes.forEach(s => insertScheme.run(...s));
console.log(`Inserted ${schemes.length} schemes`);

// Seed Partners (Indian cities)
const insertPartner = db.prepare(
    `INSERT INTO partners (name, type, address, phone, email, latitude, longitude, fund_utilization, npa_rate, is_eligible, supported_schemes) 
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
);

const partners = [
    ['Tamil Nadu SC Finance Corporation', 'SCA', '123, Anna Salai, Chennai - 600001', '044-12345678', 'contact@tnscfc.in', 13.0827, 80.2707, 82.5, 6.2, 1, '1,2,5,9'],
    ['State Bank of India - Chennai Main', 'PSB', '456, Rajaji Salai, Chennai - 600001', '044-87654321', 'chennai.main@sbi.co.in', 13.0900, 80.2800, 85.0, 5.1, 1, '1,2,3,6,7,8'],
    ['Canara Bank - T Nagar', 'PSB', '789, North Usman Road, Chennai - 600017', '044-24345678', 'tnagar@canarabank.com', 13.0390, 80.2350, 78.0, 7.2, 0, '1,2,3,6,7'],
    ['Andhra Pradesh SC Finance Corp', 'SCA', '10 MG Road, Vijayawada - 520001', '0866-1234567', 'info@apscfc.in', 16.5062, 80.6480, 88.3, 4.5, 1, '1,2,5,9'],
    ['SBI - Bangalore Main', 'PSB', '21, MG Road, Bangalore - 560001', '080-87654321', 'bangalore.main@sbi.co.in', 12.9716, 77.5946, 91.2, 3.8, 1, '1,2,3,6,7,8'],
    ['Karnataka Grameena Vikas Bank', 'RRB', '5, Station Road, Hubli - 580020', '0836-2345678', 'info@kgvb.in', 15.3647, 75.1240, 82.0, 8.5, 1, '1,2,6,7'],
    ['HDFC Bank - Hyderabad', 'PSB', '100, Banjara Hills, Hyderabad - 500034', '040-67890123', 'hyderabad@hdfcbank.com', 17.3850, 78.4867, 95.0, 2.1, 1, '1,2,3,6,7,8'],
    ['Kerala SC Development Finance', 'SCA', '50, MG Road, Thiruvananthapuram - 695001', '0471-3456789', 'info@kscdf.in', 8.5241, 76.9366, 87.0, 5.3, 1, '1,2,5,9'],
    ['IDBI Bank - Cochin', 'PSB', '25, Market Road, Kochi - 682011', '0484-4567890', 'cochin@idbi.co.in', 9.9312, 76.2673, 89.5, 4.1, 1, '1,2,3,6,7,8'],
    ['Mizo Rural Bank', 'RRB', '12, Aizawl Bazaar, Aizawl - 796001', '0389-5678901', 'info@mizoruralbank.in', 23.7271, 92.7176, 75.0, 12.0, 0, '1,2,6,7'],
    ['Bihar SC Finance Corporation', 'SCA', '30, Gandhi Maidan, Patna - 800001', '0612-6789012', 'info@bscfc.in', 25.6093, 85.1376, 84.0, 6.8, 1, '1,2,5,9'],
    ['Punjab National Bank - Delhi', 'PSB', '7, Parliament Street, New Delhi - 110001', '011-78901234', 'delhi@pnbindia.in', 28.6139, 77.2090, 93.0, 3.5, 1, '1,2,3,6,7,8'],
    ['Gujarat SC Finance Board', 'SCA', '45, Ashram Road, Ahmedabad - 380009', '079-89012345', 'info@gsfc.in', 23.0225, 72.5714, 86.5, 5.0, 1, '1,2,5,9'],
    ['UCO Bank - Kolkata', 'PSB', '10, BTM Sarani, Kolkata - 700001', '033-90123456', 'kolkata@ucobank.co.in', 22.5726, 88.3639, 80.5, 7.0, 1, '1,2,3,6,7,8'],
    ['Assam Gramin Vikash Bank', 'RRB', '15, Fancy Bazaar, Guwahati - 781001', '0361-0123456', 'info@agvb.in', 26.1445, 91.7362, 79.0, 10.5, 0, '1,2,6,7'],
];

partners.forEach(p => insertPartner.run(...p));
console.log(`Inserted ${partners.length} partners`);

// Seed Applications
const insertApp = db.prepare(
    `INSERT INTO applications (user_id, scheme_id, partner_id, project_type, project_cost, loan_amount, status, current_stage) 
     VALUES (?, ?, ?, ?, ?, ?, ?, ?)`
);

const insertHistory = db.prepare(
    `INSERT INTO application_status_history (application_id, stage, status, notes) VALUES (?, ?, ?, ?)`
);

// Priya's applications
const app1 = insertApp.run(1, 1, 1, 'Business', 120000, 110000, 'submitted', 'SCA_DISTRICT');
insertHistory.run(app1.lastInsertRowid, 'DRAFT', 'created', 'Application drafted');
insertHistory.run(app1.lastInsertRowid, 'SCA_DISTRICT', 'submitted', 'Submitted to district SCA');

const app2 = insertApp.run(1, 7, 2, 'Business', 350000, 300000, 'under_review', 'SCA_HEAD');
insertHistory.run(app2.lastInsertRowid, 'DRAFT', 'created', 'Application drafted');
insertHistory.run(app2.lastInsertRowid, 'SCA_DISTRICT', 'submitted', 'Submitted');
insertHistory.run(app2.lastInsertRowid, 'SCA_HEAD', 'forwarded', 'Forwarded to SCA Head Office');

// Ravi's application
const app3 = insertApp.run(2, 2, 5, 'Agriculture', 2500000, 2200000, 'approved', 'LOI');
insertHistory.run(app3.lastInsertRowid, 'DRAFT', 'created', 'Application drafted');
insertHistory.run(app3.lastInsertRowid, 'SCA_DISTRICT', 'submitted', 'Submitted');
insertHistory.run(app3.lastInsertRowid, 'SCA_HEAD', 'forwarded', 'Forwarded to SCA Head');
insertHistory.run(app3.lastInsertRowid, 'NSFDC_DESK', 'verified', 'Verified by NSFDC desk');
insertHistory.run(app3.lastInsertRowid, 'PCC', 'approved', 'Approved by PCC');
insertHistory.run(app3.lastInsertRowid, 'CMD', 'approved', 'Approved by CMD');
insertHistory.run(app3.lastInsertRowid, 'LOI', 'issued', 'Letter of Intent issued');

// Anita's application
const app4 = insertApp.run(3, 6, 1, 'Business', 45000, 45000, 'draft', null);
insertHistory.run(app4.lastInsertRowid, 'DRAFT', 'created', 'Application drafted');

console.log(`Inserted 4 applications`);

console.log('Database seeded successfully!');
console.log('\nDemo login aadhaar_hash values:');
console.log('  Priya:   demo1');
console.log('  Ravi:    demo2');
console.log('  Anita:   demo3');
console.log('  Suresh:  demo4');
