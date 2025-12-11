"""
Document Cleanup Service
Automatically removes old documents while preserving extracted data
"""

import os
from datetime import datetime, timedelta
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete
import logging

from app.models.base import Document
from app.core.config import settings

logger = logging.getLogger(__name__)


class DocumentCleanupService:
    """Service for cleaning up old documents"""
    
    def __init__(self, retention_days: int = 30):
        """
        retention_days: How many days to keep documents before cleanup
        Default: 30 days
        """
        self.retention_days = retention_days
    
    async def cleanup_old_documents(
        self,
        db: AsyncSession,
        dry_run: bool = False
    ) -> dict:
        """
        Clean up documents older than retention_days
        
        Cleanup strategy:
        1. Find documents older than retention_days
        2. Delete physical PDF files from disk
        3. Delete documents table rows (extracted data preserved in form_103/104 tables)
        
        Args:
            db: Database session
            dry_run: If True, only report what would be deleted (don't actually delete)
        
        Returns:
            dict with cleanup stats
        """
        cutoff_date = datetime.utcnow() - timedelta(days=self.retention_days)
        
        # Find old documents
        result = await db.execute(
            select(Document).where(Document.uploaded_at < cutoff_date)
        )
        old_documents = result.scalars().all()
        
        deleted_files = 0
        deleted_records = 0
        errors = []
        
        for doc in old_documents:
            try:
                # Delete physical file
                if doc.file_path and os.path.exists(doc.file_path):
                    if not dry_run:
                        os.remove(doc.file_path)
                        logger.info(f"🗑️ Deleted file: {doc.file_path}")
                    deleted_files += 1
                
                # Delete database record
                # NOTE: Extracted data in form_103_totals, form_103_line_items, 
                # form_104_data will be CASCADE deleted if you have foreign keys set up
                # OR preserved if you remove CASCADE
                if not dry_run:
                    await db.delete(doc)
                    deleted_records += 1
                    
            except Exception as e:
                errors.append(f"Error deleting document {doc.id}: {str(e)}")
                logger.error(f"❌ Error deleting document {doc.id}: {str(e)}")
        
        if not dry_run:
            await db.commit()
        
        stats = {
            "cutoff_date": cutoff_date.isoformat(),
            "retention_days": self.retention_days,
            "documents_found": len(old_documents),
            "files_deleted": deleted_files,
            "records_deleted": deleted_records,
            "errors": errors,
            "dry_run": dry_run
        }
        
        logger.info(f"🧹 Cleanup complete: {stats}")
        return stats
    
    async def cleanup_guest_documents(
        self,
        db: AsyncSession,
        dry_run: bool = False
    ) -> dict:
        """
        Clean up documents from guest users (user_id is NULL)
        Guests documents should be cleaned up after 24 hours
        """
        cutoff_date = datetime.utcnow() - timedelta(hours=24)
        
        result = await db.execute(
            select(Document).where(
                Document.user_id.is_(None),
                Document.uploaded_at < cutoff_date
            )
        )
        guest_documents = result.scalars().all()
        
        deleted_files = 0
        deleted_records = 0
        
        for doc in guest_documents:
            try:
                if doc.file_path and os.path.exists(doc.file_path):
                    if not dry_run:
                        os.remove(doc.file_path)
                    deleted_files += 1
                
                if not dry_run:
                    await db.delete(doc)
                    deleted_records += 1
                    
            except Exception as e:
                logger.error(f"Error deleting guest document {doc.id}: {str(e)}")
        
        if not dry_run:
            await db.commit()
        
        return {
            "cutoff_date": cutoff_date.isoformat(),
            "guest_documents_deleted": deleted_records,
            "files_deleted": deleted_files,
            "dry_run": dry_run
        }


# Singleton instance
document_cleanup_service = DocumentCleanupService(retention_days=30)