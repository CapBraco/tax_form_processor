import httpx
from app.core.config import settings

class RecaptchaService:
    def __init__(self):
        self.secret_key = settings.RECAPTCHA_SECRET_KEY
        self.verify_url = "https://www.google.com/recaptcha/api/siteverify"
    
    async def verify_token(self, token: str, action: str = "register") -> bool:
        """Verify reCAPTCHA token"""
        if not self.secret_key:
            print("⚠️ reCAPTCHA not configured, skipping verification")
            return True
        
        async with httpx.AsyncClient() as client:
            response = await client.post(
                self.verify_url,
                data={
                    "secret": self.secret_key,
                    "response": token
                }
            )
            
            if response.status_code != 200:
                return False
            
            result = response.json()
            
            # Check if verification was successful
            if not result.get("success"):
                print(f"❌ reCAPTCHA verification failed: {result.get('error-codes')}")
                return False
            
            # Check score (v3 returns score 0.0 - 1.0)
            score = result.get("score", 0)
            if score < 0.5:  # Threshold for bot detection
                print(f"⚠️ Low reCAPTCHA score: {score}")
                return False
            
            # Verify action matches
            if result.get("action") != action:
                print(f"❌ Action mismatch: expected {action}, got {result.get('action')}")
                return False
            
            return True

recaptcha_service = RecaptchaService()