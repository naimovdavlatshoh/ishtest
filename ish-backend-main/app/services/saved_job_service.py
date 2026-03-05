"""
Saved job service
"""
from sqlalchemy.orm import Session
from typing import List
from app.repositories.saved_job_repository import SavedJobRepository
from app.repositories.job_repository import JobRepository
from app.exceptions.custom_exceptions import NotFoundError


class SavedJobService:
    """Service for saved job operations"""
    
    @staticmethod
    def save_job(db: Session, user_id: int, job_id: int):
        """Save a job for a user"""
        # Check if job exists
        job = JobRepository.get_by_id(db, job_id)
        if not job:
            raise NotFoundError("Job", str(job_id))
        
        # Check if already saved
        existing = SavedJobRepository.get_by_user_and_job(db, user_id, job_id)
        if existing:
            return existing  # Already saved, return existing
        
        return SavedJobRepository.save_job(db, user_id, job_id)
    
    @staticmethod
    def unsave_job(db: Session, user_id: int, job_id: int):
        """Remove a saved job"""
        # Check if job exists
        job = JobRepository.get_by_id(db, job_id)
        if not job:
            raise NotFoundError("Job", str(job_id))
        
        SavedJobRepository.unsave_job(db, user_id, job_id)
    
    @staticmethod
    def get_saved_jobs(db: Session, user_id: int, skip: int = 0, limit: int = 100) -> List:
        """Get all saved jobs for a user"""
        return SavedJobRepository.get_saved_jobs(db, user_id, skip, limit)
    
    @staticmethod
    def get_saved_jobs_with_count(db: Session, user_id: int, skip: int = 0, limit: int = 100) -> tuple[List, int]:
        """Get all saved jobs for a user with total count"""
        return SavedJobRepository.get_saved_jobs_with_count(db, user_id, skip, limit)
    
    @staticmethod
    def is_job_saved(db: Session, user_id: int, job_id: int) -> bool:
        """Check if job is saved by user"""
        return SavedJobRepository.is_job_saved(db, user_id, job_id)
