"""
Add password reset fields to users table
Run: python backend/add_reset_fields.py
"""

import asyncio
from sqlalchemy import text
from app.core.database import engine


async def add_reset_fields():
    """Add password reset fields to users table"""
    print("Adding password reset fields to users table...")
    
    async with engine.begin() as conn:
        # Check if columns exist
        result = await conn.execute(text("""
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_name='users' AND column_name IN ('reset_token', 'reset_token_expires')
        """))
        existing_columns = [row[0] for row in result]
        
        if 'reset_token' not in existing_columns:
            await conn.execute(text("""
                ALTER TABLE users ADD COLUMN reset_token VARCHAR(500)
            """))
            print("✅ Added reset_token column")
        else:
            print("⏭️  reset_token column already exists")
        
        if 'reset_token_expires' not in existing_columns:
            await conn.execute(text("""
                ALTER TABLE users ADD COLUMN reset_token_expires TIMESTAMP WITH TIME ZONE
            """))
            print("✅ Added reset_token_expires column")
        else:
            print("⏭️  reset_token_expires column already exists")
    
    print("✅ Migration completed!")


if __name__ == "__main__":
    asyncio.run(add_reset_fields())