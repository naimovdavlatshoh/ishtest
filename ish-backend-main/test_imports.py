#!/usr/bin/env python3
"""
Import test - checks that all modules can be imported
"""
import sys

def test_imports():
    """Test import of all modules"""
    errors = []
    
    try:
        print("✓ Importing FastAPI...")
        import fastapi
    except ImportError as e:
        errors.append(f"FastAPI: {e}")
    
    try:
        print("✓ Importing app.core.config...")
        from app.core.config import settings
        print(f"  HOST: {settings.HOST}, PORT: {settings.PORT}")
    except Exception as e:
        errors.append(f"app.core.config: {e}")
    
    try:
        print("✓ Importing app.main...")
        from app.main import app
        print("  FastAPI app created successfully")
    except Exception as e:
        errors.append(f"app.main: {e}")
        import traceback
        traceback.print_exc()
    
    if errors:
        print("\n❌ Import errors:")
        for error in errors:
            print(f"  - {error}")
        return False
    else:
        print("\n✅ All imports successful!")
        print(f"\n🌐 Server should start on http://{settings.HOST}:{settings.PORT}")
        return True

if __name__ == "__main__":
    success = test_imports()
    sys.exit(0 if success else 1)
