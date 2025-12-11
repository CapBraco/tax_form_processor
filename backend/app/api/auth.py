"""
Authentication API Endpoints
Handles login, logout, registration, password management, Google OAuth, and reCAPTCHA
"""

from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException, status, Response, Request
from fastapi.responses import RedirectResponse
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from pydantic import BaseModel, EmailStr, field_validator
from typing import Optional
import httpx

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
    recaptcha_token: Optional[str] = None  # ✅ Added reCAPTCHA token
    
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


# ============================================
# ✅ RECAPTCHA VERIFICATION
# ============================================
async def verify_recaptcha(token: str, action: str = "register") -> bool:
    """Verify reCAPTCHA v3 token"""
    if not settings.RECAPTCHA_SECRET_KEY:
        print("⚠️ reCAPTCHA not configured, skipping verification")
        return True
    
    verify_url = "https://www.google.com/recaptcha/api/siteverify"
    
    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(
                verify_url,
                data={
                    "secret": settings.RECAPTCHA_SECRET_KEY,
                    "response": token
                }
            )
            
            if response.status_code != 200:
                print(f"❌ reCAPTCHA API error: {response.status_code}")
                return False
            
            result = response.json()
            
            # Check if verification was successful
            if not result.get("success"):
                print(f"❌ reCAPTCHA verification failed: {result.get('error-codes')}")
                return False
            
            # Check score (v3 returns score 0.0 - 1.0)
            score = result.get("score", 0)
            if score < settings.RECAPTCHA_SCORE_THRESHOLD:
                print(f"⚠️ Low reCAPTCHA score: {score} (threshold: {settings.RECAPTCHA_SCORE_THRESHOLD})")
                return False
            
            # Verify action matches
            if result.get("action") != action:
                print(f"❌ Action mismatch: expected {action}, got {result.get('action')}")
                return False
            
            print(f"✅ reCAPTCHA verified successfully (score: {score})")
            return True
            
    except Exception as e:
        print(f"❌ reCAPTCHA verification error: {str(e)}")
        return False


# ============================================
# ✅ GOOGLE OAUTH HELPERS
# ============================================
def get_google_auth_url() -> str:
    """Generate Google OAuth authorization URL"""
    from urllib.parse import urlencode
    
    base_url = "https://accounts.google.com/o/oauth2/v2/auth"
    params = {
        "client_id": settings.GOOGLE_CLIENT_ID,
        "redirect_uri": settings.GOOGLE_REDIRECT_URI,
        "response_type": "code",
        "scope": "openid email profile",
        "access_type": "offline",
        "prompt": "consent"
    }
    
    return f"{base_url}?{urlencode(params)}"


async def get_google_user_info(code: str) -> dict:
    """Exchange authorization code for user info"""
    token_url = "https://oauth2.googleapis.com/token"
    
    async with httpx.AsyncClient() as client:
        # Exchange code for tokens
        token_response = await client.post(
            token_url,
            data={
                "code": code,
                "client_id": settings.GOOGLE_CLIENT_ID,
                "client_secret": settings.GOOGLE_CLIENT_SECRET,
                "redirect_uri": settings.GOOGLE_REDIRECT_URI,
                "grant_type": "authorization_code"
            }
        )
        
        if token_response.status_code != 200:
            raise Exception(f"Failed to exchange code for token: {token_response.text}")
        
        tokens = token_response.json()
        access_token = tokens.get("access_token")
        
        # Get user info
        userinfo_response = await client.get(
            "https://www.googleapis.com/oauth2/v2/userinfo",
            headers={"Authorization": f"Bearer {access_token}"}
        )
        
        if userinfo_response.status_code != 200:
            raise Exception("Failed to get user info")
        
        return userinfo_response.json()


# ============================================
# AUTHENTICATION ENDPOINTS
# ============================================

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
    """Register a new user with reCAPTCHA verification"""
    try:
        # ✅ Verify reCAPTCHA
        if user_data.recaptcha_token:
            is_valid = await verify_recaptcha(user_data.recaptcha_token, "register")
            if not is_valid:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Verificación de reCAPTCHA fallida. Por favor intenta de nuevo."
                )
        elif settings.RECAPTCHA_SECRET_KEY:
            # If reCAPTCHA is configured but no token provided
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="reCAPTCHA token requerido"
            )
        
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


# ============================================
# ✅ GOOGLE OAUTH ENDPOINTS
# ============================================

@router.get("/google/login")
async def google_login():
    """Redirect to Google OAuth consent screen"""
    if not settings.GOOGLE_CLIENT_ID:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Google OAuth not configured"
        )
    
    auth_url = get_google_auth_url()
    return RedirectResponse(url=auth_url)


@router.get("/google/callback")
async def google_callback(
    code: str,
    response: Response,
    db: AsyncSession = Depends(get_db)
):
    """Handle Google OAuth callback"""
    try:
        # Get user info from Google
        user_info = await get_google_user_info(code)
        
        email = user_info.get("email")
        google_id = user_info.get("id")
        name = user_info.get("name", "")
        
        if not email:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Could not get email from Google"
            )
        
        # Check if user exists
        result = await db.execute(
            select(User).where(User.email == email)
        )
        user = result.scalar_one_or_none()
        
        if not user:
            # Create new user from Google account
            # Generate username from email
            username = email.split("@")[0]
            
            # Check if username exists and add number if needed
            existing = await db.execute(
                select(User).where(User.username.like(f"{username}%"))
            )
            count = len(existing.scalars().all())
            if count > 0:
                username = f"{username}{count + 1}"
            
            user = User(
                username=username,
                email=email,
                google_id=google_id,
                hashed_password="",  # No password for OAuth users
                is_active=True,
                is_superuser=False,
                created_at=datetime.utcnow()
            )
            db.add(user)
            await db.commit()
            await db.refresh(user)
            
            print(f"✅ New user created via Google OAuth: {username}")
        else:
            # Update google_id if not set
            if not user.google_id:
                user.google_id = google_id
                await db.commit()
        
        # Update last login
        user.last_login = datetime.utcnow()
        await db.commit()
        
        # Create JWT token
        access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
        access_token = create_access_token(
            data={"sub": user.username}, expires_delta=access_token_expires
        )
        
        # Set cookie
        response = RedirectResponse(url=settings.FRONTEND_URL)
        response.set_cookie(
            key=settings.SESSION_COOKIE_NAME,
            value=access_token,
            httponly=True,
            max_age=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
            samesite="lax",
            secure=False
        )
        
        return response
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ Google OAuth error: {str(e)}")
        # Redirect to login with error
        return RedirectResponse(url=f"{settings.FRONTEND_URL}/login?error=oauth_failed")


# ============================================
# PASSWORD MANAGEMENT ENDPOINTS
# ============================================

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
    
    reset_link = f"{settings.FRONTEND_URL}/reset-password?token={reset_token}"
    
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


# ============================================
# USER INFO ENDPOINTS
# ============================================

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


# ============================================
# EMAIL HELPER (Production only)
# ============================================

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