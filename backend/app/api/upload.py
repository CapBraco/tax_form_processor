"""
Upload API Endpoints (Enhanced with Form Parsing)
Handles PDF file uploads and structured data extraction
"""

import os
import uuid
from typing import List
from fastapi import APIRouter, UploadFile, File, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.config import settings
from app.services.enhanced_form_processing_service import enhanced_form_processing_service
from pydantic import BaseModel

router = APIRouter()


class UploadResponse(BaseModel):
    """Response model for file upload"""
    success: bool
    message: str
    document_id: int
    filename: str
    form_type: str
    processing_status: str


class BulkUploadResponse(BaseModel):
    """Response model for bulk upload"""
    success: bool
    total_files: int
    uploaded: List[UploadResponse]
    failed: List[dict]


@router.post("/single", response_model=UploadResponse)
async def upload_single_pdf(
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db)
):
    """
    Upload a single PDF file for text extraction and form parsing
    
    - **file**: PDF file to upload (Form 103 or Form 104)
    
    Returns the document ID and extracted structured data
    """
    # Validate file
    if not file.filename.lower().endswith('.pdf'):
        raise HTTPException(status_code=400, detail="Only PDF files are allowed")
    
    if file.size and file.size > settings.MAX_UPLOAD_SIZE:
        raise HTTPException(
            status_code=400,
            detail=f"File size exceeds maximum allowed size of {settings.MAX_UPLOAD_SIZE} bytes"
        )
    
    try:
        # Generate unique filename
        file_extension = os.path.splitext(file.filename)[1]
        unique_filename = f"{uuid.uuid4().hex}{file_extension}"
        file_path = os.path.join(settings.UPLOAD_DIR, unique_filename)
        
        # Save uploaded file
        with open(file_path, "wb") as buffer:
            content = await file.read()
            buffer.write(content)
        
        file_size = len(content)
        
        # Process the document (extract text and parse form)
        document = await enhanced_form_processing_service.process_uploaded_document(
            file_path=file_path,
            original_filename=file.filename,
            file_size=file_size,
            db=db
        )
        
        return UploadResponse(
            success=True,
            message="File uploaded and processed successfully",
            document_id=document.id,
            filename=file.filename,
            form_type=document.form_type.value,
            processing_status=document.processing_status.value
        )
        
    except Exception as e:
        # Clean up file if processing failed
        if 'file_path' in locals() and os.path.exists(file_path):
            os.remove(file_path)
        
        raise HTTPException(status_code=500, detail=f"Error processing file: {str(e)}")


@router.post("/bulk", response_model=BulkUploadResponse)
async def upload_multiple_pdfs(
    files: List[UploadFile] = File(...),
    db: AsyncSession = Depends(get_db)
):
    """
    Upload multiple PDF files for text extraction and form parsing
    
    - **files**: List of PDF files to upload
    
    Returns list of uploaded files with their processing status
    """
    if not files:
        raise HTTPException(status_code=400, detail="No files provided")
    
    if len(files) > 20:
        raise HTTPException(status_code=400, detail="Maximum 20 files allowed per bulk upload")
    
    uploaded = []
    failed = []
    
    for file in files:
        try:
            # Validate file
            if not file.filename.lower().endswith('.pdf'):
                failed.append({
                    "filename": file.filename,
                    "error": "Not a PDF file"
                })
                continue
            
            if file.size and file.size > settings.MAX_UPLOAD_SIZE:
                failed.append({
                    "filename": file.filename,
                    "error": f"File size exceeds maximum of {settings.MAX_UPLOAD_SIZE} bytes"
                })
                continue
            
            # Generate unique filename
            file_extension = os.path.splitext(file.filename)[1]
            unique_filename = f"{uuid.uuid4().hex}{file_extension}"
            file_path = os.path.join(settings.UPLOAD_DIR, unique_filename)
            
            # Save uploaded file
            with open(file_path, "wb") as buffer:
                content = await file.read()
                buffer.write(content)
            
            file_size = len(content)
            
            # Process the document
            document = await enhanced_form_processing_service.process_uploaded_document(
                file_path=file_path,
                original_filename=file.filename,
                file_size=file_size,
                db=db
            )
            
            uploaded.append(UploadResponse(
                success=True,
                message="File uploaded and processed successfully",
                document_id=document.id,
                filename=file.filename,
                form_type=document.form_type.value,
                processing_status=document.processing_status.value
            ))
            
        except Exception as e:
            # Clean up file if processing failed
            if 'file_path' in locals() and os.path.exists(file_path):
                os.remove(file_path)
            
            failed.append({
                "filename": file.filename,
                "error": str(e)
            })
    
    return BulkUploadResponse(
        success=len(failed) == 0,
        total_files=len(files),
        uploaded=uploaded,
        failed=failed
    )


@router.get("/status/{document_id}")
async def get_upload_status(
    document_id: int,
    db: AsyncSession = Depends(get_db)
):
    """
    Get processing status and basic info of a document
    
    - **document_id**: ID of the document
    
    Returns the current processing status
    """
    from app.services.enhanced_form_processing_service import enhanced_form_processing_service
    from sqlalchemy import select
    from app.models.base import Document
    
    result = await db.execute(
        select(Document).where(Document.id == document_id)
    )
    document = result.scalar_one_or_none()
    
    if not document:
        raise HTTPException(status_code=404, detail="Document not found")
    
    return {
        "id": document.id,
        "filename": document.original_filename,
        "form_type": document.form_type.value,
        "file_size": document.file_size,
        "total_pages": document.total_pages,
        "total_characters": document.total_characters,
        "processing_status": document.processing_status.value,
        "processing_error": document.processing_error,
        "razon_social": document.razon_social,
        "periodo": f"{document.periodo_mes} {document.periodo_anio}" if document.periodo_mes else None,
        "uploaded_at": document.uploaded_at.isoformat() if document.uploaded_at else None,
        "processed_at": document.processed_at.isoformat() if document.processed_at else None
    }
