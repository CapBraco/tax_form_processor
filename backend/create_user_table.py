"""
Create users table
Run: python backend/create_user_table.py
"""

import asyncio
from sqlalchemy import text
from app.core.database import engine, Base
from app.models.base import User
from app.core.security import get_password_hash


async def setup_database():
    """Create users table and admin user"""
    
    # Step 1: Create tables
    print("Creating users table...")
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all, tables=[User.__table__])
    print("✅ Users table created successfully!")
    
    # Step 2: Create admin user
    print("\nCreating admin user...")
    from app.core.database import AsyncSessionLocal
    
    async with AsyncSessionLocal() as db:
        try:
            # Check if admin exists
            result = await db.execute(text("SELECT * FROM users WHERE username = 'admin'"))
            existing = result.first()
            
            if existing:
                print("⏭️  Admin user already exists")
                return
            
            # Create admin user
            admin = User(
                username="admin",
                email="admin@example.com",
                hashed_password=get_password_hash("admin123"),  # Change this!
                is_active=True,
                is_superuser=True
            )
            
            db.add(admin)
            await db.commit()
            
            print("✅ Admin user created successfully!")
            print("\n" + "="*50)
            print("📋 Login Credentials:")
            print("   Username: admin")
            print("   Password: admin123")
            print("="*50)
            print("\n⚠️  IMPORTANT: Change this password immediately!")
            print("   Go to: http://localhost:3000/login")
            
        except Exception as e:
            print(f"❌ Error creating admin user: {e}")
            await db.rollback()
            raise


if __name__ == "__main__":
    # Run everything in a single event loop
    asyncio.run(setup_database())
    print("\n✅ Database setup completed!")