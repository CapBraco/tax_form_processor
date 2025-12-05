"""
Phase 1.5 Migration: Fix Existing Tables That Weren't Updated
Renames metadata -> event_data and adds user_id to form_104_data
"""

import asyncio
import sys
from sqlalchemy import text
from app.core.database import engine

async def table_exists(conn, table_name: str) -> bool:
    """Check if a table exists in the database"""
    result = await conn.execute(text(f"""
        SELECT EXISTS (
            SELECT FROM information_schema.tables 
            WHERE table_name = '{table_name}'
        );
    """))
    return result.scalar()

async def column_exists(conn, table_name: str, column_name: str) -> bool:
    """Check if a column exists in a table"""
    result = await conn.execute(text(f"""
        SELECT EXISTS (
            SELECT FROM information_schema.columns 
            WHERE table_name = '{table_name}' 
            AND column_name = '{column_name}'
        );
    """))
    return result.scalar()

async def run_migration():
    """Execute Phase 1.5 database migrations"""
    
    print("=" * 60)
    print("🔧 Starting Phase 1.5 Migration: Fix Existing Tables")
    print("=" * 60)
    
    async with engine.begin() as conn:
        try:
            # =====================================================
            # Step 1: Rename metadata -> event_data in usage_analytics
            # =====================================================
            print("\n📝 Step 1: Fixing usage_analytics table...")
            
            if await table_exists(conn, 'usage_analytics'):
                # Check if old column exists
                has_metadata = await column_exists(conn, 'usage_analytics', 'metadata')
                has_event_data = await column_exists(conn, 'usage_analytics', 'event_data')
                
                if has_metadata and not has_event_data:
                    # Rename the column
                    await conn.execute(text("""
                        ALTER TABLE usage_analytics 
                        RENAME COLUMN metadata TO event_data;
                    """))
                    print("   ✅ Renamed 'metadata' to 'event_data' in usage_analytics")
                elif has_event_data:
                    print("   ℹ️  Column 'event_data' already exists")
                else:
                    # Neither exists, create event_data
                    await conn.execute(text("""
                        ALTER TABLE usage_analytics 
                        ADD COLUMN event_data JSONB;
                    """))
                    print("   ✅ Added 'event_data' column to usage_analytics")
            else:
                print("   ℹ️  usage_analytics table doesn't exist - will be created later")
            
            # =====================================================
            # Step 2: Add user_id to form_104_data (if table exists)
            # =====================================================
            print("\n📝 Step 2: Fixing form_104_data table...")
            
            if await table_exists(conn, 'form_104_data'):
                has_user_id = await column_exists(conn, 'form_104_data', 'user_id')
                
                if not has_user_id:
                    # Add user_id column
                    await conn.execute(text("""
                        ALTER TABLE form_104_data 
                        ADD COLUMN user_id INTEGER;
                    """))
                    
                    # Add foreign key
                    await conn.execute(text("""
                        ALTER TABLE form_104_data 
                        ADD CONSTRAINT fk_form104_data_user_id 
                        FOREIGN KEY (user_id) 
                        REFERENCES users(id) 
                        ON DELETE CASCADE;
                    """))
                    
                    # Add index
                    await conn.execute(text("""
                        CREATE INDEX idx_form_104_data_user_id 
                        ON form_104_data(user_id);
                    """))
                    
                    print("   ✅ Added user_id to form_104_data")
                    
                    # Assign existing records to admin
                    result = await conn.execute(text("""
                        SELECT id FROM users WHERE is_superuser = true LIMIT 1;
                    """))
                    admin_user = result.fetchone()
                    
                    if admin_user:
                        admin_id = admin_user[0]
                        await conn.execute(text(f"""
                            UPDATE form_104_data 
                            SET user_id = {admin_id} 
                            WHERE user_id IS NULL;
                        """))
                        print(f"   ✅ Assigned existing form_104_data records to admin user")
                else:
                    print("   ℹ️  user_id already exists in form_104_data")
            else:
                print("   ℹ️  form_104_data table doesn't exist yet")
            
            print("\n" + "=" * 60)
            print("✅ Phase 1.5 Migration Completed Successfully!")
            print("=" * 60)
            print("\nWhat was done:")
            print("✅ Fixed usage_analytics.event_data column")
            print("✅ Added user_id to form_104_data (if table exists)")
            print("\nNext Steps:")
            print("1. ✅ Restart backend to verify")
            print("2. ✅ Test all functionality")
            print("\n")
            
        except Exception as e:
            print(f"\n❌ Migration failed: {e}")
            print("Rolling back changes...")
            raise

async def verify_migration():
    """Verify that migration was successful"""
    
    print("\n🔍 Verifying Migration...")
    print("-" * 60)
    
    async with engine.begin() as conn:
        try:
            # Check usage_analytics.event_data
            if await table_exists(conn, 'usage_analytics'):
                has_event_data = await column_exists(conn, 'usage_analytics', 'event_data')
                if has_event_data:
                    print("✅ usage_analytics.event_data exists")
                else:
                    print("❌ usage_analytics.event_data missing")
            
            # Check form_104_data.user_id
            if await table_exists(conn, 'form_104_data'):
                has_user_id = await column_exists(conn, 'form_104_data', 'user_id')
                if has_user_id:
                    print("✅ form_104_data.user_id exists")
                else:
                    print("❌ form_104_data.user_id missing")
            
            print("-" * 60)
            print("✅ Verification complete!")
            
        except Exception as e:
            print(f"❌ Verification failed: {e}")

async def main():
    """Main function to run migration"""
    
    # Ask for confirmation
    print("\n⚠️  This migration will:")
    print("   - Rename metadata -> event_data in usage_analytics")
    print("   - Add user_id column to form_104_data (if table exists)")
    
    response = input("\n   Continue? (yes/no): ")
    
    if response.lower() not in ['yes', 'y']:
        print("Migration cancelled.")
        sys.exit(0)
    
    # Run migration
    await run_migration()
    
    # Verify migration
    await verify_migration()

if __name__ == "__main__":
    asyncio.run(main())
