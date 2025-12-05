"""
Authentication API Endpoints
Handles login, logout, registration, and password management
"""

from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException, status, Response, Request
from sqlalchemy.ext.asyncio import AsyncSession
from pydantic import BaseModel, EmailStr, field_validator
from typing import Optional

from app.core.database import get_db
from app.core.config import settings
from app.core.security import (
    authenticate_user,
    create_access_token,
    create_password_reset_token,
    verify_password_reset_token,
    get_current_user,
    get_password_hash,
    get_user_by_username,
    get_user_by_email,
    verify_password
)
from app.models.base import User
from app.core.guest_session import GuestSessionManager
from app.utils.session_utils import get_session_id_from_request


router = APIRouter(prefix="/auth", tags=["authentication"])


class UserLogin(BaseModel):
    username: str
    password: str


class UserCreate(BaseModel):
    username: str
    email: EmailStr
    password: str
    confirm_password: str
    
    @field_validator('username')
    @classmethod
    def username_valid(cls, v):
        if len(v) < 3:
            raise ValueError('Username must be at least 3 characters')
        if not v.replace('_', '').isalnum():
            raise ValueError('Username must contain only letters, numbers, and underscores')
        return v
    
    @field_validator('password')
    @classmethod
    def password_strong(cls, v):
        if len(v) < 8:
            raise ValueError('Password must be at least 8 characters')
        return v
    
    @field_validator('confirm_password')
    @classmethod
    def passwords_match(cls, v, info):
        if 'password' in info.data and v != info.data['password']:
            raise ValueError('Passwords do not match')
        return v


class PasswordResetRequest(BaseModel):
    email: EmailStr


class PasswordReset(BaseModel):
    token: str
    new_password: str
    confirm_password: str
    
    @field_validator('new_password')
    @classmethod
    def password_strong(cls, v):
        if len(v) < 8:
            raise ValueError('Password must be at least 8 characters')
        return v
    
    @field_validator('confirm_password')
    @classmethod
    def passwords_match(cls, v, info):
        if 'new_password' in info.data and v != info.data['new_password']:
            raise ValueError('Passwords do not match')
        return v


class PasswordChange(BaseModel):
    current_password: str
    new_password: str
    confirm_password: str
    
    @field_validator('new_password')
    @classmethod
    def password_strong(cls, v):
        if len(v) < 8:
            raise ValueError('Password must be at least 8 characters')
        return v
    
    @field_validator('confirm_password')
    @classmethod
    def passwords_match(cls, v, info):
        if 'new_password' in info.data and v != info.data['new_password']:
            raise ValueError('Passwords do not match')
        return v


class UserResponse(BaseModel):
    id: int
    username: str
    email: str
    is_active: bool
    is_superuser: bool
    created_at: str
    
    class Config:
        from_attributes = True


class LoginResponse(BaseModel):
    success: bool
    user: UserResponse
    message: str


@router.post("/login", response_model=LoginResponse)
async def login(
    request: Request,
    response: Response,
    user_data: UserLogin,
    db: AsyncSession = Depends(get_db)
):
    """Login endpoint - creates session cookie"""
    user = await authenticate_user(db, user_data.username, user_data.password)
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires
    )
    
    response.set_cookie(
        key=settings.SESSION_COOKIE_NAME,
        value=access_token,
        httponly=True,
        max_age=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
        samesite="lax",
        secure=False
    )
    
    user.last_login = datetime.utcnow()
    await db.commit()
    
    guest_manager = GuestSessionManager(db)
    session_id = get_session_id_from_request(request)
    
    await guest_manager.log_event(
        event_type="login",
        user_id=user.id,
        session_id=session_id,
        metadata={"username": user.username}
    )
    
    return LoginResponse(
        success=True,
        user=UserResponse(
            id=user.id,
            username=user.username,
            email=user.email,
            is_active=user.is_active,
            is_superuser=user.is_superuser,
            created_at=user.created_at.isoformat()
        ),
        message="Login successful"
    )


@router.post("/logout")
async def logout(
    response: Response,
    current_user: User = Depends(get_current_user)
):
    """Logout endpoint - clears session cookie"""
    response.delete_cookie(key=settings.SESSION_COOKIE_NAME)
    return {"success": True, "message": "Logged out successfully"}


@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def register(
    request: Request,
    user_data: UserCreate,
    db: AsyncSession = Depends(get_db)
):
    """Register a new user with analytics tracking"""
    try:
        existing_user = await get_user_by_username(db, user_data.username)
        if existing_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Username already registered"
            )
        
        existing_email = await get_user_by_email(db, user_data.email)
        if existing_email:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email already registered"
            )
        
        hashed_password = get_password_hash(user_data.password)
        new_user = User(
            username=user_data.username,
            email=user_data.email,
            hashed_password=hashed_password,
            is_active=True,
            is_superuser=False,
            created_at=datetime.utcnow()
        )
        
        db.add(new_user)
        await db.commit()
        await db.refresh(new_user)
        
        guest_manager = GuestSessionManager(db)
        session_id = get_session_id_from_request(request)
        
        if session_id:
            session_info = await guest_manager.get_session_info(session_id)
            converted_from_guest = session_info is not None
            
            await guest_manager.log_event(
                event_type="registration",
                session_id=session_id,
                user_id=new_user.id,
                metadata={
                    "converted_from_guest": converted_from_guest,
                    "guest_documents_uploaded": session_info.get("document_count", 0) if session_info else 0
                }
            )
        else:
            await guest_manager.log_event(
                event_type="registration",
                user_id=new_user.id,
                metadata={"converted_from_guest": False}
            )
        
        return UserResponse(
            id=new_user.id,
            username=new_user.username,
            email=new_user.email,
            is_active=new_user.is_active,
            is_superuser=new_user.is_superuser,
            created_at=new_user.created_at.isoformat()
        )
        
    except HTTPException:
        raise
    except Exception as e:
        await db.rollback()
        print(f"❌ Registration error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error creating user: {str(e)}"
        )


@router.post("/password-reset-request")
async def request_password_reset(
    request_data: PasswordResetRequest,
    db: AsyncSession = Depends(get_db)
):
    """Request a password reset"""
    user = await get_user_by_email(db, request_data.email)
    
    if not user:
        return {
            "success": True,
            "message": "If the email exists, a password reset link has been sent"
        }
    
    reset_token = create_password_reset_token(user.email)
    
    user.reset_token = reset_token
    user.reset_token_expires = datetime.utcnow() + timedelta(hours=1)
    await db.commit()
    
    if settings.PRODUCTION:
        return {
            "success": True,
            "message": "If the email exists, a password reset link has been sent"
        }
    
    reset_link = f"{settings.FRONTEND_URL if hasattr(settings, 'FRONTEND_URL') else 'http://localhost:3000'}/reset-password?token={reset_token}"
    
    return {
        "success": True,
        "message": "If the email exists, a password reset link has been sent",
        "dev_reset_link": reset_link,
        "dev_token": reset_token
    }


@router.post("/password-reset")
async def reset_password(
    reset_data: PasswordReset,
    db: AsyncSession = Depends(get_db)
):
    """Reset password using token"""
    email = verify_password_reset_token(reset_data.token)
    if not email:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid or expired reset token"
        )
    
    user = await get_user_by_email(db, email)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    if user.reset_token != reset_data.token:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid reset token"
        )
    
    if user.reset_token_expires and user.reset_token_expires < datetime.utcnow():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Reset token has expired"
        )
    
    user.hashed_password = get_password_hash(reset_data.new_password)
    user.reset_token = None
    user.reset_token_expires = None
    await db.commit()
    
    return {
        "success": True,
        "message": "Password has been reset successfully"
    }


@router.post("/change-password")
async def change_password(
    password_data: PasswordChange,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Change password for authenticated user"""
    if not verify_password(password_data.current_password, current_user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Current password is incorrect"
        )
    
    current_user.hashed_password = get_password_hash(password_data.new_password)
    await db.commit()
    
    return {
        "success": True,
        "message": "Password changed successfully"
    }


@router.get("/me", response_model=UserResponse)
async def get_current_user_info(current_user: User = Depends(get_current_user)):
    """Get current user information"""
    return UserResponse(
        id=current_user.id,
        username=current_user.username,
        email=current_user.email,
        is_active=current_user.is_active,
        is_superuser=current_user.is_superuser,
        created_at=current_user.created_at.isoformat()
    )


@router.get("/check")
async def check_auth(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Check if user is authenticated"""
    return {
        "authenticated": True,
        "user": {
            "id": current_user.id,
            "username": current_user.username,
            "email": current_user.email,
            "is_superuser": current_user.is_superuser
        }
    }


async def send_password_reset_email(email: str, reset_token: str):
    """Send password reset email (production only)"""
    if not settings.PRODUCTION:
        return
    
    try:
        import smtplib
        from email.mime.text import MIMEText
        from email.mime.multipart import MIMEMultipart
        
        reset_link = f"{settings.FRONTEND_URL}/reset-password?token={reset_token}"
        
        message = MIMEMultipart("alternative")
        message["Subject"] = "Restablecer Contraseña - Tax Forms Processor"
        message["From"] = settings.EMAIL_FROM
        message["To"] = email
        
        html = f"""
        <html>
          <body>
            <h2>Restablecer Contraseña</h2>
            <p>Has solicitado restablecer tu contraseña.</p>
            <p>Haz clic en el siguiente enlace para continuar:</p>
            <p><a href="{reset_link}">Restablecer Contraseña</a></p>
            <p>Este enlace expirará en 1 hora.</p>
            <p>Si no solicitaste este cambio, ignora este correo.</p>
          </body>
        </html>
        """
        
        part = MIMEText(html, "html")
        message.attach(part)
        
        with smtplib.SMTP(settings.SMTP_HOST, settings.SMTP_PORT) as server:
            server.starttls()
            server.login(settings.SMTP_USER, settings.SMTP_PASSWORD)
            server.sendmail(settings.EMAIL_FROM, email, message.as_string())
            
    except Exception as e:
        print(f"❌ Error sending email: {str(e)}")
        pass