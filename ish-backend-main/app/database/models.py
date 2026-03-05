"""
Database models
"""
from typing import Optional
from sqlalchemy import Column, String, Integer, Boolean, DateTime, Text, ForeignKey, UniqueConstraint
from sqlalchemy.dialects.postgresql import JSONB, ENUM as PgEnum
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from datetime import datetime
import enum

from app.database.base import Base


class UserRole(str, enum.Enum):
    """User role enum. Values match PostgreSQL userrole ('user', 'admin')."""
    USER = "user"
    ADMIN = "admin"


# values_callable: use enum .value ('user'/'admin') so DB string maps to Python enum
UserRoleEnum = PgEnum(
    UserRole,
    name="userrole",
    create_type=False,
    values_callable=lambda obj: [e.value for e in obj],
)


class JobType(str, enum.Enum):
    """Job type enum"""
    FULL_TIME = "full-time"
    PART_TIME = "part-time"
    CONTRACT = "contract"
    INTERNSHIP = "internship"
    REMOTE = "remote"


class JobStatus(str, enum.Enum):
    """Job status enum"""
    DRAFT = "draft"
    ACTIVE = "active"
    CLOSED = "closed"


class ApplicationStatus(str, enum.Enum):
    """Application status enum"""
    PENDING = "pending"
    REVIEWED = "reviewed"
    ACCEPTED = "accepted"
    REJECTED = "rejected"


# PgEnum with values_callable: bind enum .value to PostgreSQL (e.g. 'active' not 'ACTIVE')
JobTypeEnum = PgEnum(
    JobType,
    name="jobtype",
    create_type=False,
    values_callable=lambda obj: [e.value for e in obj],
)
JobStatusEnum = PgEnum(
    JobStatus,
    name="jobstatus",
    create_type=False,
    values_callable=lambda obj: [e.value for e in obj],
)
ApplicationStatusEnum = PgEnum(
    ApplicationStatus,
    name="applicationstatus",
    create_type=False,
    values_callable=lambda obj: [e.value for e in obj],
)


class CompanySize(str, enum.Enum):
    """Company size enum"""
    SIZE_1_10 = "1-10"
    SIZE_11_50 = "11-50"
    SIZE_51_200 = "51-200"
    SIZE_201_500 = "201-500"
    SIZE_500_PLUS = "500+"


CompanySizeEnum = PgEnum(
    CompanySize,
    name="companysize",
    create_type=False,
    values_callable=lambda obj: [e.value for e in obj],
)


class CompanyMemberRole(str, enum.Enum):
    """Company member role enum"""
    OWNER = "owner"  # Company owner/creator
    MEMBER = "member"  # Regular company member (can post jobs)
    
    def __str__(self):
        return self.value


class User(Base):
    """User model"""
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, index=True, nullable=False)
    phone = Column(String(20), unique=True, index=True, nullable=False)
    first_name = Column(String(100), nullable=False)
    last_name = Column(String(100), nullable=False)
    hashed_password = Column(String(255), nullable=False)
    role = Column(UserRoleEnum, default=UserRole.USER, nullable=False)
    avatar = Column(String(500), nullable=True)
    is_active = Column(Boolean, default=True, nullable=False)
    is_verified = Column(Boolean, default=False, nullable=False)
    telegram_id = Column(String(50), unique=True, index=True, nullable=True)  # Telegram user ID for login
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)
    
    # Relationships
    profile = relationship("Profile", back_populates="user", uselist=False)
    companies = relationship("Company", back_populates="owner")
    company_memberships = relationship("CompanyMember", back_populates="user")
    jobs = relationship("Job", back_populates="author")
    applications = relationship("Application", back_populates="applicant")
    saved_jobs = relationship("SavedJob", back_populates="user")
    chat_invitations_sent = relationship("ChatInvitation", foreign_keys="ChatInvitation.from_user_id")
    chat_invitations_received = relationship("ChatInvitation", foreign_keys="ChatInvitation.to_user_id")


class TelegramCodePurpose(str, enum.Enum):
    """Purpose of telegram code: link account or login"""
    LINK = "link"
    LOGIN = "login"


class TelegramCode(Base):
    """One-time code for Telegram link or login. Bot requests code, user enters on site."""
    __tablename__ = "telegram_codes"
    
    id = Column(Integer, primary_key=True, index=True)
    code_hash = Column(String(64), nullable=False, index=True)  # SHA-256 of code
    telegram_id = Column(String(50), nullable=False, index=True)
    purpose = Column(String(20), nullable=False)  # 'link' | 'login'
    user_id = Column(Integer, ForeignKey("users.id"), nullable=True)  # For login codes: which user
    expires_at = Column(DateTime(timezone=True), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)


class Profile(Base):
    """User profile model - like LinkedIn, supports multiple capabilities simultaneously"""
    __tablename__ = "profiles"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    full_name = Column(String(200), nullable=False)
    city = Column(String(100), nullable=False)
    bio = Column(Text, nullable=True)
    title = Column(String(200), nullable=True)  # Job title (e.g., "Senior Developer")
    
    # Job Seeker section (Ish qidiruvchi)
    skills = Column(JSONB, nullable=True)  # JSONB array of skills
    experience = Column(JSONB, nullable=True)  # JSONB array of work experience
    education = Column(JSONB, nullable=True)  # JSONB array of education
    cv_file = Column(String(500), nullable=True)  # CV file path
    
    # Employer section (Ish beruvchi) - can have multiple companies
    # Companies are stored in separate Company model, but we can add quick info here
    employer_info = Column(JSONB, nullable=True)  # JSONB: {business_type, needed_employees_description}
    
    # Freelancer section
    freelancer_info = Column(JSONB, nullable=True)  # JSONB: {services, portfolio, prices, previous_works}
    
    # Profile completion flags for different sections
    job_seeker_complete = Column(Boolean, default=False, nullable=False)
    employer_complete = Column(Boolean, default=False, nullable=False)
    freelancer_complete = Column(Boolean, default=False, nullable=False)
    
    # "Open To Work" status flags - controls visibility on different pages
    # open_to_job_seeker: User is LOOKING FOR WORK → visible on Employees page
    open_to_job_seeker = Column(Boolean, default=False, nullable=False)
    # open_to_employer: Reserved for future use
    open_to_employer = Column(Boolean, default=False, nullable=False)
    
    is_complete = Column(Boolean, default=False, nullable=False)  # Overall profile completion
    views_count = Column(Integer, default=0, nullable=False)  # Profile view count for dashboard
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)
    
    # Relationships
    user = relationship("User", back_populates="profile")

    @property
    def avatar(self) -> Optional[str]:
        """Avatar URL from linked user (for API response)."""
        return self.user.avatar if self.user else None


class Company(Base):
    """Company model"""
    __tablename__ = "companies"
    
    id = Column(Integer, primary_key=True, index=True)
    owner_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    name = Column(String(200), nullable=False, index=True)
    description = Column(Text, nullable=True)
    logo = Column(String(500), nullable=True)
    website = Column(String(255), nullable=True)
    location = Column(String(200), nullable=False)
    industry = Column(String(100), nullable=True)
    size = Column(CompanySizeEnum, nullable=True)
    is_verified = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)
    
    # Relationships
    owner = relationship("User", back_populates="companies")
    members = relationship("CompanyMember", back_populates="company", cascade="all, delete-orphan")
    jobs = relationship("Job", back_populates="company")


class CompanyMember(Base):
    """Company member model - many-to-many relationship between User and Company with role"""
    __tablename__ = "company_members"
    
    id = Column(Integer, primary_key=True, index=True)
    company_id = Column(Integer, ForeignKey("companies.id"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    role = Column(String(20), default=CompanyMemberRole.MEMBER.value, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    
    # Relationships
    company = relationship("Company", back_populates="members")
    user = relationship("User", back_populates="company_memberships")
    
    # Unique constraint: user can be member of a company only once
    __table_args__ = (UniqueConstraint('company_id', 'user_id', name='_company_user_uc'),)


class Job(Base):
    """Job model"""
    __tablename__ = "jobs"
    
    id = Column(Integer, primary_key=True, index=True)
    author_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    company_id = Column(Integer, ForeignKey("companies.id"), nullable=True)
    title = Column(String(200), nullable=False, index=True)
    description = Column(Text, nullable=False)
    location = Column(String(200), nullable=False)
    salary_min = Column(Integer, nullable=True)
    salary_max = Column(Integer, nullable=True)
    salary_currency = Column(String(10), default="UZS", nullable=True)
    job_type = Column(JobTypeEnum, nullable=False)
    status = Column(JobStatusEnum, default=JobStatus.DRAFT, nullable=False)
    requirements = Column(JSONB, nullable=True)  # JSONB array of requirements
    is_remote = Column(Boolean, default=False, nullable=False)
    views_count = Column(Integer, default=0, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)
    
    # Relationships
    author = relationship("User", back_populates="jobs")
    company = relationship("Company", back_populates="jobs")
    applications = relationship("Application", back_populates="job")
    saved_by_users = relationship("SavedJob", back_populates="job")


class Application(Base):
    """Job application model"""
    __tablename__ = "applications"
    
    id = Column(Integer, primary_key=True, index=True)
    job_id = Column(Integer, ForeignKey("jobs.id"), nullable=False)
    applicant_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    cover_letter = Column(Text, nullable=True)
    status = Column(ApplicationStatusEnum, default=ApplicationStatus.PENDING, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)
    
    # Relationships
    job = relationship("Job", back_populates="applications")
    applicant = relationship("User", back_populates="applications")


class SavedJob(Base):
    """Saved job model - many-to-many relationship between User and Job"""
    __tablename__ = "saved_jobs"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    job_id = Column(Integer, ForeignKey("jobs.id"), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    
    # Relationships
    user = relationship("User", back_populates="saved_jobs")
    job = relationship("Job", back_populates="saved_by_users")
    
    # Unique constraint: user can save a job only once
    __table_args__ = (
        UniqueConstraint('user_id', 'job_id', name='uq_user_job'),
    )


class MessageStatus(str, enum.Enum):
    """Message status enum"""
    SENT = "sent"
    DELIVERED = "delivered"
    READ = "read"


class InvitationStatus(str, enum.Enum):
    """Chat invitation status"""
    PENDING = "pending"
    ACCEPTED = "accepted"
    REJECTED = "rejected"


class ChatInvitation(Base):
    """Invitation to start a direct chat (e.g. from Employees page). After accept, a conversation is created."""
    __tablename__ = "chat_invitations"

    id = Column(Integer, primary_key=True, index=True)
    from_user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    to_user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    message = Column(Text, nullable=True)  # Optional intro message
    status = Column(String(20), default=InvitationStatus.PENDING.value, nullable=False)
    conversation_id = Column(Integer, ForeignKey("conversations.id"), nullable=True)  # Set when accepted
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    # Relationships
    from_user = relationship("User", foreign_keys=[from_user_id])
    to_user = relationship("User", foreign_keys=[to_user_id])
    conversation = relationship("Conversation", backref="invitation", uselist=False)

    __table_args__ = (
        UniqueConstraint("from_user_id", "to_user_id", name="uq_invitation_from_to"),
    )


class Conversation(Base):
    """Conversation model - chat between two users (from accepted application or from accepted chat invitation)"""
    __tablename__ = "conversations"

    id = Column(Integer, primary_key=True, index=True)
    application_id = Column(Integer, ForeignKey("applications.id"), unique=True, nullable=True)  # Null for direct chats
    employer_id = Column(Integer, ForeignKey("users.id"), nullable=False)  # Initiator (job author or invitation sender)
    applicant_id = Column(Integer, ForeignKey("users.id"), nullable=False)  # Other participant
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now(), nullable=False)

    # Relationships
    application = relationship("Application", backref="conversation")
    employer = relationship("User", foreign_keys=[employer_id])
    applicant = relationship("User", foreign_keys=[applicant_id])
    messages = relationship("Message", back_populates="conversation", order_by="Message.created_at")


class Message(Base):
    """Message model"""
    __tablename__ = "messages"
    
    id = Column(Integer, primary_key=True, index=True)
    conversation_id = Column(Integer, ForeignKey("conversations.id"), nullable=False)
    sender_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    content = Column(Text, nullable=False)
    status = Column(String(20), default="sent", nullable=False)  # sent, delivered, read
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    read_at = Column(DateTime(timezone=True), nullable=True)
    
    # Relationships
    conversation = relationship("Conversation", back_populates="messages")
    sender = relationship("User")
