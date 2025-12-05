"""
Reset Admin Password Script
Run this to reset the admin password to "admin123"
"""

import asyncio
import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.core.database import AsyncSessionLocal
from app.core.security import get_password_hash
from app.models.base import User
from sqlalchemy import select


async def reset_admin_password():
    """Reset admin password to default"""
    print("🔧 Resetting admin password...")
    
    async with AsyncSessionLocal() as session:
        try:
            # Get admin user
            result = await session.execute(
                select(User).where(User.username == "admin")
            )
            admin = result.scalar_one_or_none()
            
            if not admin:
                print("❌ Admin user not found!")
                print("💡 Run create_user_table.py first to create the admin user")
                return False
            
            # Set new password
            new_password = "admin123"
            print(f"📝 Setting password to: {new_password}")
            
            admin.hashed_password = get_password_hash(new_password)
            
            await session.commit()
            
            print(f"✅ Admin password reset successfully!")
            print(f"✅ Username: admin")
            print(f"✅ Password: {new_password}")
            print(f"✅ Hash preview: {admin.hashed_password[:40]}...")
            
            return True
            
        except Exception as e:
            print(f"❌ Error resetting password: {e}")
            await session.rollback()
            return False


async def reset_all_passwords():
    """Reset ALL user passwords (useful for testing)"""
    print("🔧 Resetting all user passwords...")
    
    async with AsyncSessionLocal() as session:
        try:
            # Get all users
            result = await session.execute(select(User))
            users = result.scalars().all()
            
            if not users:
                print("❌ No users found!")
                return False
            
            print(f"📋 Found {len(users)} users")
            
            # Default password for all users
            default_password = "admin123"
            
            for user in users:
                user.hashed_password = get_password_hash(default_password)
                print(f"  ✅ Reset password for: {user.username}")
            
            await session.commit()
            
            print(f"\n✅ All passwords reset to: {default_password}")
            return True
            
        except Exception as e:
            print(f"❌ Error resetting passwords: {e}")
            await session.rollback()
            return False


async def main():
    """Main function"""
    import argparse
    
    parser = argparse.ArgumentParser(description='Reset user passwords')
    parser.add_argument('--all', action='store_true', help='Reset all user passwords')
    args = parser.parse_args()
    
    if args.all:
        success = await reset_all_passwords()
    else:
        success = await reset_admin_password()
    
    if success:
        print("\n🎉 Done! You can now login with the new password.")
    else:
        print("\n❌ Password reset failed!")
        sys.exit(1)


if __name__ == "__main__":
    asyncio.run(main())
