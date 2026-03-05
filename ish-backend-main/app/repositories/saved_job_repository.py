"""
Saved job repository
"""
from sqlalchemy.orm import Session
from typing import Optional, List
from app.database.models import SavedJob, Job


class SavedJobRepository:
    """Repository for saved job operations"""
    
    @staticmethod
    def get_by_user_and_job(db: Session, user_id: int, job_id: int) -> Optional[SavedJob]:
        """Check if user has saved this job"""
        return db.query(SavedJob).filter(
            SavedJob.user_id == user_id,
            SavedJob.job_id == job_id
        ).first()
    
    @staticmethod
    def save_job(db: Session, user_id: int, job_id: int) -> SavedJob:
        """Save a job for a user"""
        saved_job = SavedJob(user_id=user_id, job_id=job_id)
        db.add(saved_job)
        db.commit()
        db.refresh(saved_job)
        return saved_job
    
    @staticmethod
    def unsave_job(db: Session, user_id: int, job_id: int) -> None:
        """Remove a saved job"""
        saved_job = SavedJobRepository.get_by_user_and_job(db, user_id, job_id)
        if saved_job:
            db.delete(saved_job)
            db.commit()
    
    @staticmethod
    def get_saved_jobs(db: Session, user_id: int, skip: int = 0, limit: int = 100) -> List[Job]:
        """Get all saved jobs for a user (newest saved first)"""
        return db.query(Job).join(
            SavedJob, Job.id == SavedJob.job_id
        ).filter(
            SavedJob.user_id == user_id
        ).order_by(SavedJob.created_at.desc()).offset(skip).limit(limit).all()
    
    @staticmethod
    def get_saved_jobs_with_count(db: Session, user_id: int, skip: int = 0, limit: int = 100) -> tuple[List[Job], int]:
        """Get all saved jobs for a user with total count"""
        query = db.query(Job).join(
            SavedJob, Job.id == SavedJob.job_id
        ).filter(
            SavedJob.user_id == user_id
        )
        
        total = query.count()
        jobs = query.order_by(SavedJob.created_at.desc()).offset(skip).limit(limit).all()
        
        return jobs, total
    
    @staticmethod
    def is_job_saved(db: Session, user_id: int, job_id: int) -> bool:
        """Check if job is saved by user"""
        saved_job = SavedJobRepository.get_by_user_and_job(db, user_id, job_id)
        return saved_job is not None
