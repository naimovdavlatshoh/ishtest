"""
Profile routes - like LinkedIn, supports multiple capabilities simultaneously
"""
from fastapi import APIRouter, Depends, status, UploadFile, File, HTTPException
from pydantic import BaseModel, Field, ConfigDict
from sqlalchemy.orm import Session
import os
import shutil
from pathlib import Path
from app.database.session import get_db
from app.api.dependencies import get_current_active_user, get_current_user_optional
from app.schemas.profile_schema import ProfileCreate, ProfileUpdate, ProfileResponse
from app.services.profile_service import ProfileService
from app.database.models import User
from app.core.config import settings
from app.core.logger import setup_logger

logger = setup_logger()

router = APIRouter()


class OpenToWorkUpdate(BaseModel):
    """Schema for updating Open To Work status"""
    model_config = ConfigDict(populate_by_name=True)
    
    open_to_job_seeker: bool = Field(False, alias="openToJobSeeker", description="Set to True to show profile on Employees page")


@router.post("", response_model=ProfileResponse, status_code=status.HTTP_201_CREATED)
async def create_profile(
    profile_data: ProfileCreate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Create profile - all sections are optional, user can fill any combination"""
    return ProfileService.create_profile(db, profile_data, current_user.id)


@router.get("/me", response_model=ProfileResponse)
async def get_current_profile(
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Get current user's profile"""
    return ProfileService.get_profile_by_user_id(db, current_user.id)

@router.get("/me/dashboard-stats")
async def get_dashboard_stats(
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Get dashboard stats: profile views, jobs applied, connections, notifications. Returns camelCase for frontend."""
    stats = ProfileService.get_dashboard_stats(db, current_user.id)
    return {
        "profileViews": stats["profile_views"],
        "jobsApplied": stats["jobs_applied"],
        "connections": stats["connections"],
        "notifications": stats["notifications"],
    }


@router.get("/user/{user_id}", response_model=ProfileResponse)
async def get_profile_by_user_id(
    user_id: int,
    current_user: User = Depends(get_current_user_optional),
    db: Session = Depends(get_db)
):
    """Get profile by user ID (public endpoint). Increments profile views when viewed by another user."""
    viewer_id = current_user.id if current_user else None
    return ProfileService.get_profile_by_user_id(db, user_id, viewer_user_id=viewer_id)


@router.put("/me", response_model=ProfileResponse)
async def update_current_profile(
    update_data: ProfileUpdate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Update current user's profile - can update any section independently"""
    return ProfileService.update_profile(db, current_user.id, update_data)


@router.patch("/me/open-to-work", response_model=ProfileResponse)
async def update_open_to_work_status(
    status_data: OpenToWorkUpdate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """
    Update "Open To Work" status
    
    Set open_to_job_seeker = True to make your profile visible on the Employees page.
    Employers will be able to find you there.
    
    Page structure:
    - Jobs page: Shows job vacancies (GET /api/v1/jobs)
    - Employees page: Shows users with open_to_job_seeker = True (GET /api/v1/users/employees)
    """
    update_data = ProfileUpdate(
        open_to_job_seeker=status_data.open_to_job_seeker
    )
    return ProfileService.update_profile(db, current_user.id, update_data)


@router.post("/me/cv", response_model=ProfileResponse)
async def upload_cv(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """
    Upload CV file (PDF, DOC, DOCX)
    Max file size: 5MB
    If user already has a CV, the old file will be deleted.
    """
    # Get current profile to check for existing CV
    profile = ProfileService.get_profile_by_user_id(db, current_user.id)
    
    # Delete old CV file if exists
    if profile and profile.cv_file:
        old_file_path = Path(settings.UPLOAD_DIR) / profile.cv_file
        if old_file_path.exists():
            try:
                old_file_path.unlink()
            except Exception as e:
                logger.warning(f"Failed to delete old CV file: {e}")
    
    # Validate file type
    allowed_extensions = {'.pdf', '.doc', '.docx'}
    file_ext = Path(file.filename).suffix.lower()
    if file_ext not in allowed_extensions:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid file type. Allowed: {', '.join(allowed_extensions)}"
        )
    
    # Validate file size
    file_content = await file.read()
    if len(file_content) > settings.MAX_UPLOAD_SIZE:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"File too large. Max size: {settings.MAX_UPLOAD_SIZE / (1024 * 1024)}MB"
        )
    
    # Create upload directory if it doesn't exist
    upload_dir = Path(settings.UPLOAD_DIR) / "cvs"
    upload_dir.mkdir(parents=True, exist_ok=True)
    
    # Generate unique filename
    import time
    timestamp = int(time.time())
    safe_filename = "".join(c for c in Path(file.filename).stem if c.isalnum() or c in (' ', '-', '_'))[:20]
    filename = f"{current_user.id}_{timestamp}_{safe_filename}{file_ext}"
    file_path = upload_dir / filename
    
    # Save file
    with open(file_path, "wb") as buffer:
        buffer.write(file_content)
    
    # Update profile with CV file path
    relative_path = f"cvs/{filename}"
    update_data = ProfileUpdate(cv_file=relative_path)
    return ProfileService.update_profile(db, current_user.id, update_data)


@router.delete("/me/cv", response_model=ProfileResponse)
async def delete_cv(
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """
    Delete CV file
    Removes CV from profile and deletes the file from disk.
    """
    # Get current profile
    profile = ProfileService.get_profile_by_user_id(db, current_user.id)
    
    if not profile or not profile.cv_file:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No CV file found"
        )
    
    # Delete file from disk
    file_path = Path(settings.UPLOAD_DIR) / profile.cv_file
    if file_path.exists():
        try:
            file_path.unlink()
        except Exception as e:
            logger.warning(f"Failed to delete CV file: {e}")
    
    # Update profile to remove CV file path
    update_data = ProfileUpdate(cv_file=None)
    return ProfileService.update_profile(db, current_user.id, update_data)
