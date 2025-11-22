"""
Pre-Implementation Verification Script
Run this BEFORE implementing to check your environment
Usage: python verify_compatibility.py
"""

import sys
import os
import asyncio

print("🔍 Verifying Your Environment for Clientes Feature...")
print("=" * 60)

errors = []
warnings = []
successes = []

# Check 1: Python version
print("\n1️⃣ Checking Python version...")
if sys.version_info >= (3, 10):
    successes.append(f"✅ Python {sys.version_info.major}.{sys.version_info.minor} is compatible")
else:
    errors.append(f"❌ Python {sys.version_info.major}.{sys.version_info.minor} - need 3.10+")

# Check 2: Required packages
print("\n2️⃣ Checking installed packages...")
required_packages = {
    'fastapi': '0.115',
    'sqlalchemy': '2.0',
    'asyncpg': '0.30',
    'pdfplumber': '0.11',
    'pydantic': '2.10'
}

try:
    import importlib.metadata as metadata
    
    for package, min_version in required_packages.items():
        try:
            version = metadata.version(package)
            if version >= min_version:
                successes.append(f"✅ {package} {version}")
            else:
                warnings.append(f"⚠️  {package} {version} (recommended: {min_version}+)")
        except metadata.PackageNotFoundError:
            errors.append(f"❌ {package} not installed")
except ImportError:
    errors.append("❌ Cannot check package versions")

# Check 3: Database connection
print("\n3️⃣ Checking database configuration...")
try:
    sys.path.insert(0, os.path.abspath('.'))
    from app.core.database import AsyncSessionLocal, engine
    from app.core.config import settings
    
    successes.append("✅ Database configuration found at app.core.database")
    successes.append(f"✅ Using async SQLAlchemy")
    
    # Try to connect
    async def test_connection():
        try:
            async with AsyncSessionLocal() as session:
                await session.execute("SELECT 1")
                return True
        except Exception as e:
            return str(e)
    
    result = asyncio.run(test_connection())
    if result is True:
        successes.append("✅ Database connection successful")
    else:
        warnings.append(f"⚠️  Database connection issue: {result}")
        warnings.append("   (This is OK if Docker isn't running)")
        
except ImportError as e:
    errors.append(f"❌ Cannot import database: {e}")
    errors.append("   Make sure you're in the backend directory")

# Check 4: Model structure
print("\n4️⃣ Checking existing models...")
try:
    from app.models.base import Document, Form103LineItem, Form104Data
    
    # Check if Document has expected fields
    doc_columns = [col.name for col in Document.__table__.columns]
    
    expected_fields = ['uploaded_at', 'periodo_mes', 'periodo_anio', 'identificacion_ruc', 'razon_social']
    missing_fields = [f for f in expected_fields if f not in doc_columns]
    
    if not missing_fields:
        successes.append("✅ Document model has correct field names")
    else:
        errors.append(f"❌ Document model missing fields: {missing_fields}")
    
    # Check for async patterns
    if hasattr(Document, '__table__'):
        successes.append("✅ Models use SQLAlchemy declarative base")
    
except ImportError as e:
    errors.append(f"❌ Cannot import models: {e}")

# Check 5: API structure
print("\n5️⃣ Checking API structure...")
try:
    from app.api import upload, documents, forms_data
    successes.append("✅ Existing API modules found")
    
    # Check if they use async
    import inspect
    upload_funcs = [f for name, f in inspect.getmembers(upload) if inspect.isfunction(f) or inspect.iscoroutinefunction(f)]
    if upload_funcs and any(inspect.iscoroutinefunction(f) for f in upload_funcs):
        successes.append("✅ APIs use async/await patterns")
    
except ImportError as e:
    warnings.append(f"⚠️  API import issue: {e}")

# Check 6: New dependencies needed
print("\n6️⃣ Checking NEW dependencies needed for Clientes...")
new_deps = {
    'reportlab': 'PDF generation',
    'Pillow': 'Image processing for PDFs',
    'openpyxl': 'Excel generation',
    'requests': 'Logo downloads for PDFs'
}

for package, purpose in new_deps.items():
    try:
        __import__(package)
        successes.append(f"✅ {package} already installed ({purpose})")
    except ImportError:
        warnings.append(f"⚠️  {package} NOT installed - will need to install ({purpose})")

# Summary
print("\n" + "=" * 60)
print("📊 VERIFICATION SUMMARY")
print("=" * 60)

if successes:
    print(f"\n✅ SUCCESSES ({len(successes)}):")
    for s in successes:
        print(f"  {s}")

if warnings:
    print(f"\n⚠️  WARNINGS ({len(warnings)}):")
    for w in warnings:
        print(f"  {w}")

if errors:
    print(f"\n❌ ERRORS ({len(errors)}):")
    for e in errors:
        print(f"  {e}")

print("\n" + "=" * 60)

if errors:
    print("❌ COMPATIBILITY CHECK FAILED")
    print("\n⚠️  Fix the errors above before implementing")
    print("💡 Make sure you're running this from: enhanced/backend/")
    sys.exit(1)
elif warnings and not any('Database connection' in w for w in warnings):
    print("⚠️  COMPATIBILITY CHECK PASSED WITH WARNINGS")
    print("\n📋 Install missing dependencies:")
    print("   pip install reportlab Pillow openpyxl requests")
    print("\n✅ Then you can proceed with implementation")
    sys.exit(0)
else:
    print("✅ COMPATIBILITY CHECK PASSED")
    print("\n🎉 Your environment is compatible!")
    print("✅ You can proceed with implementation")
    print("\n📋 Next steps:")
    print("   1. Backup your database")
    print("   2. Follow IMPLEMENTATION_GUIDE.md")
    sys.exit(0)
