"""
User routes
"""
import time
from pathlib import Path
from fastapi import APIRouter, Depends, File, Query, status, UploadFile, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from app.core.config import settings
from app.core.logger import setup_logger
from app.database.session import get_db
from app.api.dependencies import get_current_active_user, get_current_user_optional
from app.schemas.user_schema import UserResponse, UserUpdate, PaginatedUsersResponse
from app.services.user_service import UserService
from app.database.models import User

router = APIRouter()
logger = setup_logger()


@router.get("/me", response_model=UserResponse)
async def get_current_user(
    current_user: User = Depends(get_current_active_user)
):
    """Get current user"""
    return current_user


@router.put("/me", response_model=UserResponse)
async def update_current_user(
    update_data: UserUpdate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Update current user"""
    return UserService.update_user(db, current_user.id, update_data)


ALLOWED_AVATAR_EXTENSIONS = {".jpg", ".jpeg", ".png", ".gif", ".webp"}


@router.post("/me/avatar", response_model=UserResponse)
async def upload_avatar(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """
    Upload avatar image (JPG, PNG, GIF, WEBP). Max 5MB.
    Replaces existing avatar if present.
    """
    file_ext = Path(file.filename or "").suffix.lower()
    if file_ext not in ALLOWED_AVATAR_EXTENSIONS:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid file type. Allowed: {', '.join(ALLOWED_AVATAR_EXTENSIONS)}"
        )
    content = await file.read()
    if len(content) > settings.MAX_UPLOAD_SIZE:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"File too large. Max size: {settings.MAX_UPLOAD_SIZE / (1024 * 1024):.0f}MB"
        )
    upload_dir = Path(settings.UPLOAD_DIR) / "avatars"
    upload_dir.mkdir(parents=True, exist_ok=True)
    if current_user.avatar:
        old_path = Path(settings.UPLOAD_DIR) / current_user.avatar
        if old_path.exists():
            try:
                old_path.unlink()
            except Exception as e:
                logger.warning("Failed to delete old avatar: %s", e)
    timestamp = int(time.time())
    filename = f"{current_user.id}_{timestamp}{file_ext}"
    file_path = upload_dir / filename
    file_path.write_bytes(content)
    relative_path = f"avatars/{filename}"
    return UserService.update_user(db, current_user.id, UserUpdate(avatar=relative_path))


@router.delete("/me/avatar", response_model=UserResponse)
async def delete_avatar(
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Remove current user's avatar."""
    if not current_user.avatar:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="No avatar found")
    avatar_path = Path(settings.UPLOAD_DIR) / current_user.avatar
    if avatar_path.exists():
        try:
            avatar_path.unlink()
        except Exception as e:
            logger.warning("Failed to delete avatar file: %s", e)
    return UserService.update_user(db, current_user.id, UserUpdate(avatar=None))


@router.get("/employees", response_model=PaginatedUsersResponse)
async def get_employees(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    skills: Optional[str] = Query(None, description="Comma-separated list of skills to filter by"),
    db: Session = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user_optional)
):
    """
    Get users who are "Open To Work" (looking for jobs) with pagination
    
    Returns users who have set open_to_job_seeker = True.
    These users will be displayed on the Employees page.
    Current user is excluded from the list.
    
    Page structure:
    - Jobs page: Shows job vacancies (GET /api/v1/jobs)
    - Employees page: Shows users with open_to_job_seeker = True (this endpoint)
    
    Filters:
    - skills: Comma-separated list of skills to search in user profiles
    """
    exclude_user_id = current_user.id if current_user else None
    
    skills_list = None
    if skills:
        # Parse comma-separated skills and strip whitespace
        skills_list = [skill.strip() for skill in skills.split(',') if skill.strip()]
    
    users, total = UserService.get_job_seekers_with_count(db, skip, limit, exclude_user_id, skills_list)
    return PaginatedUsersResponse(
        items=users,
        total=total,
        skip=skip,
        limit=limit
    )


