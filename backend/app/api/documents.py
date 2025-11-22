"""
Documents API Endpoints (Simplified)
Handles listing and managing documents
"""

from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, desc
from pydantic import BaseModel
from datetime import datetime

from app.core.database import get_db
from app.models.base import Document, ProcessingStatusEnum

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
    db: AsyncSession = Depends(get_db)
):
    """
    List all documents with pagination and filters
    
    - **page**: Page number (default: 1)
    - **page_size**: Items per page (default: 20)
    - **status**: Filter by processing status
    """
    # Build query
    query = select(Document)
    
    # Apply filters
    if status:
        try:
            status_enum = ProcessingStatusEnum(status)
            query = query.where(Document.processing_status == status_enum)
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid status")
    
    # Get total count
    count_query = select(func.count()).select_from(query.subquery())
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
    db: AsyncSession = Depends(get_db)
):
    """
    Get detailed information about a specific document including extracted text
    
    - **document_id**: ID of the document
    """
    # Get document
    result = await db.execute(
        select(Document).where(Document.id == document_id)
    )
    document = result.scalar_one_or_none()
    
    if not document:
        raise HTTPException(status_code=404, detail="Document not found")
    
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
    db: AsyncSession = Depends(get_db)
):
    """
    Delete a document and its file
    
    - **document_id**: ID of the document to delete
    """
    # Get document
    result = await db.execute(
        select(Document).where(Document.id == document_id)
    )
    document = result.scalar_one_or_none()
    
    if not document:
        raise HTTPException(status_code=404, detail="Document not found")
    
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
    db: AsyncSession = Depends(get_db)
):
    """
    Get overview statistics about documents
    """
    # Total documents
    total_result = await db.execute(select(func.count(Document.id)))
    total_documents = total_result.scalar()
    
    # By status
    completed_result = await db.execute(
        select(func.count(Document.id)).where(Document.processing_status == ProcessingStatusEnum.COMPLETED)
    )
    completed_count = completed_result.scalar()
    
    processing_result = await db.execute(
        select(func.count(Document.id)).where(Document.processing_status == ProcessingStatusEnum.PROCESSING)
    )
    processing_count = processing_result.scalar()
    
    failed_result = await db.execute(
        select(func.count(Document.id)).where(Document.processing_status == ProcessingStatusEnum.FAILED)
    )
    failed_count = failed_result.scalar()
    
    # Total characters extracted
    total_chars_result = await db.execute(
        select(func.sum(Document.total_characters)).where(Document.total_characters.isnot(None))
    )
    total_characters = total_chars_result.scalar() or 0
    
    # Total pages
    total_pages_result = await db.execute(
        select(func.sum(Document.total_pages)).where(Document.total_pages.isnot(None))
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
