"""
Application routes
"""
from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from typing import List
from app.database.session import get_db
from app.api.dependencies import get_current_active_user
from app.schemas.application_schema import ApplicationCreate, ApplicationUpdate, ApplicationResponse, ApplicationUpdateResponse
from app.services.application_service import ApplicationService
from app.database.models import User

router = APIRouter()


@router.get("/my-applications", response_model=List[ApplicationResponse])
async def get_my_applications(
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Get current user's applications"""
    return ApplicationService.get_user_applications(db, current_user.id)


@router.get("/job/{job_id}", response_model=List[ApplicationResponse])
async def get_job_applications(
    job_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Get applications for a job (only job author can see)"""
    return ApplicationService.get_job_applications(db, job_id, current_user.id)


@router.get("/{application_id}", response_model=ApplicationResponse)
async def get_application(
    application_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Get application by ID"""
    return ApplicationService.get_application(db, application_id)


@router.post("", response_model=ApplicationResponse, status_code=status.HTTP_201_CREATED)
async def create_application(
    application_data: ApplicationCreate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Create new application"""
    return ApplicationService.create_application(db, application_data, current_user.id)


@router.put("/{application_id}", response_model=ApplicationUpdateResponse)
async def update_application(
    application_id: int,
    update_data: ApplicationUpdate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Update application. When status is changed to 'accepted', a conversation is created."""
    application, conversation = ApplicationService.update_application(
        db, application_id, update_data, current_user.id
    )
    
    # Build response with conversation_id if conversation was created
    response = ApplicationUpdateResponse.model_validate(application)
    if conversation:
        response.conversation_id = conversation.id
    
    return response


@router.delete("/{application_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_application(
    application_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Delete application"""
    ApplicationService.delete_application(db, application_id, current_user.id)
