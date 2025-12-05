"""
Upload API Endpoints (Enhanced with Form Parsing and Guest Support)
✅ FIXED: Authenticated users checked FIRST (prevents 403 error)
"""

import os
import uuid
from typing import List, Optional
from fastapi import APIRouter, UploadFile, File, Depends, HTTPException, Request, Response
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import get_current_user_optional 
from app.core.database import get_db
from app.core.config import settings
from app.models.base import User, Document
from app.utils.session_utils import get_session_id_from_request, get_client_ip, get_user_agent
from app.core.guest_session import GuestSessionManager
from app.services.enhanced_form_processing_service import enhanced_form_processing_service
from pydantic import BaseModel

router = APIRouter()


class UploadResponse(BaseModel):
    """Response model for file upload"""
    success: bool
    message: str
    document_id: Optional[int] = None
    filename: str
    form_type: str
    processing_status: str


class BulkUploadResponse(BaseModel):
    """Response model for bulk upload"""
    success: bool
    total_files: int
    uploaded: List[UploadResponse]
    failed: List[dict]


@router.post("/bulk")
async def upload_multiple_pdfs(
    request: Request,
    response: Response,
    files: List[UploadFile] = File(...),
    db: AsyncSession = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user_optional)
):
    print("=" * 50)
    print(f"🔍 Current user: {current_user}")
    print(f"🔍 User ID: {current_user.id if current_user else 'None'}")
    print(f"🔍 Files: {len(files)}")
    print("=" * 50)
    """
    Upload multiple PDF files
    ✅ FIXED: Checks authenticated users FIRST to prevent 403
    """
    
    if not files:
        raise HTTPException(status_code=400, detail="No files provided")
    
    if len(files) > 20:
        raise HTTPException(status_code=400, detail="Maximum 20 files allowed per bulk upload")
    
    guest_manager = GuestSessionManager(db)
    
    # ============================================
    # ✅ AUTHENTICATED USER FLOW - CHECK FIRST!
    # ============================================
    if current_user:
        print(f"✅ Authenticated user upload: {current_user.username} (ID: {current_user.id})")
        
        uploaded = []
        failed = []
        
        for file in files:
            try:
                if not file.filename.lower().endswith('.pdf'):
                    failed.append({"filename": file.filename, "error": "Not a PDF file"})
                    continue
                
                if file.size and file.size > settings.MAX_UPLOAD_SIZE:
                    failed.append({
                        "filename": file.filename,
                        "error": f"File size exceeds maximum of {settings.MAX_UPLOAD_SIZE} bytes"
                    })
                    continue
                
                file_extension = os.path.splitext(file.filename)[1]
                unique_filename = f"{uuid.uuid4().hex}{file_extension}"
                file_path = os.path.join(settings.UPLOAD_DIR, unique_filename)
                
                with open(file_path, "wb") as buffer:
                    content = await file.read()
                    buffer.write(content)
                
                file_size = len(content)
                
                document = await enhanced_form_processing_service.process_uploaded_document(
                    file_path=file_path,
                    original_filename=file.filename,
                    file_size=file_size,
                    db=db,
                    user_id=current_user.id
                )
                
                await guest_manager.log_event(
                    event_type="user_upload",
                    user_id=current_user.id,
                    metadata={
                        "document_id": document.id,
                        "filename": file.filename,
                        "file_size": file_size
                    }
                )
                
                uploaded.append(UploadResponse(
                    success=True,
                    message="File uploaded and processed successfully",
                    document_id=document.id,
                    filename=file.filename,
                    form_type=document.form_type.value,
                    processing_status=document.processing_status.value
                ))
                
                print(f"  ✅ Saved document {document.id} for user {current_user.id}")
                
            except Exception as e:
                print(f"  ❌ Error: {str(e)}")
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
    
    # ============================================
    # GUEST USER FLOW - Only if NOT authenticated
    # ============================================
    else:
        print("👤 Guest user upload")
        
        session_id = get_session_id_from_request(request)
        ip_address = get_client_ip(request)
        user_agent = get_user_agent(request)
        
        guest_session = await guest_manager.get_or_create_session(
            session_id=session_id,
            ip_address=ip_address,
            user_agent=user_agent
        )
        
        if not session_id:
            response.set_cookie(
                key="session_id",
                value=guest_session.session_id,
                httponly=True,
                max_age=60 * 60 * 24 * 7,
                samesite="lax"
            )
        
        can_upload, remaining, message = await guest_manager.can_upload(guest_session.session_id)
        
        if not can_upload:
            raise HTTPException(status_code=403, detail=message)
        
        if len(files) > remaining:
            raise HTTPException(
                status_code=403,
                detail=f"Upload would exceed limit. You have {remaining} uploads remaining. Please register for unlimited uploads."
            )
        
        results = []
        failed = []
        
        for file in files:
            try:
                if not file.filename.lower().endswith('.pdf'):
                    failed.append({"filename": file.filename, "error": "Not a PDF file"})
                    continue
                
                file_extension = os.path.splitext(file.filename)[1]
                unique_filename = f"{uuid.uuid4().hex}{file_extension}"
                file_path = os.path.join(settings.UPLOAD_DIR, unique_filename)
                
                with open(file_path, "wb") as buffer:
                    content = await file.read()
                    buffer.write(content)
                
                file_size = len(content)
                
                result = await enhanced_form_processing_service.process_uploaded_document(
                    file_path=file_path,
                    original_filename=file.filename,
                    file_size=file_size,
                    db=db,
                    user_id=None
                )
                
                await guest_manager.track_temporary_file(
                    session_id=guest_session.session_id,
                    file_path=file_path,
                    file_size=file_size
                )
                
                await guest_manager.increment_document_count(guest_session.session_id)
                
                await guest_manager.log_event(
                    event_type="guest_upload",
                    session_id=guest_session.session_id,
                    metadata={
                        "filename": file.filename,
                        "file_size": file_size,
                        "form_type": result.form_type.value if result.form_type else "unknown"
                    }
                )
                
                results.append({
                    "filename": file.filename,
                    "success": True,
                    "status": "processed",
                    "document_id": None,
                    "form_type": result.form_type.value if result.form_type else "unknown",
                    "processing_status": "completed",
                    "message": "Processed successfully. Register to save permanently.",
                    "razon_social": result.razon_social,
                    "periodo": result.periodo_fiscal_completo
                })
                
            except Exception as e:
                if 'file_path' in locals() and os.path.exists(file_path):
                    os.remove(file_path)
                failed.append({"filename": file.filename, "error": str(e)})
        
        session_info = await guest_manager.get_session_info(guest_session.session_id)
        
        return {
            "success": True,
            "status": "success",
            "is_guest": True,
            "session_info": session_info,
            "uploaded": results,
            "failed": failed,
            "total_files": len(files),
            "message": f"Processed {len(results)} documents. {session_info['documents_remaining']} uploads remaining."
        }


# Keep all other endpoints (single upload, status, guest info) the same...
@router.post("/single", response_model=UploadResponse)
async def upload_single_pdf(
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user_optional)
):
    """Upload a single PDF file"""
    
    if not file.filename.lower().endswith('.pdf'):
        raise HTTPException(status_code=400, detail="Only PDF files are allowed")
    
    if file.size and file.size > settings.MAX_UPLOAD_SIZE:
        raise HTTPException(
            status_code=400,
            detail=f"File size exceeds maximum allowed size of {settings.MAX_UPLOAD_SIZE} bytes"
        )
    
    try:
        file_extension = os.path.splitext(file.filename)[1]
        unique_filename = f"{uuid.uuid4().hex}{file_extension}"
        file_path = os.path.join(settings.UPLOAD_DIR, unique_filename)
        
        with open(file_path, "wb") as buffer:
            content = await file.read()
            buffer.write(content)
        
        file_size = len(content)
        
        document = await enhanced_form_processing_service.process_uploaded_document(
            file_path=file_path,
            original_filename=file.filename,
            file_size=file_size,
            db=db,
            user_id=current_user.id if current_user else None
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
        if 'file_path' in locals() and os.path.exists(file_path):
            os.remove(file_path)
        
        raise HTTPException(status_code=500, detail=f"Error processing file: {str(e)}")


@router.get("/status/{document_id}")
async def get_upload_status(
    document_id: int,
    db: AsyncSession = Depends(get_db)
):
    """Get processing status of a document"""
    from sqlalchemy import select
    
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


@router.get("/guest/info")
async def get_guest_info(
    request: Request,
    db: AsyncSession = Depends(get_db)
):
    """Get information about current guest session"""
    session_id = get_session_id_from_request(request)
    
    if not session_id:
        return {
            "is_guest": True,
            "has_session": False,
            "documents_remaining": 5,
            "limit": 5
        }
    
    guest_manager = GuestSessionManager(db)
    session_info = await guest_manager.get_session_info(session_id)
    
    if not session_info:
        return {
            "is_guest": True,
            "has_session": False,
            "documents_remaining": 5,
            "limit": 5
        }
    
    return {
        "is_guest": True,
        "has_session": True,
        **session_info
    }
@router.get("/debug-session")
async def debug_session(
    request: Request,
    db: AsyncSession = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user_optional)
):
    """Debug endpoint to check session"""
    return {
        "current_user": {
            "id": current_user.id if current_user else None,
            "username": current_user.username if current_user else None,
        } if current_user else None,
        "session_data": dict(request.session),
        "cookies": dict(request.cookies),
        "headers": dict(request.headers),
    }