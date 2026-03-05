#!/usr/bin/env python3
"""
Script for creating database tables
Use this script if Alembic migrations don't work
"""
import sys
import os

# Add app to path
sys.path.insert(0, os.path.dirname(__file__))

from app.database.session import engine
from app.database.base import Base
# Import all models so they are registered in Base.metadata
from app.database.models import User, Profile, Company, Job, Application

def create_tables():
    """Create all database tables"""
    print("🔧 Connecting to database...")
    print(f"📊 DATABASE_URL: {os.environ.get('DATABASE_URL', 'from config.py')}")
    print("\n📦 Creating database tables...")
    try:
        # Create all tables based on models
        Base.metadata.create_all(bind=engine)
        print("\n✅ Tables created successfully!")
        print("\n📋 Created tables:")
        print("  ✓ users")
        print("  ✓ profiles")
        print("  ✓ companies")
        print("  ✓ jobs")
        print("  ✓ applications")
        print("\n🎉 Done! You can now start the server.")
    except Exception as e:
        print(f"\n❌ Error creating tables: {e}")
        print("\n💡 Check:")
        print("  1. Database 'ish_db' exists")
        print("  2. DATABASE_URL in .env file is correct")
        print("  3. PostgreSQL is running")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    create_tables()
