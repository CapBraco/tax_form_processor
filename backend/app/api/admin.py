"""
Admin API Endpoints
Protected admin-only routes for user management
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, desc
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

from app.core.database import get_db
from app.core.security import get_current_user, get_password_hash
from app.models.base import User, Document

router = APIRouter(prefix="/admin", tags=["admin"])


class UserListItem(BaseModel):
    id: int
    username: str
    email: str
    is_active: bool
    is_superuser: bool
    created_at: str
    last_login: Optional[str]


class UserUpdate(BaseModel):
    is_active: Optional[bool] = None
    is_superuser: Optional[bool] = None


class AdminStats(BaseModel):
    total_users: int
    active_users: int
    superusers: int
    total_documents: int
    total_clients: int


async def require_admin(current_user: User = Depends(get_current_user)):
    """Dependency to require admin privileges"""
    if not current_user.is_superuser:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Admin privileges required"
        )
    return current_user


@router.get("/stats", response_model=AdminStats)
async def get_admin_stats(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_admin)
):
    """Get admin dashboard statistics"""
    # Total users
    total_users = await db.execute(select(func.count(User.id)))
    total_users = total_users.scalar()
    
    # Active users
    active_users = await db.execute(
        select(func.count(User.id)).where(User.is_active == True)
    )
    active_users = active_users.scalar()
    
    # Superusers
    superusers = await db.execute(
        select(func.count(User.id)).where(User.is_superuser == True)
    )
    superusers = superusers.scalar()
    
    # Total documents
    total_docs = await db.execute(select(func.count(Document.id)))
    total_docs = total_docs.scalar()
    
    # Total clients
    total_clients = await db.execute(
        select(func.count(func.distinct(Document.razon_social)))
        .where(Document.razon_social.isnot(None))
    )
    total_clients = total_clients.scalar()
    
    return AdminStats(
        total_users=total_users,
        active_users=active_users,
        superusers=superusers,
        total_documents=total_docs,
        total_clients=total_clients
    )


@router.get("/users", response_model=List[UserListItem])
async def list_all_users(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_admin)
):
    """List all users (admin only)"""
    result = await db.execute(
        select(User).order_by(desc(User.created_at))
    )
    users = result.scalars().all()
    
    return [
        UserListItem(
            id=user.id,
            username=user.username,
            email=user.email,
            is_active=user.is_active,
            is_superuser=user.is_superuser,
            created_at=user.created_at.isoformat(),
            last_login=user.last_login.isoformat() if user.last_login else None
        )
        for user in users
    ]


@router.patch("/users/{user_id}")
async def update_user(
    user_id: int,
    user_update: UserUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_admin)
):
    """Update user (admin only)"""
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Don't allow disabling yourself
    if user.id == current_user.id and user_update.is_active is False:
        raise HTTPException(
            status_code=400,
            detail="Cannot deactivate your own account"
        )
    
    if user_update.is_active is not None:
        user.is_active = user_update.is_active
    
    if user_update.is_superuser is not None:
        user.is_superuser = user_update.is_superuser
    
    await db.commit()
    await db.refresh(user)
    
    return {
        "success": True,
        "message": "User updated successfully"
    }


@router.delete("/users/{user_id}")
async def delete_user(
    user_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(require_admin)
):
    """Delete user (admin only)"""
    if user_id == current_user.id:
        raise HTTPException(
            status_code=400,
            detail="Cannot delete your own account"
        )
    
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    await db.delete(user)
    await db.commit()
    
    return {
        "success": True,
        "message": "User deleted successfully"
    }