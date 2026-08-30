# Surakshit — Priority Sector Lending Platform

> An AI-driven platform for scheme matching, financial calculation, and partner discovery for marginalized entrepreneurs under the Priority Sector Lending framework.

## Architecture

```
                    SURAKSHIT
                       │
              ┌────────┴────────┐
              │                 │
        ENTREPRENEUR          ADMIN
              │                 │
              ▼                 ▼
         PROFILE          ANALYTICS
              │
              ▼
      ELIGIBILITY ENGINE
              │
              ▼
       SCHEME MATCHING
              │
       ┌──────┼──────┐
       ▼      ▼      ▼
    Scheme  Finance Partner
    Match   Calc.   Match
       │      │      │
       └──────┼──────┘
              ▼
       APPLICATION
          TRACKER
```

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | React 18 + TypeScript + Vite + Tailwind CSS + Recharts + Leaflet |
| **Backend** | Node.js + Express |
| **Database** | SQLite (dev) / PostgreSQL + PostGIS (production) |
| **Authentication** | JWT + bcrypt |
| **Maps** | Leaflet + OpenStreetMap |

## Features

### Core Modules

1. **Scheme Recommendation Engine** — Rule-based matching that recommends the best government scheme based on project type, cost, channel preference, and income
2. **Financial Calculator** — EMI calculation with amortization schedule, moratorium support, and yearly repayment breakdown with charts
3. **Partner Locator** — 15 channel partners across India with real Leaflet map, eligibility status (fund utilization & NPA rate), and filter by type (SCA/PSB/RRB/NBFC-MFI)
4. **Application Tracker** — 8-stage pipeline tracking from draft through disbursement with progress visualization
5. **JWT Authentication** — Aadhaar-based login with role-based access control

### Scheme Database

| Scheme | Code | Max Loan | Interest | Tenure |
|--------|------|----------|----------|--------|
| Micro Finance Scheme | MFS | ₹1.25L | 6.5% | 3yr |
| Term Loan | TL | ₹45L | 8.0% | 7yr |
| Educational Loan | ELS | ₹40L | 6.5% | 12yr |
| Stand-Up India | SUI | ₹1Cr | 9.5% | 10yr |
| PM Mudra - Shishu | PMY-S | ₹50K | 10.0% | 5yr |
| PM Mudra - Kishore | PMY-K | ₹5L | 10.0% | 7yr |
| PM Mudra - Tarun | PMY-T | ₹10L | 10.0% | 7yr |
| SC/ST Hub | SCST-H | ₹18L | 5.0% | 7yr |
| Artisan Credit Card | ACC | ₹1.8L | 7.0% | 5yr |
| Aajeevika Microfinance | AMY | ₹1.25L | 15.0% | 3yr |

### Partner Eligibility Rules

- **Fund Utilization** ≥ 80% required
- **RRB**: NPA rate must be < 15%
- **NBFC-MFI**: NPA rate must be < 3%

## Project Structure

```
surakshit/
├── backend/                      # Node.js + Express API
│   ├── src/
│   │   ├── config/database.js    # SQLite/PostgreSQL config
│   │   ├── middleware/auth.js    # JWT authentication
│   │   ├── routes/               # API routes
│   │   ├── services/             # Business logic
│   │   └── server.js             # Entry point
│   ├── database/
│   │   ├── docker-compose.yml    # PostgreSQL + PostGIS
│   │   ├── schema/               # SQL schemas + seed data
│   │   └── seed.js               # SQLite seed script
│   └── package.json
│
├── web/                          # React frontend
│   ├── src/
│   │   ├── components/           # Layout
│   │   ├── context/              # Auth context
│   │   ├── pages/                # All pages
│   │   ├── services/             # API calls
│   │   └── types/                # TypeScript types
│   ├── serve.py                  # Static server + API proxy
│   └── package.json
│
├── mobile/                       # Flutter mobile app (planned)
└── docker-compose.yml            # Full stack orchestration
```

## Quick Start

### Prerequisites
- Node.js 18+
- Python 3.x (for frontend server)

### 1. Install & Seed Backend
```bash
cd backend
npm install
node database/seed.js
```

### 2. Start Backend
```bash
node src/server.js
# API runs at http://localhost:5000
```

### 3. Build & Start Frontend
```bash
cd web
npm install
npx vite build
python serve.py
# Web runs at http://localhost:3000
```

### Demo Accounts

| Aadhaar Hash | Name | Role |
|-------------|------|------|
| `demo1` | Priya Sharma | Entrepreneur |
| `demo2` | Ravi Kumar | Entrepreneur |
| `demo3` | Anita Devi | Entrepreneur |
| `demo4` | Suresh Patel | Entrepreneur |

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/login` | Login with Aadhaar hash |
| GET | `/api/schemes` | List all schemes |
| POST | `/api/schemes/recommend` | Get scheme recommendation |
| GET | `/api/partners` | List all partners |
| GET | `/api/partners/nearby` | Find nearest partners |
| GET | `/api/applications` | List user applications |
| POST | `/api/applications` | Create application |
| POST | `/api/applications/:id/submit` | Submit application |
| POST | `/api/calculate` | Calculate loan EMI |

## Production Deployment

For production with PostgreSQL + PostGIS:

```bash
cd backend/database
docker-compose up -d
# Update DATABASE_URL in .env to point to PostgreSQL
```

The PostgreSQL schema includes:
- PostGIS spatial indexing for partner proximity queries
- Full ACID compliance
- GiST indexes for geospatial queries

## License

Built for SIH (Smart India Hackathon) — Priority Sector Lending challenge.
