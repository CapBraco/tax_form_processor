"""
Cleanup Jobs
Scheduled tasks to clean up expired guest sessions and temporary files
"""

import asyncio
import logging
from datetime import datetime
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import async_session_maker
from app.core.guest_session import cleanup_expired_sessions, cleanup_expired_files

logger = logging.getLogger(__name__)


async def run_cleanup_job():
    """
    Run cleanup job to remove expired sessions and files
    Should be run periodically (e.g., daily via cron or scheduler)
    """
    logger.info("🧹 Starting cleanup job...")
    
    async with async_session_maker() as db:
        try:
            # Clean up expired sessions
            sessions_deleted = await cleanup_expired_sessions(db)
            logger.info(f"✅ Deleted {sessions_deleted} expired guest sessions")
            
            # Clean up expired files
            files_deleted = await cleanup_expired_files(db)
            logger.info(f"✅ Deleted {files_deleted} expired temporary files")
            
            logger.info("✅ Cleanup job completed successfully")
            
            return {
                "success": True,
                "sessions_deleted": sessions_deleted,
                "files_deleted": files_deleted,
                "timestamp": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"❌ Cleanup job failed: {e}")
            return {
                "success": False,
                "error": str(e),
                "timestamp": datetime.utcnow().isoformat()
            }


async def cleanup_loop(interval_hours: int = 24):
    """
    Run cleanup job in a loop at specified interval
    
    Args:
        interval_hours: Hours between cleanup runs (default: 24)
    """
    while True:
        await run_cleanup_job()
        
        # Wait for next run
        wait_seconds = interval_hours * 60 * 60
        logger.info(f"⏰ Next cleanup in {interval_hours} hours...")
        await asyncio.sleep(wait_seconds)


# ========================================
# Manual cleanup script
# ========================================

if __name__ == "__main__":
    """
    Run cleanup manually:
    python -m app.core.cleanup
    """
    asyncio.run(run_cleanup_job())
