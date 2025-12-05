"""
Documents API Endpoints - CORRECTED: Dual Access
✅ Works for both guests and registered users
✅ Only Clientes section requires registration
"""

from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, desc, and_
from pydantic import BaseModel
from datetime import datetime

from app.core.database import get_db
from app.core.security import get_current_user_optional  # ← CHANGED: Optional auth
from app.models.base import Document, ProcessingStatusEnum, User

router = APIRouter()


class DocumentListItem(BaseModel):
    """Document list item response model"""
    id: int
    filename: str
    file_size: int
    total_pages: Optional[int]
    total_characters: Optional[int]
    processing_status: str
    uploaded_at: str
    processed_at: Optional[str]


class DocumentListResponse(BaseModel):
    """Response model for document list"""
    total: int
    page: int
    page_size: int
    documents: List[DocumentListItem]


class DocumentDetail(BaseModel):
    """Detailed document information"""
    id: int
    filename: str
    original_filename: str
    file_size: int
    total_pages: Optional[int]
    total_characters: Optional[int]
    processing_status: str
    processing_error: Optional[str]
    uploaded_at: str
    processed_at: Optional[str]
    extracted_text: Optional[str]


@router.get("/", response_model=DocumentListResponse)
async def list_documents(
    page: int = Query(1, ge=1, description="Page number"),
    page_size: int = Query(20, ge=1, le=100, description="Items per page"),
    status: Optional[str] = Query(None, description="Filter by processing status"),
    db: AsyncSession = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user_optional)  # ← CHANGED: Optional
):
    """
    List documents with pagination and filters
    ✅ CORRECTED: If user is logged in, show their documents only
    ✅ If guest, show empty list (guests don't save to DB)
    """
    
    # If not logged in, return empty list (guests don't save documents)
    if not current_user:
        return DocumentListResponse(
            total=0,
            page=page,
            page_size=page_size,
            documents=[]
        )
    
    # Build query with user_id filter for logged-in users
    query = select(Document).where(Document.user_id == current_user.id)
    
    # Apply filters
    if status:
        try:
            status_enum = ProcessingStatusEnum(status)
            query = query.where(Document.processing_status == status_enum)
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid status")
    
    # Get total count for user
    count_query = select(func.count()).select_from(
        select(Document).where(Document.user_id == current_user.id).subquery()
    )
    total_result = await db.execute(count_query)
    total = total_result.scalar()
    
    # Add pagination and ordering
    query = query.order_by(desc(Document.uploaded_at))
    query = query.offset((page - 1) * page_size).limit(page_size)
    
    # Execute query
    result = await db.execute(query)
    documents = result.scalars().all()
    
    # Build response
    document_items = []
    for doc in documents:
        document_items.append(DocumentListItem(
            id=doc.id,
            filename=doc.original_filename,
            file_size=doc.file_size,
            total_pages=doc.total_pages,
            total_characters=doc.total_characters,
            processing_status=doc.processing_status.value,
            uploaded_at=doc.uploaded_at.isoformat() if doc.uploaded_at else None,
            processed_at=doc.processed_at.isoformat() if doc.processed_at else None
        ))
    
    return DocumentListResponse(
        total=total,
        page=page,
        page_size=page_size,
        documents=document_items
    )


@router.get("/{document_id}", response_model=DocumentDetail)
async def get_document_detail(
    document_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user_optional)  # ← CHANGED: Optional
):
    """
    Get detailed information about a specific document
    ✅ CORRECTED: Only registered users who own the document can access
    """
    
    # Must be logged in to access saved documents
    if not current_user:
        raise HTTPException(
            status_code=401,
            detail="Please register or login to access saved documents"
        )
    
    # Get document with ownership check
    result = await db.execute(
        select(Document).where(
            and_(
                Document.id == document_id,
                Document.user_id == current_user.id
            )
        )
    )
    document = result.scalar_one_or_none()
    
    if not document:
        raise HTTPException(
            status_code=404,
            detail="Document not found or you don't have permission to access it"
        )
    
    return DocumentDetail(
        id=document.id,
        filename=document.filename,
        original_filename=document.original_filename,
        file_size=document.file_size,
        total_pages=document.total_pages,
        total_characters=document.total_characters,
        processing_status=document.processing_status.value,
        processing_error=document.processing_error,
        uploaded_at=document.uploaded_at.isoformat() if document.uploaded_at else None,
        processed_at=document.processed_at.isoformat() if document.processed_at else None,
        extracted_text=document.extracted_text
    )


@router.delete("/{document_id}")
async def delete_document(
    document_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user_optional)  # ← CHANGED: Optional
):
    """
    Delete a document and its file
    ✅ CORRECTED: Only registered users who own the document can delete
    """
    
    # Must be logged in to delete saved documents
    if not current_user:
        raise HTTPException(
            status_code=401,
            detail="Please register or login to manage saved documents"
        )
    
    # Get document with ownership check
    result = await db.execute(
        select(Document).where(
            and_(
                Document.id == document_id,
                Document.user_id == current_user.id
            )
        )
    )
    document = result.scalar_one_or_none()
    
    if not document:
        raise HTTPException(
            status_code=404,
            detail="Document not found or you don't have permission to delete it"
        )
    
    # Delete physical file
    import os
    if os.path.exists(document.file_path):
        os.remove(document.file_path)
    
    # Delete from database
    await db.delete(document)
    await db.commit()
    
    return {"success": True, "message": "Document deleted successfully"}


@router.get("/stats/overview")
async def get_documents_stats(
    db: AsyncSession = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user_optional)  # ← CHANGED: Optional
):
    """
    Get overview statistics about documents
    ✅ CORRECTED: If logged in, show user's stats. If guest, show empty stats.
    """
    
    # If not logged in, return empty stats
    if not current_user:
        return {
            "total_documents": 0,
            "by_status": {
                "completed": 0,
                "processing": 0,
                "failed": 0,
                "pending": 0
            },
            "total_pages_extracted": 0,
            "total_characters_extracted": 0
        }
    
    # Total documents for user
    total_result = await db.execute(
        select(func.count(Document.id)).where(Document.user_id == current_user.id)
    )
    total_documents = total_result.scalar()
    
    # By status for user
    completed_result = await db.execute(
        select(func.count(Document.id)).where(
            and_(
                Document.processing_status == ProcessingStatusEnum.COMPLETED,
                Document.user_id == current_user.id
            )
        )
    )
    completed_count = completed_result.scalar()
    
    processing_result = await db.execute(
        select(func.count(Document.id)).where(
            and_(
                Document.processing_status == ProcessingStatusEnum.PROCESSING,
                Document.user_id == current_user.id
            )
        )
    )
    processing_count = processing_result.scalar()
    
    failed_result = await db.execute(
        select(func.count(Document.id)).where(
            and_(
                Document.processing_status == ProcessingStatusEnum.FAILED,
                Document.user_id == current_user.id
            )
        )
    )
    failed_count = failed_result.scalar()
    
    # Total characters extracted for user
    total_chars_result = await db.execute(
        select(func.sum(Document.total_characters)).where(
            and_(
                Document.total_characters.isnot(None),
                Document.user_id == current_user.id
            )
        )
    )
    total_characters = total_chars_result.scalar() or 0
    
    # Total pages for user
    total_pages_result = await db.execute(
        select(func.sum(Document.total_pages)).where(
            and_(
                Document.total_pages.isnot(None),
                Document.user_id == current_user.id
            )
        )
    )
    total_pages = total_pages_result.scalar() or 0
    
    return {
        "total_documents": total_documents,
        "by_status": {
            "completed": completed_count,
            "processing": processing_count,
            "failed": failed_count,
            "pending": total_documents - processing_count - completed_count - failed_count
        },
        "total_pages_extracted": total_pages,
        "total_characters_extracted": total_characters
    }