"""
Job repository
"""
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import or_, and_, text
from typing import Optional, List
from app.database.models import Job, JobStatus, JobType


class JobRepository:
    """Repository for job operations"""
    
    @staticmethod
    def get_by_id(db: Session, job_id: int) -> Optional[Job]:
        """Get job by ID"""
        return db.query(Job).options(
            joinedload(Job.company),
            joinedload(Job.author)
        ).filter(Job.id == job_id).first()
    
    @staticmethod
    def get_all(
        db: Session,
        skip: int = 0,
        limit: int = 100,
        status: str = None,
        author_id: int = None,
        skills: Optional[List[str]] = None,
        search: Optional[str] = None,
        job_type: Optional[str] = None,
        location: Optional[str] = None,
        salary_min: Optional[int] = None,
        salary_max: Optional[int] = None,
        is_remote: Optional[bool] = None,
        date_from: Optional[str] = None
    ) -> List[Job]:
        """Get all jobs with filters"""
        from sqlalchemy import func
        from app.database.models import Company
        from datetime import datetime

        # Normalize enum params to lowercase (PostgreSQL enums are lowercase)
        status_val = status.strip().lower() if status and isinstance(status, str) and status.strip() else None
        job_type_val = job_type.strip().lower() if job_type and isinstance(job_type, str) and job_type.strip() else None
        
        query = db.query(Job)
        
        # Join with Company for search
        if search:
            query = query.outerjoin(Company, Job.company_id == Company.id)
        
        if status_val:
            try:
                query = query.filter(Job.status == JobStatus(status_val))
            except ValueError:
                pass
        if author_id:
            query = query.filter(Job.author_id == author_id)
        
        # Search filter (title, description, location, company name)
        if search and search.strip():
            search_term = f"%{search.strip()}%"
            search_conditions = or_(
                Job.title.ilike(search_term),
                Job.description.ilike(search_term),
                Job.location.ilike(search_term),
                Company.name.ilike(search_term)
            )
            query = query.filter(search_conditions)
        
        # Filter by job type
        if job_type_val:
            try:
                query = query.filter(Job.job_type == JobType(job_type_val))
            except ValueError:
                pass
        
        # Filter by location
        if location and location.strip():
            location_term = f"%{location.strip()}%"
            query = query.filter(Job.location.ilike(location_term))
        
        # Filter by salary range
        # Job salary range overlaps with filter range
        if salary_min is not None or salary_max is not None:
            salary_conditions = []
            
            # If both min and max are specified, check overlap
            if salary_min is not None and salary_max is not None:
                # Job salary overlaps if ranges intersect
                # Case 1: Job has both min and max
                salary_conditions.append(
                    and_(
                        Job.salary_min.isnot(None),
                        Job.salary_max.isnot(None),
                        Job.salary_min <= salary_max,
                        Job.salary_max >= salary_min
                    )
                )
                # Case 2: Job has only min (no max limit)
                salary_conditions.append(
                    and_(
                        Job.salary_min.isnot(None),
                        Job.salary_max.is_(None),
                        Job.salary_min <= salary_max
                    )
                )
                # Case 3: Job has only max (no min limit)
                salary_conditions.append(
                    and_(
                        Job.salary_min.is_(None),
                        Job.salary_max.isnot(None),
                        Job.salary_max >= salary_min
                    )
                )
            elif salary_min is not None:
                # Only min specified: job should have max >= min OR min >= min
                salary_conditions.append(
                    or_(
                        and_(Job.salary_max.isnot(None), Job.salary_max >= salary_min),
                        and_(Job.salary_min.isnot(None), Job.salary_min >= salary_min)
                    )
                )
            elif salary_max is not None:
                # Only max specified: job should have min <= max OR max <= max
                salary_conditions.append(
                    or_(
                        and_(Job.salary_min.isnot(None), Job.salary_min <= salary_max),
                        and_(Job.salary_max.isnot(None), Job.salary_max <= salary_max)
                    )
                )
            
            if salary_conditions:
                query = query.filter(or_(*salary_conditions))
        
        # Filter by remote work
        if is_remote is not None:
            query = query.filter(Job.is_remote == is_remote)
        
        # Filter by date (jobs created after date_from)
        if date_from:
            try:
                date_obj = datetime.fromisoformat(date_from.replace('Z', '+00:00'))
                query = query.filter(Job.created_at >= date_obj)
            except (ValueError, AttributeError):
                pass  # Invalid date format, skip filter
        
        # Filter by skills (search in requirements JSONB array)
        if skills and len(skills) > 0:
            # Filter jobs where requirements array contains at least one of the specified skills
            # Using PostgreSQL JSONB array functions for case-insensitive matching
            from sqlalchemy import text
            
            conditions = []
            for idx, skill in enumerate(skills):
                # Check if any element in requirements array contains the skill (case-insensitive)
                # Using jsonb_array_elements_text to extract array elements
                # Use unique parameter name for each skill to avoid conflicts
                param_name = f"skill_{idx}"
                condition = text(
                    f"EXISTS (SELECT 1 FROM jsonb_array_elements_text(jobs.requirements) AS elem WHERE LOWER(elem::text) LIKE LOWER('%' || :{param_name} || '%'))"
                ).bindparams(**{param_name: skill})
                conditions.append(condition)
            
            if conditions:
                # At least one skill must match
                query = query.filter(or_(*conditions))
        
        # Newest first
        query = query.order_by(Job.created_at.desc())
        # Eager load company and author relationships
        query = query.options(
            joinedload(Job.company),
            joinedload(Job.author)
        )
        
        return query.offset(skip).limit(limit).all()
    
    @staticmethod
    def get_all_with_count(
        db: Session,
        skip: int = 0,
        limit: int = 100,
        status: str = None,
        author_id: int = None,
        skills: Optional[List[str]] = None,
        search: Optional[str] = None,
        job_type: Optional[str] = None,
        location: Optional[str] = None,
        salary_min: Optional[int] = None,
        salary_max: Optional[int] = None,
        is_remote: Optional[bool] = None,
        date_from: Optional[str] = None
    ) -> tuple[List[Job], int]:
        """Get all jobs with filters and total count"""
        from sqlalchemy import func
        from app.database.models import Company
        from datetime import datetime

        # Normalize enum params to lowercase (PostgreSQL enums are lowercase)
        status_val = status.strip().lower() if status and isinstance(status, str) and status.strip() else None
        job_type_val = job_type.strip().lower() if job_type and isinstance(job_type, str) and job_type.strip() else None

        query = db.query(Job)
        
        # Join with Company for search
        if search:
            query = query.outerjoin(Company, Job.company_id == Company.id)
        
        if status_val:
            try:
                query = query.filter(Job.status == JobStatus(status_val))
            except ValueError:
                pass
        if author_id:
            query = query.filter(Job.author_id == author_id)
        
        # Search filter (title, description, location, company name)
        if search and search.strip():
            search_term = f"%{search.strip()}%"
            search_conditions = or_(
                Job.title.ilike(search_term),
                Job.description.ilike(search_term),
                Job.location.ilike(search_term),
                Company.name.ilike(search_term)
            )
            query = query.filter(search_conditions)
        
        # Filter by job type
        if job_type_val:
            try:
                query = query.filter(Job.job_type == JobType(job_type_val))
            except ValueError:
                pass
        
        # Filter by location
        if location and location.strip():
            location_term = f"%{location.strip()}%"
            query = query.filter(Job.location.ilike(location_term))
        
        # Filter by salary range
        if salary_min is not None or salary_max is not None:
            salary_conditions = []
            
            if salary_min is not None and salary_max is not None:
                salary_conditions.append(
                    and_(
                        Job.salary_min.isnot(None),
                        Job.salary_max.isnot(None),
                        Job.salary_min <= salary_max,
                        Job.salary_max >= salary_min
                    )
                )
                salary_conditions.append(
                    and_(
                        Job.salary_min.isnot(None),
                        Job.salary_max.is_(None),
                        Job.salary_min <= salary_max
                    )
                )
                salary_conditions.append(
                    and_(
                        Job.salary_min.is_(None),
                        Job.salary_max.isnot(None),
                        Job.salary_max >= salary_min
                    )
                )
            elif salary_min is not None:
                salary_conditions.append(
                    or_(
                        and_(Job.salary_max.isnot(None), Job.salary_max >= salary_min),
                        and_(Job.salary_min.isnot(None), Job.salary_min >= salary_min)
                    )
                )
            elif salary_max is not None:
                salary_conditions.append(
                    or_(
                        and_(Job.salary_min.isnot(None), Job.salary_min <= salary_max),
                        and_(Job.salary_max.isnot(None), Job.salary_max <= salary_max)
                    )
                )
            
            if salary_conditions:
                query = query.filter(or_(*salary_conditions))
        
        # Filter by remote work
        if is_remote is not None:
            query = query.filter(Job.is_remote == is_remote)
        
        # Filter by date
        if date_from:
            try:
                date_obj = datetime.fromisoformat(date_from.replace('Z', '+00:00'))
                query = query.filter(Job.created_at >= date_obj)
            except (ValueError, AttributeError):
                pass
        
        # Filter by skills
        if skills and len(skills) > 0:
            from sqlalchemy import text
            
            conditions = []
            for idx, skill in enumerate(skills):
                param_name = f"skill_{idx}"
                condition = text(
                    f"EXISTS (SELECT 1 FROM jsonb_array_elements_text(jobs.requirements) AS elem WHERE LOWER(elem::text) LIKE LOWER('%' || :{param_name} || '%'))"
                ).bindparams(**{param_name: skill})
                conditions.append(condition)
            
            if conditions:
                query = query.filter(or_(*conditions))
        
        # Get total count before pagination
        total = query.count()
        
        # Newest first
        query = query.order_by(Job.created_at.desc())
        # Eager load company and author relationships
        query = query.options(
            joinedload(Job.company),
            joinedload(Job.author)
        )
        
        # Apply pagination
        jobs = query.offset(skip).limit(limit).all()
        
        return jobs, total
    
    @staticmethod
    def create(db: Session, job_data: dict) -> Job:
        """Create new job"""
        job = Job(**job_data)
        db.add(job)
        db.commit()
        db.refresh(job)
        return job
    
    @staticmethod
    def update(db: Session, job: Job, update_data: dict) -> Job:
        """Update job"""
        for key, value in update_data.items():
            setattr(job, key, value)
        
        db.commit()
        db.refresh(job)
        return job
    
    @staticmethod
    def delete(db: Session, job: Job) -> None:
        """Delete job"""
        db.delete(job)
        db.commit()
    
    @staticmethod
    def increment_views(db: Session, job: Job) -> Job:
        """Increment job views count"""
        job.views_count += 1
        db.commit()
        db.refresh(job)
        return job
