"""
Enhanced PDF Form Processor - Main Application
✅ FINAL VERSION: All routers registered correctly
✅ FIXED: Proper CORS configuration with environment variables
✅ FIXED: Session middleware with correct settings
"""

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import time
from contextlib import asynccontextmanager
import logging
import os
import json
from starlette.middleware.sessions import SessionMiddleware

from app.core.config import settings
from app.core.database import engine
from app.models import base

# ✅ Import ALL routers including admin
from app.api import (
    auth, 
    upload, 
    documents, 
    clientes, 
    dashboard, 
    form_103, 
    form_104,
    forms_data,
    admin
)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Lifespan events"""
    # Startup
    logger.info("🚀 Starting Enhanced PDF Form Processor API...")
    logger.info(f"📊 Database: {settings.DATABASE_URL.split('@')[-1]}")
    logger.info(f"📁 Upload directory: {settings.UPLOAD_DIR}")
    
    os.makedirs(settings.UPLOAD_DIR, exist_ok=True)
    from app.core.scheduler import start_scheduler
    await start_scheduler()
    
    yield
    
    # Shutdown
    logger.info("👋 Shutting down...")
    await engine.dispose()


# Create app
app = FastAPI(
    title="Enhanced PDF Form Processor",
    description="Form 103 & 104 Processing with User Data Isolation",
    version="2.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan
)

# ===================================
# Middleware Configuration
# ===================================

# Session Middleware - MUST BE FIRST
# ✅ FIXED: Proper session settings for production
app.add_middleware(
    SessionMiddleware,
    secret_key=settings.SECRET_KEY,
    same_site='lax',  # Changed from 'none' - better compatibility
    https_only=True,  # Enforce HTTPS in production
    max_age=1209600,  # 14 days
    session_cookie='session'
)
logger.info("✅ Session middleware configured")

# ===================================
# CORS Configuration - READS FROM ENVIRONMENT
# ===================================

# Read from environment variables
FRONTEND_URL = os.getenv("FRONTEND_URL", "http://localhost:3000")
BACKEND_URL = os.getenv("BACKEND_URL", "http://localhost:8000")

logger.info(f"📝 Environment variables loaded:")
logger.info(f"   FRONTEND_URL: {FRONTEND_URL}")
logger.info(f"   BACKEND_URL: {BACKEND_URL}")

# Try to read CORS_ORIGINS from environment (Railway variable)
# Expected format: ["https://example.com","https://www.example.com"]
cors_origins_str = os.getenv("CORS_ORIGINS")
extra_origins = []

if cors_origins_str:
    try:
        # Parse JSON array from environment variable
        extra_origins = json.loads(cors_origins_str)
        logger.info(f"   CORS_ORIGINS parsed: {extra_origins}")
    except json.JSONDecodeError as e:
        logger.warning(f"⚠️  Failed to parse CORS_ORIGINS: {e}")
        extra_origins = []

# Build comprehensive allowed origins list
allowed_origins = [
    FRONTEND_URL,
    BACKEND_URL,
    # Add any extra origins from CORS_ORIGINS variable
    *extra_origins,
    # Local development fallbacks
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    "http://localhost:8000",
    "http://127.0.0.1:8000",
]

# Remove duplicates and None/empty values
allowed_origins = list(set([origin for origin in allowed_origins if origin and origin.strip()]))

# Add CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
    allow_headers=["*"],
    expose_headers=["*"],
    max_age=3600,
)

logger.info(f"🌐 CORS configured for {len(allowed_origins)} origins:")
for origin in allowed_origins:
    logger.info(f"   ✓ {origin}")


# Process time middleware
@app.middleware("http")
async def add_process_time_header(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    process_time = time.time() - start_time
    response.headers["X-Process-Time"] = str(process_time)
    return response


# ===================================
# Root & Health Endpoints
# ===================================

@app.get("/")
async def root():
    return {
        "message": "Enhanced PDF Form Processor API",
        "version": "2.0.0",
        "status": "online",
        "docs": "/docs",
        "environment": {
            "frontend_url": FRONTEND_URL,
            "backend_url": BACKEND_URL,
            "cors_origins_count": len(allowed_origins)
        }
    }


@app.get("/health")
async def health_check():
    from sqlalchemy import text
    
    db_status = "connected"
    try:
        from app.core.database import AsyncSessionLocal
        async with AsyncSessionLocal() as session:
            await session.execute(text("SELECT 1"))
    except Exception as e:
        db_status = f"error: {str(e)}"
    
    return {
        "status": "healthy" if db_status == "connected" else "degraded",
        "database": db_status,
        "version": "2.0.0",
        "cors_enabled": True,
        "allowed_origins_count": len(allowed_origins)
    }


# ===================================
# ✅ Register ALL Routers
# ===================================

# Authentication
app.include_router(auth.router, prefix="/api", tags=["Authentication"])

# Upload
app.include_router(upload.router, prefix="/api/upload", tags=["Upload"])

# Documents
app.include_router(documents.router, prefix="/api/documents", tags=["Documents"])

# Clientes
app.include_router(clientes.router, prefix="/api", tags=["Clientes"])

# Dashboard
app.include_router(dashboard.router, prefix="/api", tags=["Dashboard"])

# Form 103
app.include_router(form_103.router, prefix="/api", tags=["Form 103"])

# Form 104
app.include_router(form_104.router, prefix="/api", tags=["Form 104"])

# Forms Data
app.include_router(forms_data.router, prefix="/api/forms-data", tags=["Forms Data"])

# Admin
app.include_router(admin.router, prefix="/api", tags=["Admin"])

logger.info("✅ All API routers registered successfully")


# ===================================
# Global Exception Handler
# ===================================

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    logger.error(f"Unhandled exception: {exc}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={
            "message": "Internal server error",
            "detail": str(exc) if settings.DEBUG else "An error occurred"
        }
    )


# ===================================
# Development Server
# ===================================

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.DEBUG
    )