<div align="center">

# 🥖 Pan Tributario

### Automated Tax Form Processing for Ecuador

*Transforming 3-4 hours of manual work into 10 seconds*

[![Live Demo](https://img.shields.io/badge/demo-live-success?style=for-the-badge)](https://tax.capbraco.com)
[![GitHub](https://img.shields.io/badge/github-repository-blue?style=for-the-badge&logo=github)](https://github.com/CapBraco/tax_form_processor)
[![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)](LICENSE)

[Live Demo](https://tax.capbraco.com) · [Report Bug](https://github.com/CapBraco/tax_form_processor/issues) · [Request Feature](https://github.com/CapBraco/tax_form_processor/issues)

</div>

---

## 📋 Table of Contents

- [About](#about)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Screenshots](#screenshots)
- [Getting Started](#getting-started)
- [Architecture](#architecture)
- [API Documentation](#api-documentation)
- [Deployment](#deployment)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

---

## 🎯 About

Pan Tributario is a full-stack SaaS application that automates the extraction and processing of Ecuadorian tax forms (SRI Forms 103 & 104). Built to solve a real problem faced by accountants and businesses, it reduces manual data entry from 3-4 hours per client to just 10 seconds.

### The Problem

Ecuadorian accountants manually extract financial data from PDF tax forms:
- **Form 103** (Retenciones): 10+ fields per document
- **Form 104** (IVA): 130+ fields across 7 sections
- **Time required**: 3-4 hours per client
- **Monthly workload**: 150-200 hours for 50 clients
- **Error rate**: ~5% due to manual entry

### The Solution

Automated PDF processing with:
- ⚡ **1,440x faster** processing (3-4 hours → 10 seconds)
- ✅ **Zero errors** through automated extraction
- 📊 **Professional reports** (Excel & PDF exports)
- 👥 **Multi-client management** with yearly summaries
- 🔐 **Complete data isolation** between users

---

## ✨ Features

### Core Functionality
- 📤 **Drag-and-drop PDF upload** with bulk processing
- 🔍 **Automatic form detection** (103 vs 104)
- 📊 **Intelligent field extraction** using regex patterns
- 💾 **Client management** organized by company and year
- 📈 **Yearly accumulations** for tax reporting
- 📄 **Professional exports** (Excel with formulas, branded PDFs)

### User Experience
- 🎨 **Dark mode** with proper contrast ratios
- 📱 **Mobile responsive** design
- 🚀 **Real-time processing** with progress indicators
- 🎯 **Guest mode** (5 free documents, no signup)
- ♾️ **Unlimited access** for registered users

### Security & Authentication
- 🔐 **Google OAuth 2.0** integration
- 🔒 **Bcrypt password** hashing
- 🤖 **reCAPTCHA v3** bot protection
- 🛡️ **Multi-tenant architecture** with complete user isolation
- 🍪 **Secure session management**

### Technical Features
- ⚡ **Async processing** for optimal performance
- 💾 **10 database tables** with proper relationships
- 🔄 **35+ API endpoints** (RESTful)
- 📊 **Analytics dashboard** for admins
- 🌐 **CDN integration** (Cloudflare) for 70%+ cache rate

---

## 🛠️ Tech Stack

### Frontend
[![Next.js](https://img.shields.io/badge/Next.js-14-black?style=flat-square&logo=next.js)](https://nextjs.org/)
[![React](https://img.shields.io/badge/React-18-blue?style=flat-square&logo=react)](https://reactjs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5-blue?style=flat-square&logo=typescript)](https://www.typescriptlang.org/)
[![Tailwind CSS](https://img.shields.io/badge/Tailwind-3-38bdf8?style=flat-square&logo=tailwind-css)](https://tailwindcss.com/)

### Backend
[![FastAPI](https://img.shields.io/badge/FastAPI-0.100+-009688?style=flat-square&logo=fastapi)](https://fastapi.tiangolo.com/)
[![Python](https://img.shields.io/badge/Python-3.11-blue?style=flat-square&logo=python)](https://www.python.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-336791?style=flat-square&logo=postgresql)](https://www.postgresql.org/)
[![SQLAlchemy](https://img.shields.io/badge/SQLAlchemy-2.0-red?style=flat-square)](https://www.sqlalchemy.org/)

### DevOps & Tools
[![Docker](https://img.shields.io/badge/Docker-latest-2496ED?style=flat-square&logo=docker)](https://www.docker.com/)
[![Railway](https://img.shields.io/badge/Railway-Deployed-0B0D0E?style=flat-square&logo=railway)](https://railway.app/)
[![Cloudflare](https://img.shields.io/badge/Cloudflare-CDN-F38020?style=flat-square&logo=cloudflare)](https://www.cloudflare.com/)

---

## 📸 Screenshots

### Landing Page
<img src="docs/images/1.png" alt="Landing Page" width="800"/>

### CLients Interface
<img src="docs/images/2.png" alt="Clients Interface" width="800"/>

### Form 103 Display
<img src="docs/images/3.png" alt="Form 103" width="800"/>

### Yearly Summary
<img src="docs/images/4.png" alt="Yearly Summary" width="800"/>

### Light Mode
<img src="docs/images/5.png" alt="Light Mode" width="800"/>

---

## 🚀 Getting Started

### Prerequisites

- Node.js 18+ and npm
- Python 3.11+
- PostgreSQL 15+
- Docker (optional)

### Installation

#### 1. Clone the repository
```bash
git clone https://github.com/CapBraco/tax_form_processor.git
cd tax_form_processor
```

#### 2. Backend Setup
```bash
cd backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Create .env file
cp .env.example .env
# Edit .env with your database credentials

# Run migrations
alembic upgrade head

# Start server
uvicorn main:app --reload
```

Backend will run at `http://localhost:8000`

#### 3. Frontend Setup
```bash
cd frontend

# Install dependencies
npm install

# Create .env.local file
cp .env.example .env.local
# Edit .env.local with your backend URL

# Start development server
npm run dev
```

Frontend will run at `http://localhost:3000`

### Environment Variables

#### Backend (.env)
```env
DATABASE_URL=postgresql://user:password@localhost:5432/taxforms
SECRET_KEY=your-secret-key-min-32-characters
FRONTEND_URL=http://localhost:3000
GOOGLE_CLIENT_ID=your-google-oauth-client-id
GOOGLE_CLIENT_SECRET=your-google-oauth-secret
RECAPTCHA_SECRET_KEY=your-recaptcha-secret
```

#### Frontend (.env.local)
```env
NEXT_PUBLIC_API_URL=http://localhost:8000
NEXT_PUBLIC_SITE_URL=http://localhost:3000
NEXT_PUBLIC_RECAPTCHA_SITE_KEY=your-recaptcha-site-key
```

### Docker Setup (Alternative)

```bash
# Build and run with docker-compose
docker-compose up -d

# Access the application
# Frontend: http://localhost:3000
# Backend: http://localhost:8000
```

---

## 🏗️ Architecture

### System Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    CLIENT LAYER                          │
│  (Next.js Frontend - React Components & TypeScript)     │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ HTTPS/REST API
                     ▼
┌─────────────────────────────────────────────────────────┐
│                    API LAYER                             │
│    (FastAPI - Async Python with Pydantic validation)    │
│                                                          │
│  ┌──────────┐  ┌───────────┐  ┌──────────┐            │
│  │   Auth   │  │  Upload   │  │ Clients  │            │
│  │  Routes  │  │  Routes   │  │  Routes  │            │
│  └──────────┘  └───────────┘  └──────────┘            │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ SQLAlchemy ORM
                     ▼
┌─────────────────────────────────────────────────────────┐
│                  DATABASE LAYER                          │
│         (PostgreSQL - 10 Tables, JSONB fields)          │
│                                                          │
│  users • documents • form_103_data • form_104_data      │
│  guest_sessions • temporary_files • analytics           │
└─────────────────────────────────────────────────────────┘
```

### Data Flow: PDF Upload & Processing

```
1. User uploads PDF → Frontend validates file
2. API receives file → Saves to temp storage
3. pdfplumber extracts text → Regex patterns parse fields
4. Data saved to database → Async SQLAlchemy commit
5. Frontend polls status → Real-time updates
6. Success response → Display extracted data
```

### Database Schema

<img src="docs/images/database_schema.png" alt="Database Schema" width="800"/>

**Key Tables:**
- `users` - Authentication and profiles
- `documents` - Metadata for uploaded PDFs
- `form_103_data` - Extracted data from Form 103
- `form_104_data` - Extracted data from Form 104 (130 fields)
- `guest_sessions` - Temporary sessions with document limits

---

## 📚 API Documentation

Interactive API documentation available at:
- **Swagger UI**: `http://localhost:8000/docs`
- **ReDoc**: `http://localhost:8000/redoc`

### Key Endpoints

#### Authentication
```http
POST   /api/auth/register          # Create new account
POST   /api/auth/login             # Login with credentials
POST   /api/auth/google            # Google OAuth login
POST   /api/auth/logout            # Logout
GET    /api/auth/me                # Get current user
```

#### Documents
```http
POST   /api/upload/bulk            # Upload multiple PDFs
GET    /api/documents              # List user documents
GET    /api/documents/{id}         # Get document details
DELETE /api/documents/{id}         # Delete document
```

#### Forms
```http
GET    /api/forms-data/103/{id}    # Get Form 103 data
GET    /api/forms-data/104/{id}    # Get Form 104 data
```

#### Clients
```http
GET    /api/clientes               # List user clients
GET    /api/clientes/{name}        # Get client details
POST   /api/clientes/export        # Export to Excel/PDF
```

---

## 🚀 Deployment

### Railway Deployment (Current)

1. **Backend Service**
   - Build: `Dockerfile` in `backend/`
   - Start: `uvicorn main:app --host 0.0.0.0 --port $PORT`
   - Environment: Production variables from Railway

2. **Frontend Service**
   - Build: `npm run build`
   - Start: `npm run start`
   - Environment: Production variables from Railway

3. **PostgreSQL Database**
   - Managed by Railway
   - Automatic backups
   - Connection string in `DATABASE_URL`

### Custom Domain Setup

1. Point DNS to Railway (CNAME)
2. Configure Cloudflare for CDN
3. Enable SSL/TLS (Full strict mode)
4. Set up page rules for caching

---

## 🗺️ Roadmap

### Q1 2025
- [ ] Form 101 support (Impuesto a la Renta)
- [ ] Form 106 support (ATS)
- [ ] Email notifications
- [ ] Bulk document deletion

### Q2 2025
- [ ] Mobile app (React Native)
- [ ] API for third-party integrations
- [ ] Advanced analytics dashboard
- [ ] Scheduled reports (weekly/monthly)

### Q3 2025
- [ ] Multi-language support (English)
- [ ] WhatsApp notifications
- [ ] Collaborative features (team accounts)

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👤 Contact

Bryan Paucar - [@your_twitter](https://twitter.com/your_twitter)

Project Link: [https://github.com/CapBraco/tax_form_processor](https://github.com/CapBraco/tax_form_processor)

Live Demo: [https://tax.capbraco.com](https://tax.capbraco.com)

---

## 🙏 Acknowledgments

- Inspired by real-world accounting workflows in Ecuador
- Built with modern web technologies and best practices
- Special thanks to the FastAPI and Next.js communities

---

<div align="center">

Made with ❤️ by Bryan A Paucar

⭐ Star this repo if you find it helpful!

</div>