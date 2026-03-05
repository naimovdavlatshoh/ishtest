"""
Company service
"""
from sqlalchemy.orm import Session
from typing import List
from app.repositories.company_repository import CompanyRepository
from app.repositories.company_member_repository import CompanyMemberRepository
from app.schemas.company_schema import CompanyCreate, CompanyUpdate
from app.exceptions.custom_exceptions import NotFoundError, ForbiddenError
from app.database.models import CompanyMemberRole, Company


class CompanyService:
    """Service for company operations"""
    
    @staticmethod
    def get_company(db: Session, company_id: int):
        """Get company by ID"""
        company = CompanyRepository.get_by_id(db, company_id)
        if not company:
            raise NotFoundError("Company", str(company_id))
        return company
    
    @staticmethod
    def get_companies(db: Session, skip: int = 0, limit: int = 100) -> List:
        """Get all companies"""
        return CompanyRepository.get_all(db, skip, limit)
    
    @staticmethod
    def get_user_companies(db: Session, user_id: int) -> List:
        """Get companies where user is owner or member"""
        # Get companies where user is owner
        owned_companies = CompanyRepository.get_by_owner(db, user_id)
        
        # Get companies where user is member
        memberships = CompanyMemberRepository.get_by_user(db, user_id)
        member_companies = [membership.company for membership in memberships]
        
        # Combine and remove duplicates (in case user is both owner and member)
        all_companies = {company.id: company for company in owned_companies}
        for company in member_companies:
            all_companies[company.id] = company
        
        return list(all_companies.values())
    
    @staticmethod
    def create_company(db: Session, company_data: CompanyCreate, owner_id: int):
        """Create new company and add owner as member"""
        # Verify owner_id matches
        if company_data.owner_id != owner_id:
            raise ForbiddenError("You can only create companies for yourself")
        
        company_dict = company_data.model_dump()
        company = CompanyRepository.create(db, company_dict)
        
        # Automatically add owner as CompanyMember with OWNER role
        # Use string value directly to ensure compatibility with PostgreSQL enum
        CompanyMemberRepository.create(db, company.id, owner_id, "owner")
        
        return company
    
    @staticmethod
    def update_company(db: Session, company_id: int, update_data: CompanyUpdate, user_id: int):
        """Update company"""
        company = CompanyService.get_company(db, company_id)
        
        # Check if user is the owner
        if company.owner_id != user_id:
            raise ForbiddenError("You can only update your own companies")
        
        update_dict = update_data.model_dump(exclude_unset=True)
        return CompanyRepository.update(db, company, update_dict)
    
    @staticmethod
    def delete_company(db: Session, company_id: int, user_id: int):
        """Delete company"""
        company = CompanyService.get_company(db, company_id)
        
        # Check if user is the owner
        if company.owner_id != user_id:
            raise ForbiddenError("You can only delete your own companies")
        
        CompanyRepository.delete(db, company)

    @staticmethod
    def add_member(db: Session, company_id: int, user_id: int, role: str, current_user_id: int):
        """Add user to company (only owner can add members)"""
        company = CompanyService.get_company(db, company_id)
        
        # Check if current user is owner
        if company.owner_id != current_user_id:
            raise ForbiddenError("Only company owner can add members")
        
        # Check if user is already a member
        existing_member = CompanyMemberRepository.get_by_company_and_user(db, company_id, user_id)
        if existing_member:
            raise ForbiddenError("User is already a member of this company")
        
        return CompanyMemberRepository.create(db, company_id, user_id, role)

    @staticmethod
    def remove_member(db: Session, company_id: int, member_user_id: int, current_user_id: int):
        """Remove user from company (only owner can remove members)"""
        company = CompanyService.get_company(db, company_id)
        
        # Check if current user is owner
        if company.owner_id != current_user_id:
            raise ForbiddenError("Only company owner can remove members")
        
        # Cannot remove owner
        if company.owner_id == member_user_id:
            raise ForbiddenError("Cannot remove company owner")
        
        member = CompanyMemberRepository.get_by_company_and_user(db, company_id, member_user_id)
        if not member:
            raise NotFoundError("Company Member", f"company_id={company_id}, user_id={member_user_id}")
        
        CompanyMemberRepository.delete(db, member)

    @staticmethod
    def get_company_members(db: Session, company_id: int, current_user_id: int) -> List:
        """Get all members of a company (only owner can view)"""
        company = CompanyService.get_company(db, company_id)
        
        # Check if current user is owner
        if company.owner_id != current_user_id:
            raise ForbiddenError("Only company owner can view members")
        
        return CompanyMemberRepository.get_by_company(db, company_id)

    @staticmethod
    def can_user_post_job(db: Session, company_id: int, user_id: int) -> bool:
        """Check if user can post jobs for this company"""
        if not company_id:
            return True  # Individual jobs are allowed
        
        # Check if user is owner
        company = db.query(Company).filter(Company.id == company_id).first()
        if company and company.owner_id == user_id:
            return True
        
        # Check if user is member
        return CompanyMemberRepository.is_user_member(db, company_id, user_id)
