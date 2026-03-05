"""
Application constants
"""
from app.database.models import (
    UserRole,
    JobType,
    JobStatus,
    ApplicationStatus,
    CompanySize,
)

# User roles
USER_ROLES = [role.value for role in UserRole]

# Job types
JOB_TYPES = [job_type.value for job_type in JobType]

# Job statuses
JOB_STATUSES = [status.value for status in JobStatus]

# Application statuses
APPLICATION_STATUSES = [status.value for status in ApplicationStatus]

# Company sizes
COMPANY_SIZES = [size.value for size in CompanySize]

# Uzbek cities
UZBEK_CITIES = [
    "Toshkent",
    "Samarqand",
    "Buxoro",
    "Xiva",
    "Andijon",
    "Farg'ona",
    "Namangan",
    "Qarshi",
    "Termiz",
    "Urganch",
    "Jizzax",
    "Guliston",
    "Navoiy",
    "Nukus",
]
