"""
Database Backup Script - Run BEFORE Phase 1 Migration
Creates a backup of your database to ensure data safety
"""

import subprocess
import sys
from datetime import datetime
import os

def create_backup():
    """Create a PostgreSQL database backup"""
    
    print("=" * 60)
    print("💾 Creating Database Backup")
    print("=" * 60)
    
    # Database connection details
    db_name = "pdf_extractor_db"
    backup_dir = "backups"
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_file = f"{backup_dir}/backup_{db_name}_{timestamp}.sql"
    
    # Create backup directory if it doesn't exist
    os.makedirs(backup_dir, exist_ok=True)
    
    print(f"\n📋 Database: {db_name}")
    print(f"📁 Backup file: {backup_file}")
    
    try:
        # Run pg_dump command
        print("\n🔄 Creating backup...")
        
        # Windows command
        if sys.platform == "win32":
            cmd = f'pg_dump -U postgres -d {db_name} -f {backup_file}'
        else:
            # Linux/Mac command
            cmd = f'pg_dump -U postgres {db_name} > {backup_file}'
        
        result = subprocess.run(
            cmd,
            shell=True,
            capture_output=True,
            text=True
        )
        
        if result.returncode == 0:
            # Check file size
            file_size = os.path.getsize(backup_file)
            size_mb = file_size / (1024 * 1024)
            
            print(f"✅ Backup created successfully!")
            print(f"📊 Size: {size_mb:.2f} MB")
            print(f"📍 Location: {os.path.abspath(backup_file)}")
            
            print("\n" + "=" * 60)
            print("✅ Backup Complete!")
            print("=" * 60)
            print("\n💡 To restore from backup, run:")
            print(f"   psql -U postgres -d {db_name} < {backup_file}")
            print("\n")
            
            return True
        else:
            print(f"❌ Backup failed!")
            print(f"Error: {result.stderr}")
            return False
            
    except Exception as e:
        print(f"❌ Error creating backup: {e}")
        print("\n💡 Alternative: Use pgAdmin to create a backup manually")
        print("   1. Right-click on database")
        print("   2. Select 'Backup...'")
        print("   3. Choose location and click 'Backup'")
        return False

if __name__ == "__main__":
    print("\n⚠️  IMPORTANT: Creating a backup before migration")
    print("   This ensures you can restore if something goes wrong.\n")
    
    response = input("   Continue with backup? (yes/no): ")
    
    if response.lower() not in ['yes', 'y']:
        print("Backup cancelled.")
        sys.exit(0)
    
    success = create_backup()
    
    if not success:
        print("\n⚠️  Backup failed! Please create a manual backup before proceeding.")
        sys.exit(1)
