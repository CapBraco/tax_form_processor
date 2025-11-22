"""
Migration: Add Clientes Feature Fields
Compatible with ASYNC SQLAlchemy
Run this with: python -m alembic revision --autogenerate -m "add_clientes_fields"
Then: python -m alembic upgrade head

OR run this standalone script for direct SQL execution
"""

import asyncio
import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../..')))

from sqlalchemy import text
from app.core.database import engine, Base
from app.models.base import Form103Totals


async def run_migration():
    """Run database migration to add new columns and tables"""
    
    print("🔄 Starting migration...")
    
    async with engine.begin() as conn:
        # Step 1: Add new columns to documents table (if they don't exist)
        print("\n📝 Adding new columns to documents table...")
        
        # Add periodo_fiscal_completo column
        try:
            await conn.execute(text(
                "ALTER TABLE documents ADD COLUMN IF NOT EXISTS periodo_fiscal_completo VARCHAR(50)"
            ))
            print("✅ Added periodo_fiscal_completo column")
        except Exception as e:
            print(f"⏭️  periodo_fiscal_completo: {e}")
        
        # Add periodo_mes_numero column
        try:
            await conn.execute(text(
                "ALTER TABLE documents ADD COLUMN IF NOT EXISTS periodo_mes_numero INTEGER"
            ))
            print("✅ Added periodo_mes_numero column")
        except Exception as e:
            print(f"⏭️  periodo_mes_numero: {e}")
        
        # Add indices for existing columns (improve query performance)
        try:
            await conn.execute(text(
                "CREATE INDEX IF NOT EXISTS idx_documents_razon_social ON documents(razon_social)"
            ))
            print("✅ Created index on razon_social")
        except Exception as e:
            print(f"⏭️  Index on razon_social: {e}")
        
        try:
            await conn.execute(text(
                "CREATE INDEX IF NOT EXISTS idx_documents_periodo_mes ON documents(periodo_mes)"
            ))
            print("✅ Created index on periodo_mes")
        except Exception as e:
            print(f"⏭️  Index on periodo_mes: {e}")
        
        try:
            await conn.execute(text(
                "CREATE INDEX IF NOT EXISTS idx_documents_periodo_mes_numero ON documents(periodo_mes_numero)"
            ))
            print("✅ Created index on periodo_mes_numero")
        except Exception as e:
            print(f"⏭️  Index on periodo_mes_numero: {e}")
    
    # Step 2: Create Form103Totals table
    print("\n📊 Creating form_103_totals table...")
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all, tables=[Form103Totals.__table__])
        print("✅ Created form_103_totals table")
    
    print("\n✨ Migration completed successfully!")
    print("\n📋 Next steps:")
    print("1. Restart your backend server")
    print("2. Run: python backend/app/scripts/reprocess_documents.py")
    print("   (to extract razon_social, periodo data from existing PDFs)")


if __name__ == "__main__":
    asyncio.run(run_migration())
