"""
Company schemas
"""
from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from app.database.models import CompanySize


class CompanyBase(BaseModel):
    """Base company schema"""
    name: str = Field(..., min_length=1, max_length=200)
    description: Optional[str] = None
    logo: Optional[str] = None
    website: Optional[str] = None
    location: str = Field(..., min_length=1, max_length=200)
    industry: Optional[str] = Field(None, max_length=100)
    size: Optional[CompanySize] = None


class CompanyCreate(CompanyBase):
    """Company creation schema"""
    owner_id: int


class CompanyUpdate(BaseModel):
    """Company update schema"""
    name: Optional[str] = Field(None, min_length=1, max_length=200)
    description: Optional[str] = None
    logo: Optional[str] = None
    website: Optional[str] = None
    location: Optional[str] = Field(None, min_length=1, max_length=200)
    industry: Optional[str] = Field(None, max_length=100)
    size: Optional[CompanySize] = None


class CompanyResponse(CompanyBase):
    """Company response schema"""
    id: int
    owner_id: int
    is_verified: bool
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


class CompanyMemberCreate(BaseModel):
    """Company member creation schema"""
    user_id: int
    role: str = "member"  # Default to member


class CompanyMemberResponse(BaseModel):
    """Company member response schema"""
    id: int
    company_id: int
    user_id: int
    role: str
    created_at: datetime
    user: Optional[dict] = None  # Will be populated with user info
    
    class Config:
        from_attributes = True
