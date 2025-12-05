"""
Dashboard API - Phase 3: User Data Isolation
✅ All statistics filtered by user_id
"""

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, and_
from datetime import datetime

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.base import User, Document, FormTypeEnum

router = APIRouter(prefix="/dashboard", tags=["dashboard"])


@router.get("/stats")
async def get_dashboard_stats(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get dashboard statistics for current user only
    ✅ PHASE 3: All stats filtered by user_id
    """
    
    # Total documents for user
    total_result = await db.execute(
        select(func.count(Document.id)).where(Document.user_id == current_user.id)
    )
    total_documents = total_result.scalar()
    
    # Documents by form type for user
    form_type_result = await db.execute(
        select(
            Document.form_type,
            func.count(Document.id).label('count')
        )
        .where(Document.user_id == current_user.id)
        .group_by(Document.form_type)
    )
    by_form_type = {row.form_type.value: row.count for row in form_type_result.all()}
    
    # Unique clients for user
    clients_result = await db.execute(
        select(func.count(func.distinct(Document.razon_social)))
        .where(
            and_(
                Document.user_id == current_user.id,
                Document.razon_social.isnot(None)
            )
        )
    )
    unique_clients = clients_result.scalar()
    
    # Recent uploads for user
    recent_result = await db.execute(
        select(Document)
        .where(Document.user_id == current_user.id)
        .order_by(Document.uploaded_at.desc())
        .limit(5)
    )
    recent_documents = recent_result.scalars().all()
    
    return {
        "total_documents": total_documents,
        "by_form_type": by_form_type,
        "unique_clients": unique_clients,
        "recent_uploads": [
            {
                "id": doc.id,
                "filename": doc.original_filename,
                "razon_social": doc.razon_social,
                "periodo": doc.periodo_fiscal_completo,
                "uploaded_at": doc.uploaded_at.isoformat() if doc.uploaded_at else None
            }
            for doc in recent_documents
        ]
    }