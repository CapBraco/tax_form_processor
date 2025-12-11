"""
Background scheduler for periodic tasks
"""

import asyncio
from datetime import datetime
import logging

from app.core.database import AsyncSessionLocal
from app.services.document_cleanup_service import document_cleanup_service

logger = logging.getLogger(__name__)


async def run_daily_cleanup():
    """Run cleanup task daily at 2 AM"""
    while True:
        try:
            # Wait until 2 AM
            now = datetime.now()
            next_run = now.replace(hour=2, minute=0, second=0, microsecond=0)
            if next_run <= now:
                next_run = next_run.replace(day=next_run.day + 1)
            
            wait_seconds = (next_run - now).total_seconds()
            logger.info(f"⏰ Next cleanup scheduled for: {next_run}")
            
            await asyncio.sleep(wait_seconds)
            
            # Run cleanup
            logger.info("🧹 Starting scheduled cleanup...")
            async with AsyncSessionLocal() as db:
                # Cleanup registered user documents (30 days)
                stats = await document_cleanup_service.cleanup_old_documents(db, dry_run=False)
                logger.info(f"✅ Cleanup stats: {stats}")
                
                # Cleanup guest documents (24 hours)
                guest_stats = await document_cleanup_service.cleanup_guest_documents(db, dry_run=False)
                logger.info(f"✅ Guest cleanup stats: {guest_stats}")
                
        except Exception as e:
            logger.error(f"❌ Cleanup error: {str(e)}")
            await asyncio.sleep(3600)  # Wait 1 hour before retry


async def start_scheduler():
    """Start background scheduler"""
    logger.info("🚀 Starting background scheduler...")
    asyncio.create_task(run_daily_cleanup())