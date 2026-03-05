"""
User service
"""
from sqlalchemy.orm import Session
from typing import Optional, List
from app.repositories.user_repository import UserRepository
from app.schemas.user_schema import UserCreate, UserUpdate
from app.exceptions.custom_exceptions import NotFoundError, ConflictError
from app.database.models import UserRole
from app.utils.security import verify_password
from app.utils.formatters import format_phone_number


class UserService:
    """Service for user operations"""
    
    @staticmethod
    def get_user(db: Session, user_id: int):
        """Get user by ID"""
        user = UserRepository.get_by_id(db, user_id)
        if not user:
            raise NotFoundError("User", str(user_id))
        return user
    
    @staticmethod
    def get_user_by_email(db: Session, email: str):
        """Get user by email"""
        return UserRepository.get_by_email(db, email)
    
    @staticmethod
    def get_user_by_phone(db: Session, phone: str):
        """Get user by phone"""
        formatted_phone = format_phone_number(phone)
        return UserRepository.get_by_phone(db, formatted_phone)
    
    @staticmethod
    def create_user(db: Session, user_data: UserCreate):
        """Create new user"""
        # Check if email exists
        if UserRepository.get_by_email(db, user_data.email):
            raise ConflictError("Email already registered")
        
        # Check if phone exists
        formatted_phone = format_phone_number(user_data.phone)
        if UserRepository.get_by_phone(db, formatted_phone):
            raise ConflictError("Phone number already registered")
        
        user_dict = user_data.model_dump()
        user_dict["phone"] = formatted_phone
        # PostgreSQL enum userrole uses lowercase ('user', 'admin')
        user_dict["role"] = UserRole.USER.value
        return UserRepository.create(db, user_dict)
    
    @staticmethod
    def update_user(db: Session, user_id: int, update_data: UserUpdate):
        """Update user"""
        user = UserService.get_user(db, user_id)
        
        update_dict = update_data.model_dump(exclude_unset=True)
        
        # Check email uniqueness if updating
        if "email" in update_dict:
            existing = UserRepository.get_by_email(db, update_dict["email"])
            if existing and existing.id != user_id:
                raise ConflictError("Email already registered")
        
        # Check phone uniqueness if updating
        if "phone" in update_dict:
            formatted_phone = format_phone_number(update_dict["phone"])
            existing = UserRepository.get_by_phone(db, formatted_phone)
            if existing and existing.id != user_id:
                raise ConflictError("Phone number already registered")
            update_dict["phone"] = formatted_phone
        
        return UserRepository.update(db, user, update_dict)
    
    @staticmethod
    def authenticate_user(db: Session, phone: str, password: str):
        """Authenticate user"""
        formatted_phone = format_phone_number(phone)
        user = UserRepository.get_by_phone(db, formatted_phone)
        
        if not user:
            return None
        
        if not verify_password(password, user.hashed_password):
            return None
        
        if not user.is_active:
            return None
        
        return user
    
    @staticmethod
    def get_job_seekers(db: Session, skip: int = 0, limit: int = 100, exclude_user_id: Optional[int] = None, skills: Optional[List[str]] = None):
        """Get users who are open to job seeking (open_to_job_seeker = True)"""
        return UserRepository.get_job_seekers(db, skip, limit, exclude_user_id, skills)
    
    @staticmethod
    def get_job_seekers_with_count(db: Session, skip: int = 0, limit: int = 100, exclude_user_id: Optional[int] = None, skills: Optional[List[str]] = None) -> tuple[List, int]:
        """Get users who are open to job seeking with total count"""
        return UserRepository.get_job_seekers_with_count(db, skip, limit, exclude_user_id, skills)