"""
Enhanced PDF Form Processor - Main Application
✅ FINAL VERSION: All routers registered correctly
"""

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import time
from contextlib import asynccontextmanager
import logging
import os
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
    admin  # ✅ MUST IMPORT THIS
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
# Middleware - MUST BE FIRST
# ===================================
app.add_middleware(SessionMiddleware, secret_key="wJ9vF6qL2Zs8XhK4bQp1nRm3GtYxVcDa")

allowed_origins = [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    "http://localhost:8000",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
    allow_headers=["*"],
    expose_headers=["*"],
    max_age=3600,
)

logger.info(f"🌐 CORS configured for origins: {allowed_origins}")


@app.middleware("http")
async def add_process_time_header(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    process_time = time.time() - start_time
    response.headers["X-Process-Time"] = str(process_time)
    return response


# ===================================
# Root & Health
# ===================================
@app.get("/")
async def root():
    return {
        "message": "Enhanced PDF Form Processor API",
        "version": "2.0.0",
        "status": "online",
        "docs": "/docs"
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
        "version": "2.0.0"
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

# ✅ Admin (YOUR EXISTING admin.py)
app.include_router(admin.router, prefix="/api", tags=["Admin"])


# ===================================
# Exception Handler
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


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.DEBUG
    )