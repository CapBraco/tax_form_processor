# Tax Forms Processor 🇪🇨

> A comprehensive, enterprise-grade solution for processing Ecuadorian tax forms (Forms 103 & 104) with intelligent data extraction, client management, and professional reporting capabilities.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.104+-00C7B7?logo=fastapi)](https://fastapi.tiangolo.com)
[![Next.js](https://img.shields.io/badge/Next.js-14+-black?logo=next.js)](https://nextjs.org)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker)](https://www.docker.com)

<!-- PROJECT LOGO/BANNER -->
![Tax Forms Processor Banner](./docs/images/banner.png)
*[Add banner image showcasing the application interface]*

---

## 📋 Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Demo](#demo)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Configuration](#configuration)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Core Components](#core-components)
- [API Documentation](#api-documentation)
- [Deployment](#deployment)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

---

## 🎯 Overview

The **Tax Forms Processor** is a sophisticated full-stack application designed specifically for Ecuadorian tax compliance, enabling accountants and businesses to efficiently process, organize, and analyze tax documentation. The system specializes in handling:

- **Form 103**: Retenciones en la Fuente (Income Tax Withholdings)
- **Form 104**: IVA Declarations (VAT)

Built with modern web technologies and containerized for seamless deployment, this application transforms manual tax document processing into an automated, scalable workflow with comprehensive data extraction, client organization, and multi-format reporting capabilities.

### Problem Statement

Ecuadorian businesses and accountants face significant challenges in managing tax compliance documents:
- Manual data entry from PDF forms is time-consuming and error-prone
- Tracking multiple clients and their yearly financial summaries requires extensive organization
- Generating professional reports for audits and stakeholders involves repetitive formatting work
- Accessing historical tax data across multiple periods is cumbersome

### Solution

This application provides an end-to-end solution that:
- Automatically extracts structured data from official SRI tax forms
- Organizes documents by client (razón social) with complete data isolation
- Generates yearly financial summaries with automatic calculations
- Exports data in multiple professional formats (Excel, PDF)
- Offers both public guest access and secure authenticated user spaces

---

## ✨ Key Features

### 🔐 Dual Access Model
- **Guest Access**: Try core functionality with document limits (no registration required)
- **Registered Users**: Unlimited document processing with complete data isolation
- **User Authentication**: Secure registration, login, password reset, and admin panel

### 📄 Intelligent Form Processing
- **Automated Data Extraction**: Parse Forms 103 and 104 with regex-based field identification
- **Complete Field Preservation**: Capture all form data including zero-value entries for historical accuracy
- **Real-time Processing**: Upload and process documents instantly
- **Multi-document Support**: Batch processing capabilities

### 👥 Client Management
- **Organization by Razón Social**: Group documents by company name
- **Yearly Financial Summaries**: Automatic aggregation of financial data by year
- **Historical Tracking**: Access complete tax history for each client
- **Search and Filter**: Quick navigation through client portfolios

### 📊 Professional Reporting
- **Excel Export**: Detailed spreadsheets with all extracted data using openpyxl
- **Branded PDF Reports**: Professional documents with custom layouts using reportlab
- **Summary Dashboards**: Visual overviews of financial data
- **Audit-Ready Format**: Structured exports meeting SRI requirements

### 🎨 Modern User Experience
- **Mobile-Responsive Design**: Adaptive layouts with hamburger menus for all devices
- **Dark Mode**: Enhanced visibility with proper input field contrast
- **Real-time Feedback**: Loading states, progress indicators, and error handling
- **Intuitive Navigation**: Clean, organized interface for efficient workflows

---

## 🎬 Demo

<!-- SCREENSHOTS SECTION -->
### Dashboard Overview
![Dashboard](./docs/images/dashboard.png)
*[Add screenshot of main dashboard with summary statistics]*

### Form Processing
![Upload Interface](./docs/images/upload-process.png)
*[Add screenshot of file upload and processing interface]*

### Client Management
![Clients View](./docs/images/clients-view.png)
*[Add screenshot of client list and management interface]*

### Yearly Summaries
![Financial Summary](./docs/images/yearly-summary.png)
*[Add screenshot of yearly financial summary for a client]*

### Export Capabilities
![Export Options](./docs/images/export-formats.png)
*[Add screenshot showing Excel and PDF export options]*

<!-- VIDEO DEMO -->
### Live Demo Video
[![Demo Video](./docs/images/video-thumbnail.png)](https://your-demo-video-link.com)
*[Add link to demo video walkthrough]*

---

## 🛠 Tech Stack

### Backend
- **FastAPI**: High-performance Python web framework with async support
- **SQLAlchemy**: ORM with async operations for database management
- **PostgreSQL**: Robust relational database for structured data storage
- **pdfplumber**: PDF text extraction and parsing engine
- **Pydantic**: Data validation and settings management
- **Alembic**: Database migration tool

### Frontend
- **Next.js 14**: React framework with App Router and TypeScript
- **Tailwind CSS**: Utility-first CSS framework for responsive design
- **React Hooks**: Modern state management and lifecycle handling
- **Axios**: HTTP client for API communication
- **TypeScript**: Type-safe JavaScript for enhanced development

### Data Processing & Export
- **openpyxl**: Excel file generation and manipulation
- **reportlab**: PDF generation with custom layouts
- **Custom Parsers**: Regex-based extraction for Forms 103 and 104

### Infrastructure
- **Docker**: Containerization for consistent deployment environments
- **Docker Compose**: Multi-container orchestration
- **Railway**: Cloud platform for production deployment
- **Git**: Version control with git-based deployment workflows

---

## 🏗 Architecture

### System Overview

```
┌─────────────────┐         ┌─────────────────┐         ┌─────────────────┐
│                 │         │                 │         │                 │
│  Next.js        │◄───────►│  FastAPI        │◄───────►│  PostgreSQL     │
│  Frontend       │  REST   │  Backend        │  SQL    │  Database       │
│                 │  API    │                 │         │                 │
└─────────────────┘         └─────────────────┘         └─────────────────┘
                                    │
                                    │
                            ┌───────▼────────┐
                            │                │
                            │  pdfplumber    │
                            │  PDF Parser    │
                            │                │
                            └────────────────┘
```

### Database Schema

The application uses a relational database structure with the following core entities:

**Users Table**
- User authentication and profile information
- Password hashing with secure storage
- Role-based access control (user/admin)

**Documents Table**
- PDF file metadata and storage paths
- Processing status tracking
- User ownership and isolation
- Guest session identification

**Form103 & Form104 Tables**
- Extracted tax form data with all fields
- JSON storage for complete form structure
- Foreign keys to documents and users
- Yearly aggregation support

**Clients (Razón Social)**
- Company identification and grouping
- User-specific client lists
- Document associations

### Data Flow

1. **Upload**: User uploads PDF via frontend → API endpoint receives file
2. **Storage**: File saved to designated directory → Database record created
3. **Processing**: pdfplumber extracts text → Regex parsers identify fields
4. **Validation**: Pydantic schemas validate extracted data → Error handling
5. **Storage**: Structured data saved to database → JSON backup stored
6. **Response**: Frontend receives processed data → UI updates with results
7. **Export**: User requests report → openpyxl/reportlab generates file → Download initiated

---

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Docker** (v20.10+) and **Docker Compose** (v2.0+)
- **Git** for version control
- **Node.js** (v18+) and **npm** (v9+) - for local frontend development
- **Python** (v3.11+) - for local backend development

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/tax-forms-processor.git
   cd tax-forms-processor
   ```

2. **Set up environment variables**
   
   Create `.env` file in the root directory:
   ```bash
   cp .env.example .env
   ```
   
   Configure the following variables:
   ```env
   # Database
   DATABASE_URL=postgresql+asyncpg://user:password@db:5432/taxforms
   
   # Security
   SECRET_KEY=your-secret-key-here
   ALGORITHM=HS256
   ACCESS_TOKEN_EXPIRE_MINUTES=30
   
   # Application
   BACKEND_URL=http://localhost:8000
   FRONTEND_URL=http://localhost:3000
   
   # Guest Session
   GUEST_DOCUMENT_LIMIT=10
   GUEST_SESSION_EXPIRE_HOURS=24
   
   # File Storage
   UPLOAD_DIRECTORY=./uploads
   MAX_FILE_SIZE_MB=10
   ```

3. **Build and run with Docker Compose**
   ```bash
   docker-compose up --build
   ```
   
   This will start:
   - PostgreSQL database on port 5432
   - FastAPI backend on port 8000
   - Next.js frontend on port 3000

4. **Initialize the database**
   ```bash
   docker-compose exec backend alembic upgrade head
   ```

5. **Access the application**
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:8000
   - API Documentation: http://localhost:8000/docs

### Configuration

#### Backend Configuration (`backend/config.py`)

```python
class Settings(BaseSettings):
    # Database settings
    database_url: str
    
    # JWT settings
    secret_key: str
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    
    # File upload settings
    upload_directory: str = "./uploads"
    max_file_size_mb: int = 10
    
    # Guest session settings
    guest_document_limit: int = 10
    guest_session_expire_hours: int = 24
```

#### Frontend Configuration (`frontend/next.config.js`)

```javascript
module.exports = {
  env: {
    NEXT_PUBLIC_API_URL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000',
  },
  // Additional Next.js configuration
}
```

---

## 💡 Usage

### For Guest Users

1. **Navigate to Dashboard**: Access the public dashboard at `/dashboard`
2. **Upload Documents**: Click "Upload" and select Form 103 or Form 104 PDFs
3. **View Results**: Processed data appears in the dashboard with summary statistics
4. **Explore Forms**: Navigate to "Form 103" or "Form 104" to see detailed extractions
5. **Document Limit**: Guest users are limited to 10 documents per session

### For Registered Users

1. **Create Account**: Register at `/register` with email and password
2. **Login**: Access your account at `/login`
3. **Unlimited Processing**: Upload and process unlimited documents
4. **Client Management**: 
   - Navigate to "Clientes" section
   - View documents organized by razón social
   - Access yearly financial summaries
5. **Export Reports**:
   - Select client and year
   - Choose Excel or PDF format
   - Download professional reports

### Admin Features

Administrators have additional capabilities:
- View all users in the system
- Monitor system usage statistics
- Manage user accounts and permissions

---

## 📁 Project Structure

```
tax-forms-processor/
├── backend/
│   ├── app/
│   │   ├── api/
│   │   │   ├── endpoints/
│   │   │   │   ├── auth.py          # Authentication endpoints
│   │   │   │   ├── documents.py     # Document upload/processing
│   │   │   │   ├── form103.py       # Form 103 endpoints
│   │   │   │   ├── form104.py       # Form 104 endpoints
│   │   │   │   ├── clients.py       # Client management
│   │   │   │   └── export.py        # Export functionality
│   │   │   └── deps.py              # Dependency injection
│   │   ├── core/
│   │   │   ├── config.py            # Application settings
│   │   │   ├── security.py          # JWT & password hashing
│   │   │   └── database.py          # Database connection
│   │   ├── models/
│   │   │   ├── user.py              # User model
│   │   │   ├── document.py          # Document model
│   │   │   ├── form103.py           # Form 103 model
│   │   │   └── form104.py           # Form 104 model
│   │   ├── schemas/
│   │   │   ├── user.py              # User Pydantic schemas
│   │   │   ├── document.py          # Document schemas
│   │   │   ├── form103.py           # Form 103 schemas
│   │   │   └── form104.py           # Form 104 schemas
│   │   ├── services/
│   │   │   ├── pdf_processor.py     # PDF parsing logic
│   │   │   ├── form103_parser.py    # Form 103 extraction
│   │   │   ├── form104_parser.py    # Form 104 extraction
│   │   │   ├── excel_export.py      # Excel generation
│   │   │   └── pdf_export.py        # PDF report generation
│   │   └── main.py                  # FastAPI application entry
│   ├── alembic/                     # Database migrations
│   ├── uploads/                     # Uploaded PDF storage
│   ├── Dockerfile
│   ├── requirements.txt
│   └── pyproject.toml
├── frontend/
│   ├── src/
│   │   ├── app/
│   │   │   ├── dashboard/           # Dashboard page
│   │   │   ├── upload/              # Upload interface
│   │   │   ├── form103/             # Form 103 display
│   │   │   ├── form104/             # Form 104 display
│   │   │   ├── clientes/            # Client management
│   │   │   ├── login/               # Login page
│   │   │   ├── register/            # Registration page
│   │   │   └── layout.tsx           # Root layout
│   │   ├── components/
│   │   │   ├── Navbar.tsx           # Navigation component
│   │   │   ├── DashboardCard.tsx    # Dashboard widgets
│   │   │   ├── Form103Display.tsx   # Form 103 renderer
│   │   │   ├── Form104Display.tsx   # Form 104 renderer
│   │   │   └── ExportButton.tsx     # Export functionality
│   │   ├── lib/
│   │   │   ├── api.ts               # API client functions
│   │   │   └── utils.ts             # Utility functions
│   │   └── types/
│   │       ├── form103.ts           # Form 103 TypeScript types
│   │       ├── form104.ts           # Form 104 TypeScript types
│   │       └── user.ts              # User types
│   ├── public/                      # Static assets
│   ├── Dockerfile
│   ├── package.json
│   ├── tsconfig.json
│   └── tailwind.config.js
├── docs/
│   ├── images/                      # Documentation images
│   ├── API.md                       # API documentation
│   └── DEPLOYMENT.md                # Deployment guide
├── docker-compose.yml
├── .env.example
├── .gitignore
├── LICENSE
└── README.md
```

---

## 🔧 Core Components

### Backend Services

#### PDF Processor (`services/pdf_processor.py`)
The core service responsible for extracting text from PDF files using pdfplumber. Implements error handling and validation for various PDF structures.

```python
class PDFProcessor:
    def extract_text(self, pdf_path: str) -> str:
        """Extract text content from PDF file"""
        
    def identify_form_type(self, text: str) -> str:
        """Determine if PDF is Form 103 or 104"""
```

#### Form 103 Parser (`services/form103_parser.py`)
Specialized parser for Income Tax Withholding forms (Retenciones en la Fuente). Uses regex patterns to extract specific field codes and values.

**Key Fields Extracted:**
- `campo302`: Tax identification (RUC/CI)
- `campo303`: Company name (Razón Social)
- `campo344`: Gross base amount
- `campo345`: Withholding percentage
- `campo346`: Withheld tax value
- And all other official SRI field codes

```python
class Form103Parser:
    def parse(self, text: str) -> Dict[str, Any]:
        """Extract all Form 103 fields using regex patterns"""
        
    def validate_extracted_data(self, data: Dict) -> bool:
        """Validate extracted data meets SRI requirements"""
```

#### Form 104 Parser (`services/form104_parser.py`)
Specialized parser for VAT Declaration forms (IVA). Handles complex table structures and calculates totals.

**Key Fields Extracted:**
- `campo401`: Tax period
- `campo411-419`: Various VAT bases and rates (0%, 5%, 8%, 12%, 13%, 15%)
- `campo421-429`: Corresponding VAT amounts
- `campo499`: Total VAT collected
- And all other official SRI field codes

```python
class Form104Parser:
    def parse(self, text: str) -> Dict[str, Any]:
        """Extract all Form 104 fields and calculate totals"""
        
    def calculate_totals(self, data: Dict) -> Dict:
        """Calculate aggregate values from parsed data"""
```

#### Excel Export Service (`services/excel_export.py`)
Generates professional Excel reports using openpyxl with styling, formulas, and multiple worksheets.

Features:
- Automatic column sizing
- Header formatting with colors
- Formula insertion for totals
- Multiple sheets for different data views
- Freeze panes for better navigation

#### PDF Export Service (`services/pdf_export.py`)
Creates branded PDF reports using reportlab with custom layouts, headers, footers, and tables.

Features:
- Company logo and branding
- Professional table layouts
- Page numbering
- Summary sections
- SRI-compliant formatting

### Frontend Components

#### Navbar (`components/Navbar.tsx`)
Responsive navigation bar with user authentication state, mobile hamburger menu, and role-based menu items.

Features:
- Mobile-responsive with hamburger menu
- User profile dropdown
- Guest vs. authenticated state handling
- Active route highlighting

#### Form Display Components
Reusable components that match official SRI tax form layouts for accurate data presentation.

**Form103Display.tsx**
- Displays withholding details in structured format
- Groups by razón social
- Shows all extracted fields
- Filtering and sorting capabilities

**Form104Display.tsx**
- VAT declaration table layout
- Automatic total calculations
- Period-based grouping
- Export to Excel integration

#### Dashboard Cards
Modular widgets for displaying summary statistics and key metrics.

### Database Models

#### User Model
Handles user authentication with secure password hashing and role-based permissions.

#### Document Model
Tracks uploaded files with metadata, processing status, and user/guest associations.

#### Form Models (Form103/Form104)
Store extracted tax data with complete field preservation, JSON backup, and relationship to documents and users.

---

## 📡 API Documentation

### Authentication Endpoints

#### Register User
```http
POST /api/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "securepassword",
  "full_name": "John Doe"
}
```

**Response:**
```json
{
  "id": 1,
  "email": "user@example.com",
  "full_name": "John Doe",
  "is_active": true,
  "is_admin": false
}
```

#### Login
```http
POST /api/auth/login
Content-Type: application/x-www-form-urlencoded

username=user@example.com&password=securepassword
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}
```

### Document Processing Endpoints

#### Upload Document
```http
POST /api/documents/upload
Authorization: Bearer <token>
Content-Type: multipart/form-data

file: <pdf-file>
```

**Response:**
```json
{
  "id": 1,
  "filename": "form103_january.pdf",
  "upload_date": "2024-01-15T10:30:00",
  "status": "processed",
  "form_type": "form103"
}
```

#### Get Document Details
```http
GET /api/documents/{document_id}
Authorization: Bearer <token>
```

#### List User Documents
```http
GET /api/documents/
Authorization: Bearer <token>
```

### Form 103 Endpoints

#### Get All Form 103 Records
```http
GET /api/form103/
Authorization: Bearer <token>
```

#### Get Form 103 by ID
```http
GET /api/form103/{record_id}
Authorization: Bearer <token>
```

### Form 104 Endpoints

#### Get All Form 104 Records
```http
GET /api/form104/
Authorization: Bearer <token>
```

#### Get Form 104 by ID
```http
GET /api/form104/{record_id}
Authorization: Bearer <token>
```

### Client Management Endpoints

#### Get All Clients
```http
GET /api/clients/
Authorization: Bearer <token>
```

**Response:**
```json
[
  {
    "razon_social": "EMPRESA EJEMPLO S.A.",
    "document_count": 15,
    "latest_document": "2024-12-01T00:00:00"
  }
]
```

#### Get Client Details with Yearly Summary
```http
GET /api/clients/{razon_social}/summary?year=2024
Authorization: Bearer <token>
```

### Export Endpoints

#### Export to Excel
```http
POST /api/export/excel
Authorization: Bearer <token>
Content-Type: application/json

{
  "razon_social": "EMPRESA EJEMPLO S.A.",
  "year": 2024,
  "form_type": "form103"
}
```

**Response:** Excel file download

#### Export to PDF
```http
POST /api/export/pdf
Authorization: Bearer <token>
Content-Type: application/json

{
  "razon_social": "EMPRESA EJEMPLO S.A.",
  "year": 2024,
  "form_type": "form103"
}
```

**Response:** PDF file download

### Interactive API Documentation

FastAPI provides automatic interactive API documentation:

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

---

## 🚢 Deployment

### Railway Deployment

This application is optimized for deployment on [Railway](https://railway.app), a modern hosting platform with git-based workflows.

#### Prerequisites
1. Railway account ([Sign up](https://railway.app))
2. GitHub repository connected to Railway
3. Environment variables configured

#### Deployment Steps

1. **Connect Repository**
   - Login to Railway
   - Create new project
   - Connect your GitHub repository

2. **Add PostgreSQL Database**
   - Click "New" → "Database" → "PostgreSQL"
   - Railway automatically provisions the database
   - `DATABASE_URL` is automatically added to environment variables

3. **Configure Backend Service**
   - Add service from repository
   - Set root directory to `/backend`
   - Add environment variables:
     ```
     SECRET_KEY=<your-secret-key>
     FRONTEND_URL=<your-frontend-url>
     ```
   - Railway will automatically detect Dockerfile

4. **Configure Frontend Service**
   - Add another service from same repository
   - Set root directory to `/frontend`
   - Add environment variable:
     ```
     NEXT_PUBLIC_API_URL=<your-backend-url>
     ```
   - Railway will automatically detect Dockerfile

5. **Deploy**
   - Push to main branch
   - Railway automatically builds and deploys
   - Access your application via generated URLs

#### Custom Domain Setup

1. Navigate to your frontend service settings
2. Click "Settings" → "Networking"
3. Add your custom domain
4. Update DNS records as instructed

### Environment Variables Reference

```env
# Backend
DATABASE_URL=<provided-by-railway>
SECRET_KEY=<generate-secure-key>
FRONTEND_URL=https://your-frontend.railway.app
UPLOAD_DIRECTORY=/app/uploads
GUEST_DOCUMENT_LIMIT=10

# Frontend
NEXT_PUBLIC_API_URL=https://your-backend.railway.app
```

### Production Checklist

- [ ] Environment variables configured
- [ ] Database migrations run
- [ ] File upload directory configured with proper permissions
- [ ] CORS settings updated for production domains
- [ ] HTTPS enabled
- [ ] Backup strategy implemented
- [ ] Monitoring and logging configured
- [ ] Rate limiting enabled for API endpoints

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

### Development Workflow

1. **Fork the repository**
   ```bash
   git clone https://github.com/yourusername/tax-forms-processor.git
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```

3. **Make your changes**
   - Follow existing code style
   - Add tests for new functionality
   - Update documentation as needed

4. **Commit your changes**
   ```bash
   git commit -m "Add amazing feature"
   ```

5. **Push to your branch**
   ```bash
   git push origin feature/amazing-feature
   ```

6. **Open a Pull Request**
   - Provide clear description of changes
   - Reference any related issues
   - Ensure CI/CD checks pass

### Code Style

**Backend (Python)**
- Follow PEP 8 guidelines
- Use type hints
- Write docstrings for functions and classes
- Run `black` for formatting
- Run `flake8` for linting

**Frontend (TypeScript)**
- Follow Airbnb React style guide
- Use TypeScript strict mode
- Use functional components with hooks
- Run `eslint` and `prettier`

### Testing

```bash
# Backend tests
cd backend
pytest

# Frontend tests
cd frontend
npm run test
```

### Reporting Issues

Please use GitHub Issues and include:
- Clear description of the problem
- Steps to reproduce
- Expected vs. actual behavior
- Screenshots if applicable
- Environment details (OS, browser, versions)

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024 [Your Name]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

[Full MIT License text...]
```

---

## 📞 Contact

**Project Maintainer**: [Your Name]

- Email: your.email@example.com
- LinkedIn: [Your LinkedIn Profile](https://linkedin.com/in/yourprofile)
- Portfolio: [your-portfolio.com](https://your-portfolio.com)
- GitHub: [@yourusername](https://github.com/yourusername)

**Project Links**:
- Repository: [https://github.com/yourusername/tax-forms-processor](https://github.com/yourusername/tax-forms-processor)
- Issue Tracker: [https://github.com/yourusername/tax-forms-processor/issues](https://github.com/yourusername/tax-forms-processor/issues)
- Live Demo: [https://tax-forms-processor.railway.app](https://tax-forms-processor.railway.app)

---

## 🙏 Acknowledgments

- [FastAPI](https://fastapi.tiangolo.com) for the excellent backend framework
- [Next.js](https://nextjs.org) for the powerful React framework
- [pdfplumber](https://github.com/jsvine/pdfplumber) for PDF extraction capabilities
- [Railway](https://railway.app) for simplified deployment
- Servicio de Rentas Internas (SRI) Ecuador for tax form specifications
- The open-source community for inspiration and support

---

## 📊 Project Status

![Development Status](https://img.shields.io/badge/Status-Active-success)
![Version](https://img.shields.io/badge/Version-1.0.0-blue)
![Build](https://img.shields.io/badge/Build-Passing-success)

**Current Version**: 1.0.0 (Production Ready)

**Recent Updates**:
- ✅ Phase 1 Complete: Database schema with user isolation
- ✅ User authentication and registration system
- ✅ Mobile-responsive design with dark mode
- ✅ Yearly financial summaries with accurate calculations
- 🚧 Phase 2 Queued: Guest session management backend logic
- 📋 Future: Additional Ecuadorian tax form types

---

## 🗺 Roadmap

### Version 1.1 (Q1 2025)
- [ ] Guest session document limit enforcement
- [ ] Automated cleanup of expired guest data
- [ ] Enhanced admin dashboard with usage analytics
- [ ] Bulk document upload functionality

### Version 1.2 (Q2 2025)
- [ ] Support for additional SRI forms (Form 107, Form 108)
- [ ] Advanced search and filtering capabilities
- [ ] Custom report templates
- [ ] Email notifications for processing completion

### Version 2.0 (Q3 2025)
- [ ] Machine learning-based data validation
- [ ] OCR support for scanned documents
- [ ] Multi-language support (English/Spanish)
- [ ] Mobile applications (iOS/Android)

---

<div align="center">

**Built with ❤️ for Ecuadorian businesses**

[⬆ Back to Top](#tax-forms-processor-)

</div>
