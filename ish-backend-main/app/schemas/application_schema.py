"""
Application schemas
"""
from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from app.database.models import ApplicationStatus
from app.schemas.user_schema import UserResponse
from app.schemas.job_schema import JobResponse


class ApplicationBase(BaseModel):
    """Base application schema"""
    cover_letter: Optional[str] = None


class ApplicationCreate(ApplicationBase):
    """Application creation schema"""
    job_id: int


class ApplicationUpdate(BaseModel):
    """Application update schema"""
    cover_letter: Optional[str] = None
    status: Optional[ApplicationStatus] = None


class ApplicationResponse(ApplicationBase):
    """Application response schema"""
    id: int
    job_id: int
    applicant_id: int
    status: ApplicationStatus
    created_at: datetime
    updated_at: datetime
    applicant: Optional[UserResponse] = None
    job: Optional[JobResponse] = None
    conversation_id: Optional[int] = None
    
    class Config:
        from_attributes = True


class ApplicationUpdateResponse(ApplicationResponse):
    """Application update response - includes conversation_id when created"""
    conversation_id: Optional[int] = None
