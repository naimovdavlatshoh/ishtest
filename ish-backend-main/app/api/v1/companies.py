"""
Company routes
"""
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session
from typing import List
from app.database.session import get_db
from app.api.dependencies import get_current_active_user
from app.schemas.company_schema import CompanyCreate, CompanyUpdate, CompanyResponse
from app.services.company_service import CompanyService
from app.database.models import User

router = APIRouter()


@router.get("", response_model=List[CompanyResponse])
async def get_companies(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=100),
    db: Session = Depends(get_db)
):
    """Get all companies"""
    return CompanyService.get_companies(db, skip, limit)


@router.get("/my-companies", response_model=List[CompanyResponse])
async def get_my_companies(
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Get current user's companies"""
    return CompanyService.get_user_companies(db, current_user.id)


@router.get("/{company_id}", response_model=CompanyResponse)
async def get_company(
    company_id: int,
    db: Session = Depends(get_db)
):
    """Get company by ID"""
    return CompanyService.get_company(db, company_id)


@router.post("", response_model=CompanyResponse, status_code=status.HTTP_201_CREATED)
async def create_company(
    company_data: CompanyCreate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Create new company"""
    # Ensure owner_id matches current user
    if company_data.owner_id != current_user.id:
        company_data.owner_id = current_user.id
    
    return CompanyService.create_company(db, company_data, current_user.id)


@router.put("/{company_id}", response_model=CompanyResponse)
async def update_company(
    company_id: int,
    update_data: CompanyUpdate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Update company"""
    return CompanyService.update_company(db, company_id, update_data, current_user.id)


@router.delete("/{company_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_company(
    company_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Delete company"""
    CompanyService.delete_company(db, company_id, current_user.id)


# Company Members endpoints
@router.post("/{company_id}/members", response_model=dict, status_code=status.HTTP_201_CREATED)
async def add_company_member(
    company_id: int,
    member_data: dict,  # {user_id: int, role: str}
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Add user to company (only owner can add members)"""
    user_id = member_data.get("user_id")
    role = member_data.get("role", "member")
    
    if not user_id:
        from fastapi import HTTPException
        raise HTTPException(status_code=400, detail="user_id is required")
    
    member = CompanyService.add_member(db, company_id, user_id, role, current_user.id)
    return {"id": member.id, "company_id": member.company_id, "user_id": member.user_id, "role": member.role}


@router.get("/{company_id}/members", response_model=List[dict])
async def get_company_members(
    company_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Get all members of a company (only owner can view)"""
    members = CompanyService.get_company_members(db, company_id, current_user.id)
    
    # Format response with user info
    result = []
    for member in members:
        result.append({
            "id": member.id,
            "company_id": member.company_id,
            "user_id": member.user_id,
            "role": member.role,
            "created_at": member.created_at.isoformat(),
            "user": {
                "id": member.user.id,
                "firstName": member.user.first_name,
                "lastName": member.user.last_name,
                "email": member.user.email,
            } if member.user else None
        })
    return result


@router.delete("/{company_id}/members/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
async def remove_company_member(
    company_id: int,
    user_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Remove user from company (only owner can remove members)"""
    CompanyService.remove_member(db, company_id, user_id, current_user.id)
