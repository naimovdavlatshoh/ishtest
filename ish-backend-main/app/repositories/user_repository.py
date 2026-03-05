"""
User repository
"""
from sqlalchemy.orm import Session
from sqlalchemy import or_
from typing import Optional, List
from app.database.models import User, Profile
from app.utils.security import get_password_hash


class UserRepository:
    """Repository for user operations"""
    
    @staticmethod
    def get_by_id(db: Session, user_id: int) -> Optional[User]:
        """Get user by ID"""
        return db.query(User).filter(User.id == user_id).first()
    
    @staticmethod
    def get_by_email(db: Session, email: str) -> Optional[User]:
        """Get user by email"""
        return db.query(User).filter(User.email == email).first()
    
    @staticmethod
    def get_by_phone(db: Session, phone: str) -> Optional[User]:
        """Get user by phone"""
        return db.query(User).filter(User.phone == phone).first()

    @staticmethod
    def get_by_telegram_id(db: Session, telegram_id: str) -> Optional[User]:
        """Get user by Telegram ID"""
        return db.query(User).filter(User.telegram_id == telegram_id).first()

    @staticmethod
    def get_job_seekers(db: Session, skip: int = 0, limit: int = 100, exclude_user_id: Optional[int] = None, skills: Optional[List[str]] = None) -> List[User]:
        """Get users who are open to job seeking (open_to_job_seeker = True)"""
        # Start with profiles that are open to job seeking
        profile_query = db.query(Profile).filter(Profile.open_to_job_seeker == True)
        
        # Filter by skills if provided
        if skills and len(skills) > 0:
            from sqlalchemy import text
            
            conditions = []
            for idx, skill in enumerate(skills):
                # Check if any element in skills array contains the skill (case-insensitive)
                # Using jsonb_array_elements_text to extract array elements
                # Use unique parameter name for each skill to avoid conflicts
                param_name = f"skill_{idx}"
                condition = text(
                    f"EXISTS (SELECT 1 FROM jsonb_array_elements_text(profiles.skills) AS elem WHERE LOWER(elem::text) LIKE LOWER('%' || :{param_name} || '%'))"
                ).bindparams(**{param_name: skill})
                conditions.append(condition)
            
            if conditions:
                # At least one skill must match
                profile_query = profile_query.filter(or_(*conditions))
        
        # Get user IDs from filtered profiles
        job_seeker_profile_ids = [row[0] for row in profile_query.with_entities(Profile.user_id).distinct().all()]
        
        if not job_seeker_profile_ids:
            return []
        
        query = db.query(User).filter(User.id.in_(job_seeker_profile_ids))
        
        # Exclude current user if provided
        if exclude_user_id is not None:
            query = query.filter(User.id != exclude_user_id)
        
        # Newest first
        query = query.order_by(User.created_at.desc())
        return query.offset(skip).limit(limit).all()
    
    @staticmethod
    def get_job_seekers_with_count(db: Session, skip: int = 0, limit: int = 100, exclude_user_id: Optional[int] = None, skills: Optional[List[str]] = None) -> tuple[List[User], int]:
        """Get users who are open to job seeking with total count"""
        # Start with profiles that are open to job seeking
        profile_query = db.query(Profile).filter(Profile.open_to_job_seeker == True)
        
        # Filter by skills if provided
        if skills and len(skills) > 0:
            from sqlalchemy import text
            
            conditions = []
            for idx, skill in enumerate(skills):
                param_name = f"skill_{idx}"
                condition = text(
                    f"EXISTS (SELECT 1 FROM jsonb_array_elements_text(profiles.skills) AS elem WHERE LOWER(elem::text) LIKE LOWER('%' || :{param_name} || '%'))"
                ).bindparams(**{param_name: skill})
                conditions.append(condition)
            
            if conditions:
                profile_query = profile_query.filter(or_(*conditions))
        
        # Get user IDs from filtered profiles
        job_seeker_profile_ids = [row[0] for row in profile_query.with_entities(Profile.user_id).distinct().all()]
        
        if not job_seeker_profile_ids:
            return [], 0
        
        query = db.query(User).filter(User.id.in_(job_seeker_profile_ids))
        
        # Exclude current user if provided
        if exclude_user_id is not None:
            query = query.filter(User.id != exclude_user_id)
        
        total = query.count()
        # Newest first
        query = query.order_by(User.created_at.desc())
        users = query.offset(skip).limit(limit).all()
        
        return users, total
    
    @staticmethod
    def create(db: Session, user_data: dict) -> User:
        """Create new user"""
        if "password" in user_data:
            user_data["hashed_password"] = get_password_hash(user_data.pop("password"))
        
        user = User(**user_data)
        db.add(user)
        db.commit()
        db.refresh(user)
        return user
    
    @staticmethod
    def update(db: Session, user: User, update_data: dict) -> User:
        """Update user"""
        if "password" in update_data:
            update_data["hashed_password"] = get_password_hash(update_data.pop("password"))
        
        for key, value in update_data.items():
            setattr(user, key, value)
        
        db.commit()
        db.refresh(user)
        return user
    
    @staticmethod
    def delete(db: Session, user: User) -> None:
        """Delete user"""
        db.delete(user)
        db.commit()
