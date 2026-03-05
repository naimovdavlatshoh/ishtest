"""
Profile schemas - like LinkedIn, supports multiple capabilities simultaneously
"""
from pydantic import BaseModel, Field, ConfigDict
from typing import Optional, List, Dict, Any
from datetime import datetime


# ===== Helper Schemas =====

class EmployerInfo(BaseModel):
    """Employer information (quick info, companies stored separately)"""
    model_config = ConfigDict(populate_by_name=True)
    
    business_type: Optional[str] = Field(None, max_length=100, alias="businessType", description="Type of business")
    needed_employees: Optional[str] = Field(None, alias="neededEmployees", description="Description of needed employees")


class FreelancerInfo(BaseModel):
    """Freelancer information"""
    model_config = ConfigDict(populate_by_name=True)
    
    services: Optional[List[str]] = Field(None, description="List of services provided")
    portfolio: Optional[List[Dict[str, Any]]] = Field(None, description="Portfolio items")
    prices: Optional[Dict[str, Any]] = Field(None, description="Pricing information")
    previous_works: Optional[List[Dict[str, Any]]] = Field(None, alias="previousWorks", description="Previous work examples")


# ===== Main Profile Schemas =====

class ProfileBase(BaseModel):
    """Base profile schema - common fields"""
    model_config = ConfigDict(populate_by_name=True)
    
    full_name: str = Field(..., min_length=1, max_length=200, alias="fullName")
    city: str = Field(..., min_length=1, max_length=100)
    bio: Optional[str] = None
    title: Optional[str] = Field(None, max_length=200, description="Job title or professional title")


class ProfileCreate(ProfileBase):
    """Profile creation schema - all sections are optional"""
    model_config = ConfigDict(populate_by_name=True)
    
    # Job Seeker section (Ish qidiruvchi)
    skills: Optional[List[str]] = Field(None, description="List of skills")
    experience: Optional[List[Dict[str, Any]]] = Field(None, description="List of work experience")
    education: Optional[List[Dict[str, Any]]] = Field(None, description="List of education")
    cv_file: Optional[str] = Field(None, description="Path to uploaded CV file", alias="cvFile")
    
    # Employer section (Ish beruvchi)
    employer_info: Optional[EmployerInfo] = Field(None, description="Employer information", alias="employerInfo")
    
    # Freelancer section
    freelancer_info: Optional[FreelancerInfo] = Field(None, description="Freelancer information", alias="freelancerInfo")


class ProfileUpdate(BaseModel):
    """Profile update schema - all fields optional"""
    model_config = ConfigDict(populate_by_name=True)
    
    full_name: Optional[str] = Field(None, min_length=1, max_length=200, alias="fullName")
    city: Optional[str] = Field(None, min_length=1, max_length=100)
    bio: Optional[str] = None
    title: Optional[str] = Field(None, max_length=200)
    
    # Job Seeker section
    skills: Optional[List[str]] = None
    experience: Optional[List[Dict[str, Any]]] = None
    education: Optional[List[Dict[str, Any]]] = None
    cv_file: Optional[str] = Field(None, alias="cvFile")
    
    # Employer section
    employer_info: Optional[EmployerInfo] = Field(None, alias="employerInfo")
    
    # Freelancer section
    freelancer_info: Optional[FreelancerInfo] = Field(None, alias="freelancerInfo")
    
    # "Open To Work" status flags
    open_to_job_seeker: Optional[bool] = Field(
        None, 
        alias="openToJobSeeker",
        description="I'm looking for work - Show my profile on Employees page so employers can find me"
    )
    open_to_employer: Optional[bool] = Field(
        None,
        alias="openToEmployer",
        description="Reserved for future use"
    )


class ProfileResponse(ProfileBase):
    """Profile response schema"""
    model_config = ConfigDict(populate_by_name=True, from_attributes=True)
    
    id: int
    user_id: int = Field(alias="userId")
    avatar: Optional[str] = None
    
    # Job Seeker section
    skills: Optional[List[str]] = None
    experience: Optional[List[Dict[str, Any]]] = None
    education: Optional[List[Dict[str, Any]]] = None
    cv_file: Optional[str] = Field(None, alias="cvFile")
    
    # Employer section
    employer_info: Optional[Dict[str, Any]] = Field(None, alias="employerInfo")
    
    # Freelancer section
    freelancer_info: Optional[Dict[str, Any]] = Field(None, alias="freelancerInfo")
    
    # Completion flags
    job_seeker_complete: bool = Field(False, alias="jobSeekerComplete")
    employer_complete: bool = Field(False, alias="employerComplete")
    freelancer_complete: bool = Field(False, alias="freelancerComplete")
    is_complete: bool = Field(False, alias="isComplete")
    
    # "Open To Work" status flags
    open_to_job_seeker: bool = Field(False, alias="openToJobSeeker")
    open_to_employer: bool = Field(False, alias="openToEmployer")
    
    created_at: datetime = Field(alias="createdAt")
    updated_at: datetime = Field(alias="updatedAt")


class DashboardStatsResponse(BaseModel):
    """Dashboard stats for the current user"""
    model_config = ConfigDict(populate_by_name=True)

    profile_views: int = Field(alias="profileViews")
    jobs_applied: int = Field(alias="jobsApplied")
    connections: int = 0
    notifications: int = 0
