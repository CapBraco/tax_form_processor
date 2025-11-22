"""
Enhanced Database initialization script.
Creates tables for documents, form_103_line_items, and form_104_data
"""

import asyncio
from app.core.database import engine, Base
from app.models.base import Document, Form103LineItem, Form104Data

async def init_database():
    """Initialize database - create all tables"""
    print("🗄️  Initializing enhanced database...")
    
    async with engine.begin() as conn:
        # Drop all tables (for clean start - remove in production!)
        # await conn.run_sync(Base.metadata.drop_all)
        
        # Create all tables
        await conn.run_sync(Base.metadata.create_all)
    
    print("✅ Database tables created successfully!")
    print("\nTables created:")
    print("  - documents (stores PDFs and headers)")
    print("  - form_103_line_items (Form 103 line items with BASE IMPONIBLE and VALOR RETENIDO)")
    print("  - form_104_data (Form 104 structured IVA data)")

async def main():
    """Main initialization function"""
    try:
        await init_database()
        print("\n✨ Enhanced database initialization complete!")
        print("\nYou can now:")
        print("  1. Upload Form 103 PDFs (Retenciones)")
        print("  2. Upload Form 104 PDFs (IVA)")
        print("  3. Query structured data via API")
        
    except Exception as e:
        print(f"❌ Error initializing database: {e}")
        import traceback
        traceback.print_exc()
    finally:
        await engine.dispose()

if __name__ == "__main__":
    asyncio.run(main())
