"""
Simple Database Migration: Add google_id to users table
Compatible with your database setup
"""

import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import asyncio
from sqlalchemy import text
from app.core.database import engine


async def upgrade():
    """Add google_id column to users table"""
    print("🔄 Running migration: Add google_id to users table")
    
    async with engine.begin() as conn:
        # Check if column already exists
        result = await conn.execute(text("""
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_name='users' AND column_name='google_id';
        """))
        
        exists = result.fetchone() is not None
        
        if exists:
            print("  ⏭️  Column 'google_id' already exists, skipping...")
            return
        
        # Add google_id column
        await conn.execute(text("""
            ALTER TABLE users 
            ADD COLUMN google_id VARCHAR(255);
        """))
        
        print("  ✅ Column 'google_id' added successfully")
        
        # Add unique constraint
        try:
            await conn.execute(text("""
                ALTER TABLE users 
                ADD CONSTRAINT users_google_id_unique UNIQUE (google_id);
            """))
            print("  ✅ Unique constraint added")
        except Exception as e:
            print(f"  ⚠️  Unique constraint may already exist: {str(e)}")
        
        # Create index for performance
        try:
            await conn.execute(text("""
                CREATE INDEX ix_users_google_id 
                ON users (google_id);
            """))
            print("  ✅ Index 'ix_users_google_id' created successfully")
        except Exception as e:
            print(f"  ⚠️  Index may already exist: {str(e)}")


async def downgrade():
    """Remove google_id column from users table"""
    print("🔄 Running migration rollback: Remove google_id from users table")
    
    async with engine.begin() as conn:
        # Drop index first
        await conn.execute(text("""
            DROP INDEX IF EXISTS ix_users_google_id;
        """))
        
        print("  ✅ Index 'ix_users_google_id' dropped")
        
        # Drop unique constraint
        await conn.execute(text("""
            ALTER TABLE users 
            DROP CONSTRAINT IF EXISTS users_google_id_unique;
        """))
        
        print("  ✅ Unique constraint dropped")
        
        # Drop column
        await conn.execute(text("""
            ALTER TABLE users 
            DROP COLUMN IF EXISTS google_id;
        """))
        
        print("  ✅ Column 'google_id' removed")


async def verify():
    """Verify the migration was applied correctly"""
    print("🔍 Verifying migration...")
    
    async with engine.begin() as conn:
        # Check if column exists
        result = await conn.execute(text("""
            SELECT column_name, data_type, is_nullable
            FROM information_schema.columns 
            WHERE table_name='users' AND column_name='google_id';
        """))
        
        row = result.fetchone()
        
        if row:
            print(f"  ✅ Column 'google_id' exists:")
            print(f"     - Type: {row[1]}")
            print(f"     - Nullable: {row[2]}")
            
            # Check unique constraint
            result = await conn.execute(text("""
                SELECT constraint_name 
                FROM information_schema.table_constraints 
                WHERE table_name='users' 
                AND constraint_type='UNIQUE'
                AND constraint_name='users_google_id_unique';
            """))
            
            if result.fetchone():
                print("  ✅ Unique constraint exists")
            else:
                print("  ⚠️  Unique constraint not found")
            
            # Check index
            result = await conn.execute(text("""
                SELECT indexname 
                FROM pg_indexes 
                WHERE tablename='users' AND indexname='ix_users_google_id';
            """))
            
            if result.fetchone():
                print("  ✅ Index 'ix_users_google_id' exists")
            else:
                print("  ⚠️  Index 'ix_users_google_id' not found")
        else:
            print("  ❌ Column 'google_id' not found")


async def main():
    """Main entry point"""
    if len(sys.argv) < 2:
        print("Usage: python migration_add_google_id.py [upgrade|downgrade|verify]")
        sys.exit(1)
    
    command = sys.argv[1]
    
    try:
        if command == "upgrade":
            await upgrade()
            await verify()
        elif command == "downgrade":
            await downgrade()
        elif command == "verify":
            await verify()
        else:
            print(f"Unknown command: {command}")
            print("Usage: python migration_add_google_id.py [upgrade|downgrade|verify]")
            sys.exit(1)
        
        print("\n✅ Migration completed successfully!")
        
    except Exception as e:
        print(f"\n❌ Error: {str(e)}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    asyncio.run(main())
