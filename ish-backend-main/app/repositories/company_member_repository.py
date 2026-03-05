"""
Company Member repository
"""
from sqlalchemy.orm import Session, joinedload
from typing import Optional, List
from app.database.models import CompanyMember, Company, User


class CompanyMemberRepository:
    """Repository for company member operations"""

    @staticmethod
    def get_by_company_and_user(db: Session, company_id: int, user_id: int) -> Optional[CompanyMember]:
        """Get company member by company ID and user ID"""
        return db.query(CompanyMember).filter(
            CompanyMember.company_id == company_id,
            CompanyMember.user_id == user_id
        ).first()

    @staticmethod
    def get_by_company(db: Session, company_id: int) -> List[CompanyMember]:
        """Get all members of a company"""
        return db.query(CompanyMember).options(
            joinedload(CompanyMember.user)
        ).filter(CompanyMember.company_id == company_id).all()

    @staticmethod
    def get_by_user(db: Session, user_id: int) -> List[CompanyMember]:
        """Get all companies where user is a member"""
        return db.query(CompanyMember).options(
            joinedload(CompanyMember.company)
        ).filter(CompanyMember.user_id == user_id).all()

    @staticmethod
    def create(db: Session, company_id: int, user_id: int, role: str) -> CompanyMember:
        """Add user to company"""
        member = CompanyMember(
            company_id=company_id,
            user_id=user_id,
            role=role
        )
        db.add(member)
        db.commit()
        db.refresh(member)
        return member

    @staticmethod
    def update_role(db: Session, member: CompanyMember, role: str) -> CompanyMember:
        """Update member role"""
        member.role = role
        db.commit()
        db.refresh(member)
        return member

    @staticmethod
    def delete(db: Session, member: CompanyMember) -> None:
        """Remove user from company"""
        db.delete(member)
        db.commit()

    @staticmethod
    def is_user_member(db: Session, company_id: int, user_id: int) -> bool:
        """Check if user is a member of the company (owner or member)"""
        member = CompanyMemberRepository.get_by_company_and_user(db, company_id, user_id)
        return member is not None

    @staticmethod
    def is_user_owner(db: Session, company_id: int, user_id: int) -> bool:
        """Check if user is the owner of the company"""
        from app.database.models import CompanyMemberRole
        member = CompanyMemberRepository.get_by_company_and_user(db, company_id, user_id)
        if member:
            return member.role == CompanyMemberRole.OWNER
        # Also check if user is the company owner
        company = db.query(Company).filter(Company.id == company_id).first()
        return company and company.owner_id == user_id
