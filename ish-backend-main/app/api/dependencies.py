"""
API dependencies
"""
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from jose import JWTError
from app.database.session import get_db
from app.repositories.user_repository import UserRepository
from app.utils.security import decode_access_token
from app.exceptions.custom_exceptions import UnauthorizedError

security = HTTPBearer(auto_error=False)


def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
):
    """Get current authenticated user"""
    if credentials is None:
        raise UnauthorizedError("Authorization header missing. Please provide a Bearer token.")
    
    token = credentials.credentials.strip() if credentials.credentials else None
    
    if not token:
        raise UnauthorizedError("Token missing. Please provide a valid Bearer token.")
    
    try:
        payload = decode_access_token(token)
        if payload is None:
            raise UnauthorizedError("Invalid or expired token. Please login again.")
        
        user_id_str = payload.get("sub")
        if user_id_str is None:
            raise UnauthorizedError("Invalid token payload. User ID not found.")
        
        # Convert string back to int (JWT requires sub to be a string)
        try:
            user_id: int = int(user_id_str)
        except (ValueError, TypeError):
            raise UnauthorizedError("Invalid user ID in token.")
    except (JWTError, TypeError) as e:
        raise UnauthorizedError(f"Token validation failed: {str(e)}")
    except Exception as e:
        raise UnauthorizedError(f"Authentication error: {str(e)}")
    
    user = UserRepository.get_by_id(db, user_id)
    if user is None:
        raise UnauthorizedError("User not found")
    
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User is inactive"
        )
    
    return user


def get_current_active_user(current_user = Depends(get_current_user)):
    """Get current active user"""
    if not current_user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User is inactive"
        )
    return current_user


def get_current_user_optional(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
):
    """Get current authenticated user (optional - returns None if not authenticated)"""
    if credentials is None:
        return None
    
    token = credentials.credentials.strip() if credentials.credentials else None
    
    if not token:
        return None
    
    try:
        payload = decode_access_token(token)
        if payload is None:
            return None
        
        user_id_str = payload.get("sub")
        if user_id_str is None:
            return None
        
        try:
            user_id: int = int(user_id_str)
        except (ValueError, TypeError):
            return None
    except (JWTError, TypeError):
        return None
    except Exception:
        return None
    
    user = UserRepository.get_by_id(db, user_id)
    if user is None or not user.is_active:
        return None
    
    return user
