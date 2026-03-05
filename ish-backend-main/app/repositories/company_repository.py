"""
Company repository
"""
from sqlalchemy.orm import Session
from typing import Optional, List
from app.database.models import Company


class CompanyRepository:
    """Repository for company operations"""
    
    @staticmethod
    def get_by_id(db: Session, company_id: int) -> Optional[Company]:
        """Get company by ID"""
        return db.query(Company).filter(Company.id == company_id).first()
    
    @staticmethod
    def get_all(db: Session, skip: int = 0, limit: int = 100) -> List[Company]:
        """Get all companies"""
        return db.query(Company).offset(skip).limit(limit).all()
    
    @staticmethod
    def get_by_owner(db: Session, owner_id: int) -> List[Company]:
        """Get companies by owner"""
        return db.query(Company).filter(Company.owner_id == owner_id).all()
    
    @staticmethod
    def create(db: Session, company_data: dict) -> Company:
        """Create new company"""
        company = Company(**company_data)
        db.add(company)
        db.commit()
        db.refresh(company)
        return company
    
    @staticmethod
    def update(db: Session, company: Company, update_data: dict) -> Company:
        """Update company"""
        for key, value in update_data.items():
            setattr(company, key, value)
        
        db.commit()
        db.refresh(company)
        return company
    
    @staticmethod
    def delete(db: Session, company: Company) -> None:
        """Delete company"""
        db.delete(company)
        db.commit()
