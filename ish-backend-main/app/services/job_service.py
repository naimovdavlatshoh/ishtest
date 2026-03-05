"""
Job service
"""
from sqlalchemy.orm import Session
from typing import List
from app.repositories.job_repository import JobRepository
from app.services.company_service import CompanyService
from app.schemas.job_schema import JobCreate, JobUpdate
from app.exceptions.custom_exceptions import NotFoundError, ForbiddenError


class JobService:
    """Service for job operations"""
    
    @staticmethod
    def get_job(db: Session, job_id: int):
        """Get job by ID"""
        job = JobRepository.get_by_id(db, job_id)
        if not job:
            raise NotFoundError("Job", str(job_id))
        return job
    
    @staticmethod
    def get_jobs(
        db: Session,
        skip: int = 0,
        limit: int = 100,
        status: str = None,
        author_id: int = None,
        skills: List[str] = None,
        search: str = None,
        job_type: str = None,
        location: str = None,
        salary_min: int = None,
        salary_max: int = None,
        is_remote: bool = None,
        date_from: str = None
    ) -> List:
        """Get all jobs with filters"""
        return JobRepository.get_all(
            db, skip, limit, status, author_id, skills, search,
            job_type, location, salary_min, salary_max, is_remote, date_from
        )
    
    @staticmethod
    def get_jobs_with_count(
        db: Session,
        skip: int = 0,
        limit: int = 100,
        status: str = None,
        author_id: int = None,
        skills: List[str] = None,
        search: str = None,
        job_type: str = None,
        location: str = None,
        salary_min: int = None,
        salary_max: int = None,
        is_remote: bool = None,
        date_from: str = None
    ) -> tuple[List, int]:
        """Get jobs with total count"""
        return JobRepository.get_all_with_count(
            db, skip, limit, status, author_id, skills, search,
            job_type, location, salary_min, salary_max, is_remote, date_from
        )
    
    @staticmethod
    def create_job(db: Session, job_data: JobCreate, author_id: int):
        """Create new job"""
        # If company_id is provided, check if user has permission to post jobs for this company
        if job_data.company_id:
            if not CompanyService.can_user_post_job(db, job_data.company_id, author_id):
                raise ForbiddenError("You don't have permission to post jobs for this company")
        
        job_dict = job_data.model_dump()
        job_dict["author_id"] = author_id
        return JobRepository.create(db, job_dict)
    
    @staticmethod
    def update_job(db: Session, job_id: int, update_data: JobUpdate, user_id: int):
        """Update job"""
        job = JobService.get_job(db, job_id)
        
        # Check if user is the author
        if job.author_id != user_id:
            raise ForbiddenError("You can only update your own jobs")
        
        update_dict = update_data.model_dump(exclude_unset=True)
        return JobRepository.update(db, job, update_dict)
    
    @staticmethod
    def delete_job(db: Session, job_id: int, user_id: int):
        """Delete job"""
        job = JobService.get_job(db, job_id)
        
        # Check if user is the author
        if job.author_id != user_id:
            raise ForbiddenError("You can only delete your own jobs")
        
        JobRepository.delete(db, job)
    
    @staticmethod
    def increment_views(db: Session, job_id: int):
        """Increment job views"""
        job = JobService.get_job(db, job_id)
        return JobRepository.increment_views(db, job)
