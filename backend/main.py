"""
Enhanced PDF Form Processor - Main Application
FastAPI backend with Form 103/104 parsing
"""

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import time
from contextlib import asynccontextmanager
import logging
import os

from app.core.config import settings
from app.core.database import engine
from app.models import base

# Import API routers
from app.api.clientes import router as clientes_router
from app.api import upload, documents, forms_data

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Lifespan events for the application.
    Runs on startup and shutdown.
    """
    # Startup
    logger.info("🚀 Starting Enhanced PDF Form Processor API...")
    logger.info(f"📊 Database: {settings.DATABASE_URL.split('@')[-1]}")
    logger.info(f"📁 Upload directory: {settings.UPLOAD_DIR}")
    
    # Create upload directory if it doesn't exist
    os.makedirs(settings.UPLOAD_DIR, exist_ok=True)
    
    yield
    
    # Shutdown
    logger.info("👋 Shutting down Enhanced PDF Form Processor API...")
    await engine.dispose()


# Create FastAPI application
app = FastAPI(
    title="Enhanced PDF Form Processor",
    description="Extracts structured data from Ecuadorian Form 103 and 104",
    version="2.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan
)

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Middleware for request timing
@app.middleware("http")
async def add_process_time_header(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    process_time = time.time() - start_time
    response.headers["X-Process-Time"] = str(process_time)
    return response


# Root endpoint
@app.get("/")
async def root():
    """Root endpoint - API health check"""
    return {
        "message": "Enhanced PDF Form Processor API",
        "version": "2.0.0",
        "features": [
            "Form 103 (Retenciones) parsing",
            "Form 104 (IVA) parsing",
            "Structured data extraction",
            "Database storage"
        ],
        "status": "online",
        "docs": "/docs"
    }


# Health check endpoint
@app.get("/health")
async def health_check():
    """Health check endpoint for monitoring"""
    from sqlalchemy import text
    
    # Check database
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


# Include API routers
app.include_router(upload.router, prefix="/api/upload", tags=["Upload"])
app.include_router(documents.router, prefix="/api/documents", tags=["Documents"])
app.include_router(forms_data.router, prefix="/api/forms-data", tags=["Forms Data"])
app.include_router(clientes_router, prefix="/api", tags=["Clientes"])

# Global exception handler
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    """Global exception handler for unhandled errors"""
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
