# 📊 Tax Forms Processor - Ecuador

> Professional tax document processing system for Ecuadorian businesses. Automatically extracts, analyzes, and organizes data from SRI Forms 103 (Retenciones) and 104 (IVA).

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Python](https://img.shields.io/badge/Python-3.11+-blue)](https://www.python.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.104+-green)](https://fastapi.tiangolo.com/)
[![Next.js](https://img.shields.io/badge/Next.js-14+-black)](https://nextjs.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-blue)](https://www.postgresql.org/)

---

## 🎯 **Overview**

Tax Forms Processor is a full-stack web application designed to streamline tax compliance for Ecuadorian businesses. Upload PDF tax documents, and the system automatically extracts, processes, and organizes all relevant data.

### **Key Features**

✅ **Automated PDF Processing** - Upload Form 103 & 104 PDFs and extract data automatically  
✅ **Client Management** - Organize documents by company (razón social) and year  
✅ **Yearly Summaries** - Automatic calculation of annual totals and accumulations  
✅ **Professional Exports** - Generate Excel and branded PDF reports  
✅ **Guest Mode** - Process up to 5 documents without registration  
✅ **User Isolation** - Complete data privacy for registered users  
✅ **Analytics Dashboard** - Track visitors, uploads, and usage statistics (admin only)  
✅ **Mobile Responsive** - Works beautifully on all devices  
✅ **Dark Mode** - Professional dark theme with proper contrast  

---

## 🏗️ **Architecture**

### **Tech Stack**

**Backend:**
- **FastAPI** - Modern Python web framework
- **PostgreSQL** - Reliable database
- **pdfplumber** - PDF text extraction
- **SQLAlchemy** - ORM for database operations
- **Bcrypt** - Secure password hashing

**Frontend:**
- **Next.js 14** - React framework with App Router
- **TypeScript** - Type-safe development
- **Tailwind CSS** - Utility-first styling
- **Recharts** - Beautiful analytics charts
- **Lucide Icons** - Modern icon set

**DevOps:**
- **Docker** - Containerization
- **Railway** - Cloud hosting platform
- **GitHub Actions** - CI/CD (optional)

### **System Architecture**

```
┌─────────────┐      ┌──────────────┐      ┌────────────┐
│   Next.js   │ ───▶ │   FastAPI    │ ───▶ │ PostgreSQL │
│  (Frontend) │      │  (Backend)   │      │ (Database) │
└─────────────┘      └──────────────┘      └────────────┘
       │                     │                     │
       │                     │                     │
       ▼                     ▼                     ▼
  User Session         PDF Processing        Data Storage
  Authentication       Regex Extraction      User Isolation
  React Components     Form Parsing          JSONB Fields
```

---

## 🚀 **Quick Start**

### **Prerequisites**

- **Docker** and **Docker Compose** installed
- **Node.js 18+** (for local frontend development)
- **Python 3.11+** (for local backend development)
- **PostgreSQL 15+** (or use Docker)

### **Installation**

#### **1. Clone the repository**
```bash
git clone https://github.com/CapBraco/tax-forms-processor.git
cd tax-forms-processor
```

#### **2. Set up environment variables**

Create `.env` file in `backend/`:
```env
# Database
DATABASE_URL=postgresql://postgres:password@localhost:5432/pdf_extractor_db

# Security
SECRET_KEY=your-secret-key-here-min-32-characters

# Frontend URL (for CORS)
FRONTEND_URL=http://localhost:3000

# Backend URL
BACKEND_URL=http://localhost:8000
```

Create `.env.local` file in `frontend/`:
```env
NEXT_PUBLIC_API_URL=http://localhost:8000
NEXT_PUBLIC_SITE_URL=http://localhost:3000
```

#### **3. Database Setup** (CRITICAL)

**Choose ONE of the following methods:**

##### **Method A: Complete Schema Migration (RECOMMENDED)**

This applies the complete, production-ready schema in one step:

```bash
# Create the database
psql -U postgres -c "CREATE DATABASE pdf_extractor_db;"

# Apply the complete schema
psql -U postgres -d pdf_extractor_db -f backend/migrations/complete_schema.sql
```

The `complete_schema.sql` file includes:
- All 10 tables with correct structure
- All ENUM types (formtypeenum, processingstatusenum)
- All indexes and foreign keys
- Default values and constraints

##### **Method B: Incremental Migrations**

Apply migrations in strict order:

```bash
# Create the database
psql -U postgres -c "CREATE DATABASE pdf_extractor_db;"

# Run migrations in order (DO NOT SKIP ANY)
psql -U postgres -d pdf_extractor_db -f backend/migrations/001_initial_schema.sql
psql -U postgres -d pdf_extractor_db -f backend/migrations/002_add_user_isolation.sql
psql -U postgres -d pdf_extractor_db -f backend/migrations/003_add_form_104_fields.sql
psql -U postgres -d pdf_extractor_db -f backend/migrations/004_add_analytics.sql
```

⚠️ **IMPORTANT**: Do NOT run migrations out of order or skip any!

##### **Method C: Docker Compose (Automatic)**

```bash
# This automatically creates the database with complete schema
docker-compose up -d

# Verify the database was created correctly
docker-compose exec db psql -U postgres -d pdf_extractor_db -c "\dt"
```

#### **4. Verify Database Schema**

After creating the database, verify all tables exist:

```bash
psql -U postgres -d pdf_extractor_db -c "
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;"
```

Expected tables:
- `documents` (25 columns)
- `form_103_data`
- `form_103_line_items`
- `form_103_totals`
- `form_104_data` (130+ columns)
- `guest_sessions`
- `temporary_files`
- `usage_analytics`
- `users`

#### **5. Start the Application**

**Using Docker Compose (Recommended):**
```bash
docker-compose up -d
```

**OR manually:**

**Backend:**
```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
uvicorn main:app --reload
```

**Frontend:**
```bash
cd frontend
npm install
npm run dev
```

#### **6. Access the Application**

- Frontend: http://localhost:3000
- Backend API: http://localhost:8000
- API Docs: http://localhost:8000/docs

---

## 🔧 **Database Schema Details**

### **Complete Table List**

| Table | Columns | Purpose |
|-------|---------|---------|
| `documents` | 25 | Main document metadata |
| `form_103_data` | 10 | Form 103 extracted data |
| `form_103_line_items` | 9 | Line-by-line Form 103 details |
| `form_103_totals` | 12 | Form 103 totals and summaries |
| `form_104_data` | 133 | Complete Form 104 data (7 sections) |
| `guest_sessions` | 7 | Guest user session tracking |
| `temporary_files` | 6 | Temporary file management |
| `usage_analytics` | 6 | Analytics event tracking |
| `users` | 11 | User accounts and authentication |

### **Critical Columns**

#### **documents table:**
- `form_type` (ENUM: 'FORM_103', 'FORM_104', 'UNKNOWN')
- `processing_status` (ENUM: 'PENDING', 'PROCESSING', 'COMPLETED', 'FAILED')
- `user_id` (Foreign key to users)
- `session_id` (For guest users)
- `razon_social` (Company name)
- `periodo_fiscal_completo` (Full period: "ENERO 2025")

#### **form_104_data table:**
All 133 fields including:
- `ventas_tarifa_diferente_cero_bruto`
- `ventas_tarifa_diferente_cero_neto`
- `impuesto_generado`
- Plus 130+ more financial fields

#### **users table:**
- `username` (Unique)
- `email` (Unique)
- `hashed_password`
- `last_login` (TIMESTAMP)
- `is_active` (Boolean)

#### **temporary_files table:**
- `session_id`
- `file_path`
- `file_size` (BIGINT)
- `expires_at`

---

## ⚠️ **Common Issues & Troubleshooting**

### **Issue 1: "Column does not exist" errors**

**Symptom:**
```
column "last_login" of relation "users" does not exist
column "file_size" of relation "temporary_files" does not exist
```

**Cause:** Incomplete database migration or running migrations out of order.

**Solution:**
```bash
# Option A: Start fresh with complete schema
psql -U postgres -c "DROP DATABASE pdf_extractor_db;"
psql -U postgres -c "CREATE DATABASE pdf_extractor_db;"
psql -U postgres -d pdf_extractor_db -f backend/migrations/complete_schema.sql

# Option B: Check and add missing columns individually
psql -U postgres -d pdf_extractor_db -c "
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_login TIMESTAMP WITH TIME ZONE;
ALTER TABLE temporary_files ADD COLUMN IF NOT EXISTS file_size BIGINT;
"
```

### **Issue 2: "ENUM type does not exist" errors**

**Symptom:**
```
type "formtypeenum" does not exist
type "processingstatusenum" does not exist
```

**Solution:**
```bash
# Create ENUM types
psql -U postgres -d pdf_extractor_db -c "
CREATE TYPE formtypeenum AS ENUM ('FORM_103', 'FORM_104', 'UNKNOWN');
CREATE TYPE processingstatusenum AS ENUM ('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED');
"
```

### **Issue 3: "Table does not exist" errors**

**Symptom:**
```
relation "form_103_totals" does not exist
relation "form_103_line_items" does not exist
```

**Cause:** Missing migrations or incomplete schema.

**Solution:** Apply the complete schema migration (see Installation Step 3).

### **Issue 4: Form 104 processing fails**

**Symptom:** Form 103 works but Form 104 fails with column errors.

**Cause:** The `form_104_data` table has 133 columns and is often incomplete.

**Solution:**
```bash
# Verify form_104_data table structure
psql -U postgres -d pdf_extractor_db -c "\d form_104_data"

# If columns are missing, reapply the complete schema
psql -U postgres -d pdf_extractor_db -f backend/migrations/complete_schema.sql
```

### **Issue 5: Railway deployment fails**

**Symptom:** App deploys but database schema is incomplete.

**Solution:**
1. In Railway dashboard, go to your database service
2. Open "Connect" tab and copy connection URL
3. Run migrations remotely:
```bash
# Set the Railway database URL
export DATABASE_URL="postgresql://postgres:xxx@containers-us-west-xxx.railway.app:5432/railway"

# Apply complete schema
psql $DATABASE_URL -f backend/migrations/complete_schema.sql
```

### **Database Health Check Script**

Create `backend/check_db.py`:
```python
import asyncio
from sqlalchemy import text
from database import engine

async def check_database():
    async with engine.begin() as conn:
        # Check tables
        tables = await conn.execute(text("""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public'
        """))
        
        print("✅ Existing tables:")
        for row in tables:
            print(f"  - {row[0]}")
        
        # Check ENUM types
        enums = await conn.execute(text("""
            SELECT typname FROM pg_type 
            WHERE typtype = 'e'
        """))
        
        print("\n✅ Existing ENUM types:")
        for row in enums:
            print(f"  - {row[0]}")

if __name__ == "__main__":
    asyncio.run(check_database())
```

Run it:
```bash
cd backend
python check_db.py
```

---

## 📖 **User Guide**

### **For End Users**

#### **1. Registration & Login**
- Visit the homepage
- Click "Crear Cuenta Gratis" to register
- Or use Guest Mode (5 documents max)

#### **2. Upload Documents**
- Go to "Upload" section
- Select PDF files (Form 103 or Form 104)
- System automatically detects form type
- Processing happens in real-time

#### **3. View Results**
- **Documents**: See all uploaded PDFs
- **Form 103**: View retenciones data in accordion format
- **Form 104**: View IVA declarations (7 sections, 133 fields)
- **Clientes**: Organized by company name and year

#### **4. Export Data**
- Click "Exportar Excel" for spreadsheet
- Click "Exportar PDF" for branded report
- Choose yearly summaries or specific documents

### **For Administrators**

#### **Analytics Dashboard**
Access at `/admin/analytics` (superuser only)

Features:
- **Visitor Tracking**: Daily, weekly, monthly unique visitors
- **User Growth**: New registrations over time
- **Document Uploads**: Track processing activity
- **Page Views**: See most popular pages
- **Charts**: Visual representation of all metrics

---

## 🚢 **Deployment**

### **Railway Deployment** (Recommended)

#### **Step 1: Prepare Your Repository**

Ensure these files exist:
- `backend/requirements.txt`
- `frontend/package.json`
- `backend/migrations/complete_schema.sql`
- `.gitignore` (exclude `.env`, `venv/`, `node_modules/`)

#### **Step 2: Create Railway Project**

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Create new project
railway init
```

#### **Step 3: Add Services**

In Railway Dashboard:

1. **Add PostgreSQL Database**
   - Click "New" → "Database" → "PostgreSQL"
   - Note the connection string

2. **Add Backend Service**
   - Click "New" → "GitHub Repo"
   - Select your repository
   - Configure:
     - **Root Directory**: `backend`
     - **Build Command**: (leave empty)
     - **Start Command**: `uvicorn main:app --host 0.0.0.0 --port $PORT`

3. **Add Frontend Service**
   - Click "New" → "GitHub Repo"
   - Select your repository
   - Configure:
     - **Root Directory**: `frontend`
     - **Build Command**: `npm run build`
     - **Start Command**: `npm run start`

#### **Step 4: Configure Environment Variables**

**Backend Service Variables:**
```env
DATABASE_URL=${{Postgres.DATABASE_URL}}
SECRET_KEY=your-production-secret-key-min-32-chars
FRONTEND_URL=https://your-frontend.railway.app
BACKEND_URL=https://your-backend.railway.app
PORT=8000
```

**Frontend Service Variables:**
```env
NEXT_PUBLIC_API_URL=https://your-backend.railway.app
NEXT_PUBLIC_SITE_URL=https://your-frontend.railway.app
PORT=3000
```

#### **Step 5: Run Database Migrations**

```bash
# Get the Railway database URL from dashboard
railway variables

# Run migrations
psql "postgresql://postgres:xxx@containers-us-west-xxx.railway.app:5432/railway" \
  -f backend/migrations/complete_schema.sql
```

#### **Step 6: Deploy**

```bash
railway up
```

#### **Step 7: Verify Deployment**

1. Check backend health: `https://your-backend.railway.app/docs`
2. Check frontend: `https://your-frontend.railway.app`
3. Test upload functionality
4. Verify database tables exist

### **Production Checklist**

- [x] Database schema applied correctly
- [x] All environment variables configured
- [x] SECRET_KEY is strong (32+ characters)
- [x] CORS settings configured for production domain
- [x] PostgreSQL connection pooling enabled
- [x] SSL/HTTPS enabled
- [x] Analytics tracking enabled
- [x] Error monitoring setup (optional: Sentry)
- [x] Backups configured
- [x] Custom domain configured

---

## 📁 **Project Structure**

```
tax-forms-processor/
├── backend/
│   ├── main.py                      # FastAPI app entry
│   ├── database.py                  # Database connection
│   ├── models.py                    # SQLAlchemy models (10 tables)
│   ├── auth.py                      # Authentication logic
│   ├── api/
│   │   ├── upload.py                # File upload endpoint
│   │   ├── documents.py             # Documents CRUD
│   │   ├── clientes.py              # Clients API
│   │   ├── analytics.py             # Analytics API
│   │   ├── form_103.py              # Form 103 endpoints
│   │   └── form_104.py              # Form 104 endpoints
│   ├── services/
│   │   ├── pdf_parser.py            # PDF parsing service
│   │   ├── form_parser.py           # Form extraction logic
│   │   └── form_processing.py       # Async processing
│   ├── migrations/
│   │   ├── complete_schema.sql      # ⭐ Complete DB schema (USE THIS)
│   │   ├── 001_initial_schema.sql   # Initial tables
│   │   ├── 002_add_user_isolation.sql
│   │   ├── 003_add_form_104_fields.sql
│   │   └── 004_add_analytics.sql
│   ├── check_db.py                  # Database health check
│   └── requirements.txt             # Python dependencies
│
├── frontend/
│   ├── app/
│   │   ├── layout.tsx               # Root layout
│   │   ├── page.tsx                 # Homepage
│   │   ├── dashboard/               # Main app
│   │   ├── login/                   # Login page
│   │   ├── register/                # Registration
│   │   └── admin/                   # Admin panel
│   ├── components/
│   │   ├── Dashboard.tsx            # Main dashboard
│   │   ├── UploadSection.tsx        # Upload UI
│   │   ├── Form103Section.tsx       # Form 103 display
│   │   ├── Form104Section.tsx       # Form 104 display (7 sections)
│   │   ├── ClientDetail.tsx         # Client view
│   │   ├── YearlySummary.tsx        # Yearly summary
│   │   ├── AnalyticsDashboard.tsx   # Analytics UI
│   │   └── PresentationCard.tsx     # Branding card
│   ├── contexts/
│   │   ├── AuthContext.tsx          # Auth state
│   │   └── ThemeContext.tsx         # Dark mode
│   └── lib/
│       └── api.ts                   # API client
│
├── docker-compose.yml               # Docker setup with auto-migration
├── Dockerfile.backend               # Backend container
├── Dockerfile.frontend              # Frontend container
├── .gitignore                       # Git ignore rules
└── README.md                        # This file
```

---

## 🔐 **Security Best Practices**

### **Environment Variables**
- Never commit `.env` files to git
- Use strong SECRET_KEY (32+ characters)
- Rotate keys regularly in production

### **Database Security**
- Use strong PostgreSQL passwords
- Enable SSL connections in production
- Regular backups (Railway does this automatically)
- Limit database access to specific IPs

### **API Security**
- CORS configured for specific domains only
- Rate limiting on sensitive endpoints
- Input validation on all forms
- SQL injection protection (via SQLAlchemy)

---

## 🤝 **Contributing**

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### **Development Guidelines**

- Write tests for new features
- Follow TypeScript/Python best practices
- Update documentation
- Ensure all tests pass
- Test database migrations thoroughly
- Keep commits atomic and well-described

---

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 **Acknowledgments**

- **SRI Ecuador** - For standardized tax form formats
- **FastAPI** - Excellent web framework
- **Next.js** - Modern React framework
- **pdfplumber** - Reliable PDF parsing
- **Railway** - Simple deployment platform

---

## 📞 **Support**

- **Issues**: [GitHub Issues](https://github.com/CapBraco/tax-forms-processor/issues)
- **Email**: support@capbraco.com
- **Website**: [https://www.capbraco.com](https://www.capbraco.com)

---

## 🗺️ **Roadmap**

### **Completed** ✅
- [x] Form 103 processing (complete with line items)
- [x] Form 104 processing (133 fields across 7 sections)
- [x] User authentication
- [x] Guest mode (5 document limit)
- [x] Analytics dashboard
- [x] Excel/PDF exports with branding
- [x] Mobile responsive design
- [x] Dark mode
- [x] Multi-tenant architecture
- [x] Complete database schema
- [x] Railway deployment

### **Planned** 🔮
- [ ] Form 101 support (Impuesto a la Renta)
- [ ] Form 106 support (ATS)
- [ ] Email notifications
- [ ] Scheduled exports
- [ ] API integrations
- [ ] Mobile app (React Native)
- [ ] Machine learning for field extraction
- [ ] Multi-language support (English)

---

## 📊 **Statistics**

- **Lines of Code**: ~18,000+
- **Components**: 25+ React components
- **API Endpoints**: 35+ routes
- **Database Tables**: 10 tables
- **Form Fields Processed**: 143+ fields (Form 103 + 104)
- **Supported PDF Types**: 2 (Form 103, 104)
- **Database Columns**: 300+ across all tables

---

## 💡 **Tips & Best Practices**

### **Database Management**
- Always use `complete_schema.sql` for new deployments
- Test migrations on development database first
- Back up production database before migrations
- Use `check_db.py` to verify schema integrity

### **Development Workflow**
1. Make changes in a feature branch
2. Test locally with Docker Compose
3. Verify database schema
4. Test both Form 103 and Form 104 uploads
5. Check analytics tracking
6. Deploy to staging (if available)
7. Deploy to production

### **Performance Optimization**
- PostgreSQL connection pooling enabled by default
- Index on frequently queried columns (razon_social, periodo_fiscal_completo)
- Async processing for PDF parsing
- React component lazy loading

---
### 📷 **Media**
![Dashboard](assets/1.png)
![Clients](assets/2.png)
![Forms View](assets/3.png)
![Yearly Summary](assets/4.png)

---


**Built with ❤️ by [CapBraco](https://www.capbraco.com)**

*Last Updated: December 16, 2025*