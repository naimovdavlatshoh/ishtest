"""
Application service
"""
from sqlalchemy.orm import Session
from typing import List, Optional, Tuple
from app.repositories.application_repository import ApplicationRepository
from app.repositories.job_repository import JobRepository
from app.schemas.application_schema import ApplicationCreate, ApplicationUpdate
from app.exceptions.custom_exceptions import NotFoundError, ConflictError, ForbiddenError
from app.database.models import Conversation


class ApplicationService:
    """Service for application operations"""
    
    @staticmethod
    def get_application(db: Session, application_id: int):
        """Get application by ID"""
        application = ApplicationRepository.get_by_id(db, application_id)
        if not application:
            raise NotFoundError("Application", str(application_id))
        return application
    
    @staticmethod
    def get_job_applications(db: Session, job_id: int, user_id: int) -> List:
        """Get all applications for a job (only job author can see)"""
        job = JobRepository.get_by_id(db, job_id)
        if not job:
            raise NotFoundError("Job", str(job_id))
        
        if job.author_id != user_id:
            raise ForbiddenError("You can only view applications for your own jobs")
        
        return ApplicationRepository.get_by_job(db, job_id)
    
    @staticmethod
    def get_user_applications(db: Session, applicant_id: int) -> List:
        """Get all applications by applicant"""
        return ApplicationRepository.get_by_applicant(db, applicant_id)
    
    @staticmethod
    def create_application(db: Session, application_data: ApplicationCreate, applicant_id: int):
        """Create new application"""
        # Check if job exists
        job = JobRepository.get_by_id(db, application_data.job_id)
        if not job:
            raise NotFoundError("Job", str(application_data.job_id))
        
        # Check if job is active
        if job.status.value != "active":
            raise ConflictError("Cannot apply to inactive job")
        
        # Check if already applied
        existing = ApplicationRepository.get_by_job_and_applicant(
            db, application_data.job_id, applicant_id
        )
        if existing:
            raise ConflictError("You have already applied to this job")
        
        application_dict = application_data.model_dump()
        application_dict["applicant_id"] = applicant_id
        return ApplicationRepository.create(db, application_dict)
    
    @staticmethod
    def update_application(
        db: Session,
        application_id: int,
        update_data: ApplicationUpdate,
        user_id: int
    ) -> Tuple[any, Optional[Conversation]]:
        """
        Update application (only applicant or job author can update).
        Returns tuple of (application, conversation) where conversation is created
        when status changes to 'accepted'.
        """
        application = ApplicationService.get_application(db, application_id)
        
        # Check permissions
        job = JobRepository.get_by_id(db, application.job_id)
        if application.applicant_id != user_id and job.author_id != user_id:
            raise ForbiddenError("You can only update your own applications or applications to your jobs")
        
        update_dict = update_data.model_dump(exclude_unset=True)
        
        # Check if status is being changed to accepted
        conversation = None
        if update_dict.get("status") == "accepted" and application.status.value != "accepted":
            # Create conversation when application is accepted
            from app.services.chat_service import ChatService
            conversation = ChatService.create_conversation_for_application(
                db, application, job.author_id
            )
        
        updated_application = ApplicationRepository.update(db, application, update_dict)
        return updated_application, conversation
    
    @staticmethod
    def delete_application(db: Session, application_id: int, user_id: int):
        """Delete application"""
        application = ApplicationService.get_application(db, application_id)
        
        # Only applicant can delete
        if application.applicant_id != user_id:
            raise ForbiddenError("You can only delete your own applications")
        
        ApplicationRepository.delete(db, application)
