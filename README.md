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

1. **Clone the repository**
```bash
git clone https://github.com/CapBraco/tax-forms-processor.git
cd tax-forms-processor
```

2. **Set up environment variables**

Create `.env` file in `backend/`:
```env
# Database
DATABASE_URL=postgresql://user:password@localhost:5432/taxforms

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

3. **Start with Docker Compose** (Easiest)
```bash
docker-compose up -d
```

Access the application:
- Frontend: http://localhost:3000
- Backend API: http://localhost:8000
- API Docs: http://localhost:8000/docs

**OR**

3. **Run Manually** (Development)

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

4. **Run Database Migrations**
```bash
# Connect to your PostgreSQL database
psql -U your_user -d taxforms

# Run migrations in order:
\i backend/migrations/001_initial_schema.sql
\i backend/migrations/002_add_user_isolation.sql
\i backend/migrations/003_add_form_104_fields.sql
\i backend/migrations/004_add_analytics.sql
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
- **Form 104**: View IVA declarations (7 sections, 127 fields)
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

#### **User Management**
Access at `/admin` (superuser only)

Features:
- View all registered users
- See user statistics
- Monitor system health

---

## 🔧 **Configuration**

### **Environment Variables**

#### **Backend (`backend/.env`)**

| Variable | Description | Example |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://user:pass@localhost:5432/db` |
| `SECRET_KEY` | JWT secret key (min 32 chars) | `your-super-secret-key-here-min-32-chars` |
| `FRONTEND_URL` | Frontend URL for CORS | `http://localhost:3000` |
| `BACKEND_URL` | Backend URL | `http://localhost:8000` |

#### **Frontend (`frontend/.env.local`)**

| Variable | Description | Example |
|----------|-------------|---------|
| `NEXT_PUBLIC_API_URL` | Backend API URL | `http://localhost:8000` |
| `NEXT_PUBLIC_SITE_URL` | Frontend site URL | `http://localhost:3000` |

### **Database Schema**

Main tables:
- `users` - User accounts and authentication
- `documents` - Uploaded PDF metadata
- `form_103_data` - Extracted Form 103 data
- `form_104_data` - Extracted Form 104 data (127 fields)
- `guest_sessions` - Guest session tracking
- `analytics_events` - Visitor and usage tracking

---

## 📊 **Features in Detail**

### **1. Form 103 Processing**

**Extracts:**
- Razón Social (company name)
- RUC (tax ID)
- Period (month/year)
- Retenciones details (base imponible, valor retenido)
- 10 total fields (pre-calculated sums)

**Display:**
- Accordion format with 2 sections
- Zero-value filtering toggle
- Mobile-responsive tables
- Dark mode support

### **2. Form 104 Processing**

**Extracts:** 127 fields across 5 pages:
1. **Identificación** (14 fields) - Company identification
2. **Ventas** (24 fields) - Sales declarations
3. **Compras y Exportaciones** (42 fields) - Purchases and exports
4. **Liquidación del IVA** (15 fields) - IVA calculations
5. **Resumen Impositivo** (15 fields) - Tax summary
6. **Exportaciones** (8 fields) - Export details
7. **Totales Finales** (9 fields) - Final totals

**Display:**
- 7-section accordion
- Color-coded sections (purple theme)
- Professional table layout
- Zero-value filtering

### **3. Guest Mode**

**Limits:**
- 5 documents maximum
- No data persistence after session
- Full form processing capabilities
- Session-based isolation

**Purpose:**
- Try before registering
- One-time document processing
- Demo the application

### **4. User Isolation**

**Security:**
- Each user sees only their own data
- Complete database isolation via `user_id`
- Guest sessions isolated via `session_id`
- No cross-user data leakage

### **5. Analytics Tracking**

**Metrics:**
- Unique visitors (daily/weekly/monthly)
- Page views
- New user registrations
- Document uploads
- Active sessions (last 24h)
- Popular pages

**Charts:**
- Line charts for visitors/pageviews
- Bar charts for uploads/registrations
- Daily stats for up to 90 days
- Conversion rate calculation

---

## 🚢 **Deployment**

### **Railway Deployment** (Recommended)

1. **Install Railway CLI**
```bash
npm install -g @railway/cli
```

2. **Login to Railway**
```bash
railway login
```

3. **Initialize Project**
```bash
railway init
```

4. **Add PostgreSQL**
```bash
railway add postgresql
```

5. **Deploy**
```bash
railway up
```

6. **Set Environment Variables** (Railway Dashboard)
- Add all variables from `.env` files
- Use Railway's PostgreSQL connection string

7. **Configure Custom Domain** (Optional)
```bash
railway domain
```

### **Production Checklist**

- [ ] Environment variables configured
- [ ] Database migrations applied
- [ ] SECRET_KEY is strong (32+ characters)
- [ ] CORS settings configured for production domain
- [ ] PostgreSQL connection pooling enabled
- [ ] SSL/HTTPS enabled
- [ ] Analytics tracking enabled
- [ ] Error monitoring setup (optional: Sentry)
- [ ] Backups configured
- [ ] Custom domain configured

---

## 🧪 **Testing**

### **Backend Tests**
```bash
cd backend
pytest tests/
```

### **Frontend Tests**
```bash
cd frontend
npm run test
```

### **Manual Testing**

Use the included Postman collection:
1. Import `backend/tests/Tax_Forms_API.postman_collection.json`
2. Set environment variables
3. Run Collection Runner

---

## 📁 **Project Structure**

```
tax-forms-processor/
├── backend/
│   ├── main.py                 # FastAPI app entry
│   ├── database.py             # Database connection
│   ├── models.py               # SQLAlchemy models
│   ├── auth.py                 # Authentication logic
│   ├── api/
│   │   ├── upload.py           # File upload endpoint
│   │   ├── documents.py        # Documents CRUD
│   │   ├── clientes.py         # Clients API
│   │   ├── analytics.py        # Analytics API
│   │   ├── form_103.py         # Form 103 endpoints
│   │   └── form_104.py         # Form 104 endpoints
│   ├── services/
│   │   ├── pdf_parser.py       # PDF parsing service
│   │   ├── form_parser.py      # Form extraction logic
│   │   └── form_processing.py  # Async processing
│   ├── migrations/             # SQL migrations
│   └── requirements.txt        # Python dependencies
│
├── frontend/
│   ├── app/
│   │   ├── layout.tsx          # Root layout
│   │   ├── page.tsx            # Homepage
│   │   ├── dashboard/          # Main app
│   │   ├── login/              # Login page
│   │   ├── register/           # Registration
│   │   └── admin/              # Admin panel
│   ├── components/
│   │   ├── Dashboard.tsx       # Main dashboard
│   │   ├── UploadSection.tsx   # Upload UI
│   │   ├── Form103Section.tsx  # Form 103 display
│   │   ├── Form104Section.tsx  # Form 104 display
│   │   ├── ClientDetail.tsx    # Client view
│   │   ├── YearlySummary.tsx   # Yearly summary
│   │   ├── AnalyticsDashboard.tsx  # Analytics UI
│   │   └── PresentationCard.tsx    # Branding card
│   ├── contexts/
│   │   ├── AuthContext.tsx     # Auth state
│   │   └── ThemeContext.tsx    # Dark mode
│   └── lib/
│       └── api.ts              # API client
│
├── docker-compose.yml          # Docker setup
├── Dockerfile.backend          # Backend container
├── Dockerfile.frontend         # Frontend container
└── README.md                   # This file
```

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

- **Issues**: [GitHub Issues](https://github.com/yourusername/tax-forms-processor/issues)
- **Email**: support@capbraco.com
- **Website**: [https://www.capbraco.com](https://www.capbraco.com)

---

## 🗺️ **Roadmap**

### **Completed** ✅
- [x] Form 103 processing
- [x] Form 104 processing (127 fields)
- [x] User authentication
- [x] Guest mode
- [x] Analytics dashboard
- [x] Excel/PDF exports
- [x] Mobile responsive design
- [x] Dark mode
- [x] Multi-tenant architecture

### **Planned** 🔮
- [ ] Form 101 support (Impuesto a la Renta)
- [ ] Form 106 support (ATS)
- [ ] Email notifications
- [ ] Scheduled exports
- [ ] API integrations
- [ ] Mobile app (React Native)
- [ ] Machine learning for field extraction

---

## 📊 **Statistics**

- **Lines of Code**: ~15,000+
- **Components**: 20+ React components
- **API Endpoints**: 30+ routes
- **Database Tables**: 7 main tables
- **Form Fields Processed**: 137+ fields (Form 103 + 104)
- **Supported PDF Types**: 2 (Form 103, 104)

---

## 🎨 **Screenshots**

### Dashboard
![Dashboard](docs/screenshots/dashboard.png)

### Form 103 View
![Form 103](docs/screenshots/form-103.png)

### Form 104 View
![Form 104](docs/screenshots/form-104.png)

### Analytics Dashboard
![Analytics](docs/screenshots/analytics.png)

*(Add actual screenshots to `docs/screenshots/` directory)*

---

## 💡 **Tips & Tricks**

### **Performance Optimization**
- Use Docker for consistent environments
- Enable PostgreSQL connection pooling
- Cache frequently accessed data
- Use CDN for static assets in production

### **Security Best Practices**
- Change SECRET_KEY in production
- Use HTTPS in production
- Implement rate limiting (optional)
- Regular security audits
- Keep dependencies updated

### **Scaling**
- Use Redis for session storage
- Add Celery for background tasks
- Implement horizontal scaling
- Use load balancer for multiple instances

---

**Built with ❤️ by [CapBraco](https://www.capbraco.com)**

*Last Updated: December 12, 2025*
