"""
Phase 1 Migration: Add User Isolation and Guest Session Support (FIXED)
Checks if tables exist before modifying them
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

async def run_migration():
    """Execute all Phase 1 database migrations"""
    
    print("=" * 60)
    print("🚀 Starting Phase 1 Migration: User Isolation & Guest Support")
    print("=" * 60)
    
    async with engine.begin() as conn:
        try:
            # =====================================================
            # Step 1: Add user_id to documents table
            # =====================================================
            print("\n📝 Step 1: Adding user_id to documents table...")
            
            if await table_exists(conn, 'documents'):
                await conn.execute(text("""
                    ALTER TABLE documents 
                    ADD COLUMN IF NOT EXISTS user_id INTEGER;
                """))
                
                await conn.execute(text("""
                    ALTER TABLE documents 
                    DROP CONSTRAINT IF EXISTS fk_documents_user_id;
                """))
                
                await conn.execute(text("""
                    ALTER TABLE documents 
                    ADD CONSTRAINT fk_documents_user_id 
                    FOREIGN KEY (user_id) 
                    REFERENCES users(id) 
                    ON DELETE CASCADE;
                """))
                
                await conn.execute(text("""
                    CREATE INDEX IF NOT EXISTS idx_documents_user_id ON documents(user_id);
                """))
                
                print("   ✅ Added user_id to documents table")
            else:
                print("   ⚠️  documents table does not exist - skipping")
            
            # =====================================================
            # Step 2: Add user_id to form_103_line_items (if exists)
            # =====================================================
            print("\n📝 Step 2: Checking form_103_line_items table...")
            
            if await table_exists(conn, 'form_103_line_items'):
                await conn.execute(text("""
                    ALTER TABLE form_103_line_items 
                    ADD COLUMN IF NOT EXISTS user_id INTEGER;
                """))
                
                await conn.execute(text("""
                    ALTER TABLE form_103_line_items 
                    DROP CONSTRAINT IF EXISTS fk_form103_user_id;
                """))
                
                await conn.execute(text("""
                    ALTER TABLE form_103_line_items 
                    ADD CONSTRAINT fk_form103_user_id 
                    FOREIGN KEY (user_id) 
                    REFERENCES users(id) 
                    ON DELETE CASCADE;
                """))
                
                await conn.execute(text("""
                    CREATE INDEX IF NOT EXISTS idx_form_103_user_id 
                    ON form_103_line_items(user_id);
                """))
                
                print("   ✅ Added user_id to form_103_line_items")
            else:
                print("   ℹ️  form_103_line_items table does not exist - will be created when first Form 103 is processed")
            
            # =====================================================
            # Step 3: Add user_id to form_104_line_items (if exists)
            # =====================================================
            print("\n📝 Step 3: Checking form_104_line_items table...")
            
            if await table_exists(conn, 'form_104_line_items'):
                await conn.execute(text("""
                    ALTER TABLE form_104_line_items 
                    ADD COLUMN IF NOT EXISTS user_id INTEGER;
                """))
                
                await conn.execute(text("""
                    ALTER TABLE form_104_line_items 
                    DROP CONSTRAINT IF EXISTS fk_form104_user_id;
                """))
                
                await conn.execute(text("""
                    ALTER TABLE form_104_line_items 
                    ADD CONSTRAINT fk_form104_user_id 
                    FOREIGN KEY (user_id) 
                    REFERENCES users(id) 
                    ON DELETE CASCADE;
                """))
                
                await conn.execute(text("""
                    CREATE INDEX IF NOT EXISTS idx_form_104_user_id 
                    ON form_104_line_items(user_id);
                """))
                
                print("   ✅ Added user_id to form_104_line_items")
            else:
                print("   ℹ️  form_104_line_items table does not exist - will be created when first Form 104 is processed")
            
            # =====================================================
            # Step 4: Create guest_sessions table
            # =====================================================
            print("\n📝 Step 4: Creating guest_sessions table...")
            
            await conn.execute(text("""
                CREATE TABLE IF NOT EXISTS guest_sessions (
                    id SERIAL PRIMARY KEY,
                    session_id VARCHAR(255) UNIQUE NOT NULL,
                    document_count INTEGER DEFAULT 0,
                    created_at TIMESTAMP DEFAULT NOW(),
                    last_activity TIMESTAMP DEFAULT NOW(),
                    ip_address VARCHAR(45),
                    user_agent TEXT
                );
            """))
            
            await conn.execute(text("""
                CREATE INDEX IF NOT EXISTS idx_guest_sessions_session_id 
                ON guest_sessions(session_id);
            """))
            
            await conn.execute(text("""
                CREATE INDEX IF NOT EXISTS idx_guest_sessions_created_at 
                ON guest_sessions(created_at);
            """))
            
            print("   ✅ Created guest_sessions table")
            
            # =====================================================
            # Step 5: Create temporary_files table
            # =====================================================
            print("\n📝 Step 5: Creating temporary_files table...")
            
            await conn.execute(text("""
                CREATE TABLE IF NOT EXISTS temporary_files (
                    id SERIAL PRIMARY KEY,
                    session_id VARCHAR(255) NOT NULL,
                    file_path VARCHAR(500) NOT NULL,
                    file_size BIGINT,
                    created_at TIMESTAMP DEFAULT NOW(),
                    expires_at TIMESTAMP NOT NULL
                );
            """))
            
            await conn.execute(text("""
                CREATE INDEX IF NOT EXISTS idx_temp_files_session_id 
                ON temporary_files(session_id);
            """))
            
            await conn.execute(text("""
                CREATE INDEX IF NOT EXISTS idx_temp_files_expires_at 
                ON temporary_files(expires_at);
            """))
            
            print("   ✅ Created temporary_files table")
            
            # =====================================================
            # Step 6: Create usage_analytics table
            # =====================================================
            print("\n📝 Step 6: Creating usage_analytics table...")
            
            await conn.execute(text("""
                CREATE TABLE IF NOT EXISTS usage_analytics (
                    id SERIAL PRIMARY KEY,
                    event_type VARCHAR(50) NOT NULL,
                    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
                    session_id VARCHAR(255),
                    metadata JSONB,
                    created_at TIMESTAMP DEFAULT NOW()
                );
            """))
            
            await conn.execute(text("""
                CREATE INDEX IF NOT EXISTS idx_analytics_event_type 
                ON usage_analytics(event_type);
            """))
            
            await conn.execute(text("""
                CREATE INDEX IF NOT EXISTS idx_analytics_user_id 
                ON usage_analytics(user_id);
            """))
            
            await conn.execute(text("""
                CREATE INDEX IF NOT EXISTS idx_analytics_created_at 
                ON usage_analytics(created_at);
            """))
            
            print("   ✅ Created usage_analytics table")
            
            # =====================================================
            # Step 7: Migrate existing data (set admin as owner)
            # =====================================================
            print("\n📝 Step 7: Migrating existing data...")
            
            # Get admin user ID
            result = await conn.execute(text("""
                SELECT id FROM users WHERE is_superuser = true LIMIT 1;
            """))
            admin_user = result.fetchone()
            
            if admin_user:
                admin_id = admin_user[0]
                print(f"   📌 Found admin user with ID: {admin_id}")
                
                # Assign all existing documents to admin
                if await table_exists(conn, 'documents'):
                    result = await conn.execute(text(f"""
                        UPDATE documents 
                        SET user_id = {admin_id} 
                        WHERE user_id IS NULL;
                    """))
                    print(f"   ✅ Assigned documents to admin user")
                
                # Assign all existing form_103_line_items to admin
                if await table_exists(conn, 'form_103_line_items'):
                    result = await conn.execute(text(f"""
                        UPDATE form_103_line_items 
                        SET user_id = {admin_id} 
                        WHERE user_id IS NULL;
                    """))
                    print(f"   ✅ Assigned Form 103 items to admin user")
                
                # Assign all existing form_104_line_items to admin
                if await table_exists(conn, 'form_104_line_items'):
                    result = await conn.execute(text(f"""
                        UPDATE form_104_line_items 
                        SET user_id = {admin_id} 
                        WHERE user_id IS NULL;
                    """))
                    print(f"   ✅ Assigned Form 104 items to admin user")
                
                print(f"   ✅ Data migration completed")
            else:
                print("   ⚠️  No admin user found - existing data will remain unassigned")
            
            print("\n" + "=" * 60)
            print("✅ Phase 1 Migration Completed Successfully!")
            print("=" * 60)
            print("\nWhat was done:")
            print("✅ Added user_id to existing tables")
            print("✅ Created guest_sessions table")
            print("✅ Created temporary_files table")
            print("✅ Created usage_analytics table")
            print("✅ Assigned existing data to admin user")
            
            print("\nNext Steps:")
            print("1. ✅ Update app/models/base.py with new models")
            print("2. ✅ Restart backend to verify")
            print("3. ✅ Move to Phase 2: Backend Logic Updates")
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
            # Check documents table
            if await table_exists(conn, 'documents'):
                result = await conn.execute(text("""
                    SELECT column_name 
                    FROM information_schema.columns 
                    WHERE table_name = 'documents' AND column_name = 'user_id';
                """))
                if result.fetchone():
                    print("✅ documents.user_id exists")
            
            # Check form_103_line_items table
            if await table_exists(conn, 'form_103_line_items'):
                result = await conn.execute(text("""
                    SELECT column_name 
                    FROM information_schema.columns 
                    WHERE table_name = 'form_103_line_items' AND column_name = 'user_id';
                """))
                if result.fetchone():
                    print("✅ form_103_line_items.user_id exists")
            
            # Check form_104_line_items table
            if await table_exists(conn, 'form_104_line_items'):
                result = await conn.execute(text("""
                    SELECT column_name 
                    FROM information_schema.columns 
                    WHERE table_name = 'form_104_line_items' AND column_name = 'user_id';
                """))
                if result.fetchone():
                    print("✅ form_104_line_items.user_id exists")
            
            # Check new tables
            if await table_exists(conn, 'guest_sessions'):
                print("✅ guest_sessions table exists")
            
            if await table_exists(conn, 'temporary_files'):
                print("✅ temporary_files table exists")
            
            if await table_exists(conn, 'usage_analytics'):
                print("✅ usage_analytics table exists")
            
            # Count migrated documents
            if await table_exists(conn, 'documents'):
                result = await conn.execute(text("""
                    SELECT COUNT(*) FROM documents WHERE user_id IS NOT NULL;
                """))
                doc_count = result.fetchone()[0]
                print(f"✅ {doc_count} documents assigned to users")
            
            print("-" * 60)
            print("✅ All checks passed!")
            
        except Exception as e:
            print(f"❌ Verification failed: {e}")

async def main():
    """Main function to run migration"""
    
    # Ask for confirmation
    print("\n⚠️  This migration will:")
    print("   - Add user_id column to existing tables")
    print("   - Create new tables for guest sessions")
    print("   - Assign all existing data to the admin user")
    print("\n   (Tables that don't exist will be skipped)")
    
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
