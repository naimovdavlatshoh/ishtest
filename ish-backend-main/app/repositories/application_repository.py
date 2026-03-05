"""
Application repository
"""
from sqlalchemy.orm import Session, joinedload
from typing import Optional, List
from app.database.models import Application, Job


class ApplicationRepository:
    """Repository for application operations"""
    
    @staticmethod
    def get_by_id(db: Session, application_id: int) -> Optional[Application]:
        """Get application by ID"""
        return db.query(Application).options(
            joinedload(Application.applicant),
            joinedload(Application.job).joinedload(Job.company)
        ).filter(Application.id == application_id).first()
    
    @staticmethod
    def get_by_job(db: Session, job_id: int) -> List[Application]:
        """Get all applications for a job"""
        return db.query(Application).options(
            joinedload(Application.applicant),
            joinedload(Application.job).joinedload(Job.company)
        ).filter(Application.job_id == job_id).all()
    
    @staticmethod
    def get_by_applicant(db: Session, applicant_id: int) -> List[Application]:
        """Get all applications by applicant"""
        return db.query(Application).options(
            joinedload(Application.job).joinedload(Job.company)
        ).filter(Application.applicant_id == applicant_id).all()

    @staticmethod
    def count_by_applicant(db: Session, applicant_id: int) -> int:
        """Count applications by applicant"""
        return db.query(Application).filter(Application.applicant_id == applicant_id).count()
    
    @staticmethod
    def get_by_job_and_applicant(
        db: Session,
        job_id: int,
        applicant_id: int
    ) -> Optional[Application]:
        """Get application by job and applicant"""
        return db.query(Application).filter(
            Application.job_id == job_id,
            Application.applicant_id == applicant_id
        ).first()
    
    @staticmethod
    def create(db: Session, application_data: dict) -> Application:
        """Create new application"""
        application = Application(**application_data)
        db.add(application)
        db.commit()
        db.refresh(application)
        return application
    
    @staticmethod
    def update(db: Session, application: Application, update_data: dict) -> Application:
        """Update application"""
        for key, value in update_data.items():
            setattr(application, key, value)
        
        db.commit()
        db.refresh(application)
        return application
    
    @staticmethod
    def delete(db: Session, application: Application) -> None:
        """Delete application"""
        db.delete(application)
        db.commit()
