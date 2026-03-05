"""
Profile service - like LinkedIn, supports multiple capabilities simultaneously
"""
import json
from sqlalchemy.orm import Session
from typing import Optional
from app.repositories.profile_repository import ProfileRepository
from app.repositories.user_repository import UserRepository
from app.repositories.application_repository import ApplicationRepository
from app.repositories.chat_repository import MessageRepository
from app.schemas.profile_schema import ProfileCreate, ProfileUpdate
from app.exceptions.custom_exceptions import NotFoundError, ConflictError


def _full_name_to_first_last(full_name: str) -> tuple[str, str]:
    """Split full_name into first_name and last_name (User model has both required, max 100 chars)."""
    parts = (full_name or "").strip().split(maxsplit=1)
    if not parts:
        return ("", "")
    first = (parts[0] or "")[:100]
    last = (parts[1] if len(parts) > 1 else parts[0] or "")[:100]
    return (first, last)


class ProfileService:
    """Service for profile operations"""
    
    @staticmethod
    def get_profile_by_user_id(db: Session, user_id: int, viewer_user_id: Optional[int] = None):
        """Get profile by user ID. If viewer_user_id is set and different from profile owner, increment views_count."""
        profile = ProfileRepository.get_by_user_id(db, user_id)
        if not profile:
            raise NotFoundError("Profile", f"for user {user_id}")
        if viewer_user_id is not None and viewer_user_id != profile.user_id:
            ProfileRepository.increment_views(db, profile)
        return profile
    
    @staticmethod
    def create_profile(db: Session, profile_data: ProfileCreate, user_id: int):
        """Create new profile - all sections are optional"""
        # Check if user exists
        user = UserRepository.get_by_id(db, user_id)
        if not user:
            raise NotFoundError("User", str(user_id))
        
        # Check if profile already exists
        existing = ProfileRepository.get_by_user_id(db, user_id)
        if existing:
            raise ConflictError("Profile already exists for this user")
        
        profile_dict = profile_data.model_dump(exclude_unset=True)
        profile_dict['user_id'] = user_id
        
        # Convert nested models to dicts
        if profile_dict.get('employer_info'):
            if hasattr(profile_dict['employer_info'], 'model_dump'):
                profile_dict['employer_info'] = profile_dict['employer_info'].model_dump()
        
        if profile_dict.get('freelancer_info'):
            if hasattr(profile_dict['freelancer_info'], 'model_dump'):
                profile_dict['freelancer_info'] = profile_dict['freelancer_info'].model_dump()
        
        # Check completion for each section
        completion_flags = ProfileService._check_section_completeness(profile_dict)
        
        # Ensure all completion flags are boolean, never None
        profile_dict['job_seeker_complete'] = bool(completion_flags.get('job_seeker_complete', False))
        profile_dict['employer_complete'] = bool(completion_flags.get('employer_complete', False))
        profile_dict['freelancer_complete'] = bool(completion_flags.get('freelancer_complete', False))
        
        # Overall completion: at least one section should be complete
        profile_dict['is_complete'] = bool(any([
            profile_dict['job_seeker_complete'],
            profile_dict['employer_complete'],
            profile_dict['freelancer_complete']
        ]))
        
        profile = ProfileRepository.create(db, profile_dict)
        # Keep User.first_name / User.last_name in sync with Profile.full_name (used on Employees page etc.)
        full_name = profile_dict.get("full_name") or getattr(profile, "full_name", "")
        if full_name:
            first_name, last_name = _full_name_to_first_last(full_name)
            if first_name:
                UserRepository.update(db, user, {"first_name": first_name, "last_name": last_name or first_name})
        return profile
    
    @staticmethod
    def update_profile(db: Session, user_id: int, update_data: ProfileUpdate):
        """Update profile - all sections are optional"""
        profile = ProfileService.get_profile_by_user_id(db, user_id)
        
        update_dict = update_data.model_dump(exclude_unset=True)
        
        # Convert nested models to dicts
        if update_dict.get('employer_info'):
            if hasattr(update_dict['employer_info'], 'model_dump'):
                update_dict['employer_info'] = update_dict['employer_info'].model_dump()
        
        if update_dict.get('freelancer_info'):
            if hasattr(update_dict['freelancer_info'], 'model_dump'):
                update_dict['freelancer_info'] = update_dict['freelancer_info'].model_dump()
        
        # Merge with existing profile data
        # SQLAlchemy handles JSON fields automatically now
        existing_data = {
            'skills': profile.skills or [],
            'experience': profile.experience or [],
            'education': profile.education or [],
            'cv_file': profile.cv_file,
            'employer_info': profile.employer_info or {},
            'freelancer_info': profile.freelancer_info or {},
            'bio': profile.bio,
            'title': profile.title,
        }
        
        # Update with new data
        existing_data.update(update_dict)
        
        # Check completion for each section based on merged data
        completion_flags = ProfileService._check_section_completeness(existing_data)
        
        # Always set completion flags (they are NOT NULL in DB)
        # These flags are always recalculated based on current profile state
        # Ensure they are always boolean, never None
        update_dict['job_seeker_complete'] = bool(completion_flags.get('job_seeker_complete', False))
        update_dict['employer_complete'] = bool(completion_flags.get('employer_complete', False))
        update_dict['freelancer_complete'] = bool(completion_flags.get('freelancer_complete', False))
        
        # Overall completion
        update_dict['is_complete'] = bool(any([
            update_dict['job_seeker_complete'],
            update_dict['employer_complete'],
            update_dict['freelancer_complete']
        ]))
        
        # Keep User.first_name / User.last_name in sync when full_name is updated (used on Employees page etc.)
        if "full_name" in update_dict and update_dict["full_name"]:
            first_name, last_name = _full_name_to_first_last(update_dict["full_name"])
            if first_name:
                UserRepository.update(db, profile.user, {"first_name": first_name, "last_name": last_name or first_name})
        
        return ProfileRepository.update(db, profile, update_dict)
    
    @staticmethod
    def _check_section_completeness(profile_data: dict) -> dict:
        """Check completion status for each section"""
        # SQLAlchemy handles JSON fields as objects now
        skills = profile_data.get("skills") or []
        experience = profile_data.get("experience") or []
        education = profile_data.get("education") or []
        employer_info = profile_data.get("employer_info") or {}
        freelancer_info = profile_data.get("freelancer_info") or {}
        
        # Job Seeker section is complete if has bio, skills, and at least one experience or education
        bio = profile_data.get("bio")
        bio_valid = bool(bio and len(str(bio)) >= 20)
        skills_valid = bool(skills and len(skills) > 0)
        experience_valid = bool(experience and len(experience) > 0)
        education_valid = bool(education and len(education) > 0)
        
        job_seeker_complete = bool(
            bio_valid and
            skills_valid and
            (experience_valid or education_valid)
        )
        
        # Employer section is complete if has business_type
        employer_complete = bool(employer_info and employer_info.get("business_type"))
        
        # Freelancer section is complete if has services
        freelancer_complete = bool(
            freelancer_info and
            freelancer_info.get("services") and
            len(freelancer_info["services"]) > 0
        )
        
        # Ensure all values are boolean, never None
        return {
            'job_seeker_complete': bool(job_seeker_complete),
            'employer_complete': bool(employer_complete),
            'freelancer_complete': bool(freelancer_complete)
        }

    @staticmethod
    def get_dashboard_stats(db: Session, user_id: int) -> dict:
        """Get dashboard stats: profile_views, jobs_applied, connections, notifications."""
        profile = ProfileRepository.get_by_user_id(db, user_id)
        profile_views = 0
        if profile:
            profile_views = getattr(profile, "views_count", 0) or 0
        jobs_applied = ApplicationRepository.count_by_applicant(db, user_id)
        connections = 0  # No connections feature yet
        notifications = MessageRepository.get_total_unread_count_for_user(db, user_id)
        return {
            "profile_views": profile_views,
            "jobs_applied": jobs_applied,
            "connections": connections,
            "notifications": notifications,
        }