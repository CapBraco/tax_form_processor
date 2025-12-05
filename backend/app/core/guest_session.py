"""
Guest Session Manager
Handles guest user sessions, document limits, and temporary file tracking
"""

import uuid
from datetime import datetime, timedelta
from typing import Optional, Dict, Any
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from app.models.base import GuestSession, TemporaryFile, UsageAnalytics

# Configuration
GUEST_DOCUMENT_LIMIT = 5
GUEST_SESSION_EXPIRY_HOURS = 24
TEMP_FILE_EXPIRY_HOURS = 24


class GuestSessionManager:
    """Manages guest user sessions and document upload limits"""
    
    def __init__(self, db: AsyncSession):
        self.db = db
    
    async def get_or_create_session(
        self, 
        session_id: Optional[str] = None,
        ip_address: Optional[str] = None,
        user_agent: Optional[str] = None
    ) -> GuestSession:
        """
        Get existing guest session or create new one
        
        Args:
            session_id: Existing session ID (from cookie/header)
            ip_address: Client IP address
            user_agent: Client user agent string
            
        Returns:
            GuestSession object
        """
        # If session_id provided, try to find existing session
        if session_id:
            result = await self.db.execute(
                select(GuestSession).where(GuestSession.session_id == session_id)
            )
            existing_session = result.scalar_one_or_none()
            
            if existing_session:
                # Update last activity
                existing_session.last_activity = datetime.utcnow()
                await self.db.commit()
                await self.db.refresh(existing_session)
                return existing_session
        
        # Create new session
        new_session_id = str(uuid.uuid4())
        new_session = GuestSession(
            session_id=new_session_id,
            document_count=0,
            ip_address=ip_address,
            user_agent=user_agent
        )
        
        self.db.add(new_session)
        await self.db.commit()
        await self.db.refresh(new_session)
        
        return new_session
    
    async def can_upload(self, session_id: str) -> tuple[bool, int, str]:
        """
        Check if guest can upload more documents
        
        Args:
            session_id: Guest session ID
            
        Returns:
            Tuple of (can_upload: bool, remaining: int, message: str)
        """
        result = await self.db.execute(
            select(GuestSession).where(GuestSession.session_id == session_id)
        )
        session = result.scalar_one_or_none()
        
        if not session:
            return False, 0, "Invalid session"
        
        remaining = GUEST_DOCUMENT_LIMIT - session.document_count
        
        if session.document_count >= GUEST_DOCUMENT_LIMIT:
            return False, 0, f"Guest upload limit reached ({GUEST_DOCUMENT_LIMIT} documents). Please register for unlimited uploads."
        
        return True, remaining, f"{remaining} uploads remaining"
    
    async def increment_document_count(self, session_id: str) -> int:
        """
        Increment document count for guest session
        
        Args:
            session_id: Guest session ID
            
        Returns:
            New document count
        """
        result = await self.db.execute(
            select(GuestSession).where(GuestSession.session_id == session_id)
        )
        session = result.scalar_one_or_none()
        
        if session:
            session.document_count += 1
            session.last_activity = datetime.utcnow()
            await self.db.commit()
            await self.db.refresh(session)
            return session.document_count
        
        return 0
    
    async def track_temporary_file(
        self,
        session_id: str,
        file_path: str,
        file_size: int
    ) -> TemporaryFile:
        """
        Track a temporary file for guest session
        
        Args:
            session_id: Guest session ID
            file_path: Path to temporary file
            file_size: Size of file in bytes
            
        Returns:
            TemporaryFile object
        """
        expires_at = datetime.utcnow() + timedelta(hours=TEMP_FILE_EXPIRY_HOURS)
        
        temp_file = TemporaryFile(
            session_id=session_id,
            file_path=file_path,
            file_size=file_size,
            expires_at=expires_at
        )
        
        self.db.add(temp_file)
        await self.db.commit()
        await self.db.refresh(temp_file)
        
        return temp_file
    
    async def get_session_info(self, session_id: str) -> Optional[Dict[str, Any]]:
        """
        Get information about a guest session
        
        Args:
            session_id: Guest session ID
            
        Returns:
            Dictionary with session info or None
        """
        result = await self.db.execute(
            select(GuestSession).where(GuestSession.session_id == session_id)
        )
        session = result.scalar_one_or_none()
        
        if not session:
            return None
        
        remaining = GUEST_DOCUMENT_LIMIT - session.document_count
        
        return {
            "session_id": session.session_id,
            "document_count": session.document_count,
            "documents_remaining": remaining,
            "limit": GUEST_DOCUMENT_LIMIT,
            "created_at": session.created_at.isoformat(),
            "last_activity": session.last_activity.isoformat()
        }
    
    async def log_event(
        self,
        event_type: str,
        session_id: Optional[str] = None,
        user_id: Optional[int] = None,
        metadata: Optional[Dict[str, Any]] = None
    ):
        """
        Log an analytics event
        
        Args:
            event_type: Type of event (e.g., 'guest_upload', 'registration')
            session_id: Guest session ID (if applicable)
            user_id: User ID (if applicable)
            metadata: Additional event data
        """
        event = UsageAnalytics(
            event_type=event_type,
            user_id=user_id,
            session_id=session_id,
            event_data=metadata
        )
        
        self.db.add(event)
        await self.db.commit()


async def generate_guest_session_id() -> str:
    """Generate a new unique session ID for guests"""
    return str(uuid.uuid4())


async def cleanup_expired_sessions(db: AsyncSession) -> int:
    """
    Clean up expired guest sessions (older than 7 days)
    
    Args:
        db: Database session
        
    Returns:
        Number of sessions deleted
    """
    expiry_date = datetime.utcnow() - timedelta(days=7)
    
    # Get expired sessions
    result = await db.execute(
        select(GuestSession).where(GuestSession.last_activity < expiry_date)
    )
    expired_sessions = result.scalars().all()
    
    count = len(expired_sessions)
    
    # Delete them (cascade will handle temporary_files)
    for session in expired_sessions:
        await db.delete(session)
    
    await db.commit()
    
    return count


async def cleanup_expired_files(db: AsyncSession) -> int:
    """
    Clean up expired temporary files
    
    Args:
        db: Database session
        
    Returns:
        Number of files deleted
    """
    import os
    
    now = datetime.utcnow()
    
    # Get expired files
    result = await db.execute(
        select(TemporaryFile).where(TemporaryFile.expires_at < now)
    )
    expired_files = result.scalars().all()
    
    count = 0
    
    for temp_file in expired_files:
        # Delete physical file if it exists
        try:
            if os.path.exists(temp_file.file_path):
                os.remove(temp_file.file_path)
                count += 1
        except Exception as e:
            print(f"Error deleting file {temp_file.file_path}: {e}")
        
        # Delete database record
        await db.delete(temp_file)
    
    await db.commit()
    
    return count
