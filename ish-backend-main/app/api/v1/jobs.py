"""
Job routes
"""
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session
from typing import List, Optional
from app.database.session import get_db
from app.api.dependencies import get_current_active_user, get_current_user_optional
from app.schemas.job_schema import JobCreate, JobUpdate, JobResponse, PaginatedJobsResponse
from app.services.job_service import JobService
from app.services.saved_job_service import SavedJobService
from app.database.models import User

router = APIRouter()


@router.get("", response_model=PaginatedJobsResponse)
async def get_jobs(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    status: Optional[str] = None,
    skills: Optional[str] = Query(None, description="Comma-separated list of skills to filter by"),
    search: Optional[str] = Query(None, description="Search query for title, description, location, or company name"),
    job_type: Optional[str] = Query(None, description="Filter by job type (full-time, part-time, contract, internship, remote)"),
    location: Optional[str] = Query(None, description="Filter by location (partial match)"),
    salary_min: Optional[int] = Query(None, ge=0, description="Minimum salary filter"),
    salary_max: Optional[int] = Query(None, ge=0, description="Maximum salary filter"),
    is_remote: Optional[bool] = Query(None, description="Filter by remote work (true/false)"),
    date_from: Optional[str] = Query(None, description="Filter jobs created after this date (ISO format)"),
    db: Session = Depends(get_db)
):
    """
    Get all job vacancies with pagination
    
    This endpoint is used for the Jobs page.
    Returns paginated list of job postings/vacancies.
    
    Page structure:
    - Jobs page: Shows job vacancies (this endpoint)
    - Employees page: Shows users with open_to_job_seeker = True (GET /api/v1/users/employees)
    
    Filters:
    - status: Filter by job status (active, draft, closed)
    - skills: Comma-separated list of skills to search in job requirements
    - search: Search query for title, description, location, or company name
    - job_type: Filter by job type (full-time, part-time, contract, internship, remote)
    - location: Filter by location (partial match, case-insensitive)
    - salary_min: Minimum salary filter
    - salary_max: Maximum salary filter
    - is_remote: Filter by remote work (true/false)
    - date_from: Filter jobs created after this date (ISO format: YYYY-MM-DD)
    """
    skills_list = None
    if skills:
        # Parse comma-separated skills and strip whitespace
        skills_list = [skill.strip() for skill in skills.split(',') if skill.strip()]

    # Normalize enum params to lowercase (PostgreSQL enums are lowercase)
    status_normalized = status.strip().lower() if status and status.strip() else None
    job_type_normalized = job_type.strip().lower() if job_type and job_type.strip() else None

    jobs, total = JobService.get_jobs_with_count(
        db, skip, limit, status_normalized, None, skills_list, search,
        job_type_normalized, location, salary_min, salary_max, is_remote, date_from
    )
    
    return PaginatedJobsResponse(
        items=jobs,
        total=total,
        skip=skip,
        limit=limit
    )


@router.get("/my-jobs", response_model=PaginatedJobsResponse)
async def get_my_jobs(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    status: Optional[str] = None,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Get current user's jobs with pagination"""
    status_normalized = status.strip().lower() if status and status.strip() else None
    jobs, total = JobService.get_jobs_with_count(db, skip, limit, status_normalized, current_user.id)
    return PaginatedJobsResponse(
        items=jobs,
        total=total,
        skip=skip,
        limit=limit
    )


@router.get("/saved", response_model=PaginatedJobsResponse)
async def get_saved_jobs(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Get all saved jobs for current user with pagination"""
    jobs, total = SavedJobService.get_saved_jobs_with_count(db, current_user.id, skip, limit)
    return PaginatedJobsResponse(
        items=jobs,
        total=total,
        skip=skip,
        limit=limit
    )


@router.get("/{job_id}", response_model=JobResponse)
async def get_job(
    job_id: int,
    db: Session = Depends(get_db)
):
    """Get job by ID"""
    return JobService.get_job(db, job_id)


@router.post("/{job_id}/view", status_code=status.HTTP_204_NO_CONTENT)
async def increment_job_views(
    job_id: int,
    db: Session = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user_optional)
):
    """Increment job views count (only if user is not the job owner)"""
    job = JobService.get_job(db, job_id)
    
    # Don't increment views if current user is the job owner
    if current_user and job.author_id == current_user.id:
        return
    
    JobService.increment_views(db, job_id)


@router.post("", response_model=JobResponse, status_code=status.HTTP_201_CREATED)
async def create_job(
    job_data: JobCreate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Create new job"""
    return JobService.create_job(db, job_data, current_user.id)


@router.put("/{job_id}", response_model=JobResponse)
async def update_job(
    job_id: int,
    update_data: JobUpdate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Update job"""
    return JobService.update_job(db, job_id, update_data, current_user.id)


@router.delete("/{job_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_job(
    job_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Delete job"""
    JobService.delete_job(db, job_id, current_user.id)


@router.post("/{job_id}/save", status_code=status.HTTP_201_CREATED)
async def save_job(
    job_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Save a job for later"""
    SavedJobService.save_job(db, current_user.id, job_id)
    return {"message": "Job saved successfully"}


@router.delete("/{job_id}/save", status_code=status.HTTP_204_NO_CONTENT)
async def unsave_job(
    job_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Remove a saved job"""
    SavedJobService.unsave_job(db, current_user.id, job_id)


@router.get("/{job_id}/saved", response_model=dict)
async def check_job_saved(
    job_id: int,
    current_user: Optional[User] = Depends(get_current_user_optional),
    db: Session = Depends(get_db)
):
    """Check if job is saved by current user"""
    if not current_user:
        return {"saved": False}
    
    is_saved = SavedJobService.is_job_saved(db, current_user.id, job_id)
    return {"saved": is_saved}
