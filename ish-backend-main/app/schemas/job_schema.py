"""
Job schemas
"""
from pydantic import BaseModel, Field, field_validator
from typing import Optional, List, Any
from datetime import datetime

from app.database.models import JobType, JobStatus
from app.schemas.company_schema import CompanyResponse
from app.schemas.user_schema import UserResponse

def _salary_from_string(s: str) -> Optional[int]:
    """Parse salary from string; allow thousand separators (e.g. 2.500.000)."""
    cleaned = s.strip().replace(" ", "").replace(".", "").replace(",", "")
    if not cleaned:
        return None
    if not cleaned.isdigit():
        raise ValueError(
            "Salary must be a non-negative integer or a string with separators (e.g. 2.500.000)"
        )
    return int(cleaned)


def _parse_salary(value: Any) -> Optional[int]:
    """
    Coerce input to optional non-negative integer for salary_min/salary_max.

    Accepts: None, int, whole float (e.g. 2500000.0), or string with thousand
    separators (e.g. "2.500.000", "2 500 000"). Rejects negative values and
    fractional floats.
    """
    if value is None:
        return None
    if isinstance(value, bool):
        raise ValueError("Salary must be a number or string, not boolean")
    if isinstance(value, int):
        if value < 0:
            raise ValueError("Salary must be non-negative")
        return value
    if isinstance(value, float):
        if value != value:
            raise ValueError("Salary cannot be NaN")
        if value < 0:
            raise ValueError("Salary must be non-negative")
        if not value.is_integer():
            raise ValueError(
                "Salary must be a whole number (e.g. 2500000 or string 2.500.000)"
            )
        return int(value)
    if isinstance(value, str):
        return _salary_from_string(value)
    raise ValueError("Salary must be an integer or a string (e.g. 2.500.000)")


def _normalize_job_type(value: Any) -> Any:
    """Accept job_type as enum or string (e.g. 'full-time', 'FULL_TIME', 'Full-Time')."""
    if value is None or isinstance(value, JobType):
        return value
    if isinstance(value, str):
        normalized = value.strip().lower().replace("-", "").replace("_", "")
        for member in JobType:
            if member.value.lower().replace("-", "") == normalized:
                return member
            if member.name.lower() == normalized:
                return member
    return value


class JobBase(BaseModel):
    """Base job schema"""
    title: str = Field(..., min_length=1, max_length=200)
    description: str = Field(..., min_length=1)
    location: str = Field(..., min_length=1, max_length=200)
    salary_min: Optional[int] = None
    salary_max: Optional[int] = None
    salary_currency: str = Field(default="UZS", max_length=10)
    job_type: JobType
    requirements: Optional[List[str]] = None
    is_remote: bool = False

    @field_validator("salary_min", "salary_max", mode="before")
    @classmethod
    def parse_salary(cls, value: Any) -> Optional[int]:
        return _parse_salary(value)

    @field_validator("job_type", mode="before")
    @classmethod
    def normalize_job_type(cls, value: Any) -> Any:
        return _normalize_job_type(value)


class JobCreate(JobBase):
    """Job creation schema"""
    company_id: Optional[int] = None


class JobUpdate(BaseModel):
    """Job update schema"""
    title: Optional[str] = Field(None, min_length=1, max_length=200)
    description: Optional[str] = Field(None, min_length=1)
    location: Optional[str] = Field(None, min_length=1, max_length=200)
    salary_min: Optional[int] = None
    salary_max: Optional[int] = None
    salary_currency: Optional[str] = Field(None, max_length=10)
    job_type: Optional[JobType] = None
    status: Optional[JobStatus] = None
    requirements: Optional[List[str]] = None
    is_remote: Optional[bool] = None

    @field_validator("salary_min", "salary_max", mode="before")
    @classmethod
    def parse_salary(cls, value: Any) -> Optional[int]:
        return _parse_salary(value)

    @field_validator("job_type", mode="before")
    @classmethod
    def normalize_job_type(cls, value: Any) -> Any:
        return _normalize_job_type(value)


class JobResponse(JobBase):
    """Job response schema"""
    id: int
    author_id: int
    company_id: Optional[int] = None
    status: JobStatus
    views_count: int
    created_at: datetime
    updated_at: datetime
    company: Optional[CompanyResponse] = None
    author: Optional[UserResponse] = None
    
    class Config:
        from_attributes = True


class PaginatedJobsResponse(BaseModel):
    """Paginated jobs response schema"""
    items: List[JobResponse]
    total: int
    skip: int
    limit: int
