"""
Profile repository - Professional implementation with JSONB
"""
from sqlalchemy.orm import Session
from typing import Optional
from app.database.models import Profile

class ProfileRepository:
    """
    Repository for profile operations.
    Leverages PostgreSQL JSONB for automatic serialization/deserialization.
    """
    
    @staticmethod
    def get_by_user_id(db: Session, user_id: int) -> Optional[Profile]:
        """Get profile by user ID"""
        return db.query(Profile).filter(Profile.user_id == user_id).first()
    
    @staticmethod
    def create(db: Session, profile_data: dict) -> Profile:
        """Create new profile"""
        profile = Profile(**profile_data)
        db.add(profile)
        db.commit()
        db.refresh(profile)
        return profile
    
    @staticmethod
    def update(db: Session, profile: Profile, update_data: dict) -> Profile:
        """Update profile attributes"""
        for key, value in update_data.items():
            setattr(profile, key, value)
        
        db.commit()
        db.refresh(profile)
        return profile
    
    @staticmethod
    def delete(db: Session, profile: Profile) -> None:
        """Delete profile"""
        db.delete(profile)
        db.commit()

    @staticmethod
    def increment_views(db: Session, profile: Profile) -> Profile:
        """Increment profile views count"""
        profile.views_count = (profile.views_count or 0) + 1
        db.commit()
        db.refresh(profile)
        return profile
