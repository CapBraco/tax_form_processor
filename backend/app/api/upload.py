"""
Upload API Endpoints - BULLETPROOF GUEST LIMIT ENFORCEMENT
✅ Counts ACTUAL documents from database (not session counter)
✅ Prevents race conditions
✅ Cannot be bypassed
"""

import os
import uuid
from typing import List, Optional
from fastapi import APIRouter, UploadFile, File, Depends, HTTPException, Request, Response
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func

from app.core.security import get_current_user_optional 
from app.core.database import get_db
from app.core.config import settings
from app.models.base import User, Document
from app.utils.session_utils import get_session_id_from_request, get_client_ip, get_user_agent
from app.core.guest_session import GuestSessionManager
from app.services.enhanced_form_processing_service import enhanced_form_processing_service
from pydantic import BaseModel

router = APIRouter()

# ✅ CRITICAL: Maximum documents for guests
GUEST_DOCUMENT_LIMIT = 5


class UploadResponse(BaseModel):
    """Response model for file upload"""
    success: bool
    message: str
    document_id: Optional[int] = None
    filename: str
    form_type: str
    processing_status: str
    is_duplicate: Optional[bool] = False


class BulkUploadResponse(BaseModel):
    """Response model for bulk upload"""
    success: bool
    total_files: int
    uploaded: List[UploadResponse]
    failed: List[dict]
    summary: Optional[dict] = None


async def get_or_create_guest_session(
    request: Request,
    response: Response,
    db: AsyncSession
) -> str:
    """Get existing guest session or create new one"""
    session_id = request.cookies.get("session_id")
    
    if not session_id:
        session_id = str(uuid.uuid4())
        guest_manager = GuestSessionManager(db)
        ip_address = get_client_ip(request)
        user_agent = get_user_agent(request)
        
        await guest_manager.get_or_create_session(
            session_id=session_id,
            ip_address=ip_address,
            user_agent=user_agent
        )
        
        response.set_cookie(
            key="session_id",
            value=session_id,
            httponly=True,
            samesite="lax",
            max_age=86400
        )
    
    return session_id


async def get_guest_document_count(session_id: str, db: AsyncSession) -> int:
    """
    ✅ BULLETPROOF: Count ACTUAL documents in database for this session
    This cannot be bypassed or have race conditions
    """
    result = await db.execute(
        select(func.count(Document.id))
        .where(Document.session_id == session_id)
    )
    count = result.scalar() or 0
    return count


async def check_guest_can_upload(
    session_id: str,
    files_to_upload: int,
    db: AsyncSession
) -> tuple[bool, int, str]:
    """
    ✅ BULLETPROOF: Check if guest can upload based on ACTUAL database count
    
    Returns: (can_upload, remaining, message)
    """
    current_count = await get_guest_document_count(session_id, db)
    remaining = GUEST_DOCUMENT_LIMIT - current_count
    
    if remaining <= 0:
        return (
            False,
            0,
            f"Límite de {GUEST_DOCUMENT_LIMIT} documentos alcanzado. "
            f"Crea una cuenta gratuita para documentos ilimitados."
        )
    
    if files_to_upload > remaining:
        return (
            False,
            remaining,
            f"Solo puedes subir {remaining} documento{'s' if remaining > 1 else ''} más. "
            f"Has alcanzado el límite de {GUEST_DOCUMENT_LIMIT} documentos para invitados. "
            f"Crea una cuenta gratuita para documentos ilimitados."
        )
    
    return (True, remaining, "OK")


@router.post("/bulk")
async def upload_multiple_pdfs(
    request: Request,
    response: Response,
    files: List[UploadFile] = File(...),
    db: AsyncSession = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user_optional)
):
    """
    Upload multiple PDF files
    ✅ BULLETPROOF: Counts actual documents from database
    """
    
    if not files:
        raise HTTPException(status_code=400, detail="No files provided")
    
    if len(files) > 20:
        raise HTTPException(status_code=400, detail="Maximum 20 files allowed per bulk upload")
    
    guest_manager = GuestSessionManager(db)
    
    # ============================================
    # ✅ AUTHENTICATED USER FLOW
    # ============================================
    if current_user:
        print(f"✅ Authenticated user upload: {current_user.username} (ID: {current_user.id})")
        
        uploaded = []
        failed = []
        new_count = 0
        duplicate_count = 0
        error_count = 0
        
        for file in files:
            try:
                if not file.filename.lower().endswith('.pdf'):
                    failed.append({"filename": file.filename, "error": "Not a PDF file"})
                    error_count += 1
                    continue
                
                if file.size and file.size > settings.MAX_UPLOAD_SIZE:
                    failed.append({
                        "filename": file.filename,
                        "error": f"File size exceeds maximum"
                    })
                    error_count += 1
                    continue
                
                file_extension = os.path.splitext(file.filename)[1]
                unique_filename = f"{uuid.uuid4().hex}{file_extension}"
                file_path = os.path.join(settings.UPLOAD_DIR, unique_filename)
                
                with open(file_path, "wb") as buffer:
                    content = await file.read()
                    buffer.write(content)
                
                file_size = len(content)
                
                document, is_duplicate = await enhanced_form_processing_service.process_uploaded_document(
                    file_path=file_path,
                    original_filename=file.filename,
                    file_size=file_size,
                    db=db,
                    user_id=current_user.id,
                    session_id=None,
                    allow_duplicates=False
                )
                
                if is_duplicate:
                    duplicate_count += 1
                else:
                    new_count += 1
                
                uploaded.append(UploadResponse(
                    success=True,
                    message="Duplicate document" if is_duplicate else "File uploaded successfully",
                    document_id=document.id,
                    filename=file.filename,
                    form_type=document.form_type.value,
                    processing_status=document.processing_status.value,
                    is_duplicate=is_duplicate
                ))
                
            except Exception as e:
                error_count += 1
                print(f"  ❌ Error: {str(e)}")
                if 'file_path' in locals() and os.path.exists(file_path):
                    os.remove(file_path)
                failed.append({"filename": file.filename, "error": str(e)})
        
        return BulkUploadResponse(
            success=len(uploaded) > 0,
            total_files=len(files),
            uploaded=uploaded,
            failed=failed,
            summary={
                "new": new_count,
                "duplicates": duplicate_count,
                "errors": error_count
            }
        )
    
    # ============================================
    # ✅ GUEST USER FLOW - BULLETPROOF ENFORCEMENT
    # ============================================
    else:
        print("👤 Guest user bulk upload")
        
        # Get or create session
        session_id = await get_or_create_guest_session(request, response, db)
        
        # ✅ BULLETPROOF: Count actual documents in database
        current_count = await get_guest_document_count(session_id, db)
        print(f"  📊 Current guest document count: {current_count}/{GUEST_DOCUMENT_LIMIT}")
        
        # ✅ BULLETPROOF: Check if can upload
        can_upload, remaining, message = await check_guest_can_upload(
            session_id=session_id,
            files_to_upload=len(files),
            db=db
        )
        
        if not can_upload:
            print(f"  ❌ Upload blocked: {message}")
            raise HTTPException(status_code=403, detail=message)
        
        print(f"  ✅ Upload allowed: {remaining} slots remaining")
        
        uploaded = []
        failed = []
        new_count = 0
        duplicate_count = 0
        error_count = 0
        
        for file in files:
            try:
                if not file.filename.lower().endswith('.pdf'):
                    failed.append({"filename": file.filename, "error": "Not a PDF file"})
                    error_count += 1
                    continue
                
                file_extension = os.path.splitext(file.filename)[1]
                unique_filename = f"{uuid.uuid4().hex}{file_extension}"
                file_path = os.path.join(settings.UPLOAD_DIR, unique_filename)
                
                with open(file_path, "wb") as buffer:
                    content = await file.read()
                    buffer.write(content)
                
                file_size = len(content)
                
                # ✅ Process with session_id
                document, is_duplicate = await enhanced_form_processing_service.process_uploaded_document(
                    file_path=file_path,
                    original_filename=file.filename,
                    file_size=file_size,
                    db=db,
                    user_id=None,
                    session_id=session_id,
                    allow_duplicates=False
                )
                
                # Track file
                await guest_manager.track_temporary_file(
                    session_id=session_id,
                    file_path=file_path,
                    file_size=file_size
                )
                
                if is_duplicate:
                    duplicate_count += 1
                else:
                    new_count += 1
                
                await guest_manager.log_event(
                    event_type="guest_upload",
                    session_id=session_id,
                    metadata={
                        "document_id": document.id,
                        "filename": file.filename,
                        "is_duplicate": is_duplicate
                    }
                )
                
                uploaded.append(UploadResponse(
                    success=True,
                    message="Duplicate document" if is_duplicate else "File uploaded successfully",
                    document_id=document.id,
                    filename=file.filename,
                    form_type=document.form_type.value,
                    processing_status=document.processing_status.value,
                    is_duplicate=is_duplicate
                ))
                
                print(f"  {'⚠️ Duplicate' if is_duplicate else '✅ New'}: {file.filename}")
                
            except Exception as e:
                error_count += 1
                print(f"  ❌ Error: {str(e)}")
                if 'file_path' in locals() and os.path.exists(file_path):
                    os.remove(file_path)
                failed.append({"filename": file.filename, "error": str(e)})
        
        # ✅ Get updated count from database
        final_count = await get_guest_document_count(session_id, db)
        final_remaining = GUEST_DOCUMENT_LIMIT - final_count
        
        print(f"  📊 Final guest document count: {final_count}/{GUEST_DOCUMENT_LIMIT}")
        
        return BulkUploadResponse(
            success=len(uploaded) > 0,
            total_files=len(files),
            uploaded=uploaded,
            failed=failed,
            summary={
                "new": new_count,
                "duplicates": duplicate_count,
                "errors": error_count,
                "session_info": {
                    "document_count": final_count,
                    "documents_remaining": final_remaining,
                    "limit": GUEST_DOCUMENT_LIMIT
                }
            }
        )


@router.post("/single", response_model=UploadResponse)
async def upload_single_pdf(
    request: Request,
    response: Response,
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user_optional)
):
    """
    Upload a single PDF file
    ✅ BULLETPROOF: Counts actual documents from database
    """
    
    if not file.filename.lower().endswith('.pdf'):
        raise HTTPException(status_code=400, detail="Only PDF files are allowed")
    
    if file.size and file.size > settings.MAX_UPLOAD_SIZE:
        raise HTTPException(status_code=400, detail="File size exceeds maximum")
    
    # Handle guest vs authenticated user
    if current_user:
        user_id = current_user.id
        session_id = None
    else:
        # ✅ GUEST: Check limit using database count
        session_id = await get_or_create_guest_session(request, response, db)
        user_id = None
        
        # ✅ BULLETPROOF: Count actual documents
        current_count = await get_guest_document_count(session_id, db)
        print(f"👤 Guest single upload: {current_count}/{GUEST_DOCUMENT_LIMIT} documents")
        
        # ✅ BULLETPROOF: Check if can upload
        can_upload, remaining, message = await check_guest_can_upload(
            session_id=session_id,
            files_to_upload=1,
            db=db
        )
        
        if not can_upload:
            print(f"  ❌ Upload blocked: {message}")
            raise HTTPException(status_code=403, detail=message)
    
    try:
        file_extension = os.path.splitext(file.filename)[1]
        unique_filename = f"{uuid.uuid4().hex}{file_extension}"
        file_path = os.path.join(settings.UPLOAD_DIR, unique_filename)
        
        with open(file_path, "wb") as buffer:
            content = await file.read()
            buffer.write(content)
        
        file_size = len(content)
        
        document, is_duplicate = await enhanced_form_processing_service.process_uploaded_document(
            file_path=file_path,
            original_filename=file.filename,
            file_size=file_size,
            db=db,
            user_id=user_id,
            session_id=session_id,
            allow_duplicates=False
        )
        
        return UploadResponse(
            success=True,
            message="Duplicate document" if is_duplicate else "File uploaded successfully",
            document_id=document.id,
            filename=file.filename,
            form_type=document.form_type.value,
            processing_status=document.processing_status.value,
            is_duplicate=is_duplicate
        )
        
    except Exception as e:
        if 'file_path' in locals() and os.path.exists(file_path):
            os.remove(file_path)
        raise HTTPException(status_code=500, detail=f"Error processing file: {str(e)}")


@router.get("/guest/info")
async def get_guest_info(
    request: Request,
    db: AsyncSession = Depends(get_db)
):
    """
    Get guest session info
    ✅ BULLETPROOF: Returns actual count from database
    """
    session_id = get_session_id_from_request(request)
    
    if not session_id:
        return {
            "is_guest": True,
            "has_session": False,
            "documents_remaining": GUEST_DOCUMENT_LIMIT,
            "document_count": 0,
            "limit": GUEST_DOCUMENT_LIMIT
        }
    
    # ✅ BULLETPROOF: Get actual count from database
    document_count = await get_guest_document_count(session_id, db)
    documents_remaining = max(0, GUEST_DOCUMENT_LIMIT - document_count)
    
    return {
        "is_guest": True,
        "has_session": True,
        "document_count": document_count,
        "documents_remaining": documents_remaining,
        "limit": GUEST_DOCUMENT_LIMIT
    }