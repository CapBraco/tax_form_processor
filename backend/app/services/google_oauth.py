from google.oauth2 import id_token
from google.auth.transport import requests
import httpx
from app.core.config import settings

class GoogleOAuthService:
    def __init__(self):
        self.client_id = settings.GOOGLE_CLIENT_ID
        self.client_secret = settings.GOOGLE_CLIENT_SECRET
        self.redirect_uri = settings.GOOGLE_REDIRECT_URI
    
    def get_authorization_url(self):
        """Generate Google OAuth authorization URL"""
        base_url = "https://accounts.google.com/o/oauth2/v2/auth"
        params = {
            "client_id": self.client_id,
            "redirect_uri": self.redirect_uri,
            "response_type": "code",
            "scope": "openid email profile",
            "access_type": "offline",
            "prompt": "consent"
        }
        
        from urllib.parse import urlencode
        return f"{base_url}?{urlencode(params)}"
    
    async def get_user_info(self, code: str):
        """Exchange authorization code for user info"""
        token_url = "https://oauth2.googleapis.com/token"
        
        async with httpx.AsyncClient() as client:
            # Exchange code for tokens
            token_response = await client.post(
                token_url,
                data={
                    "code": code,
                    "client_id": self.client_id,
                    "client_secret": self.client_secret,
                    "redirect_uri": self.redirect_uri,
                    "grant_type": "authorization_code"
                }
            )
            
            if token_response.status_code != 200:
                raise Exception("Failed to exchange code for token")
            
            tokens = token_response.json()
            id_token_jwt = tokens.get("id_token")
            
            # Verify and decode ID token
            try:
                user_info = id_token.verify_oauth2_token(
                    id_token_jwt,
                    requests.Request(),
                    self.client_id
                )
                return user_info
            except Exception as e:
                raise Exception(f"Failed to verify token: {str(e)}")

google_oauth_service = GoogleOAuthService()