"""
User schemas
"""
from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from datetime import datetime
from app.database.models import UserRole


class UserBase(BaseModel):
    """Base user schema"""
    email: EmailStr
    phone: str
    first_name: str = Field(..., min_length=1, max_length=100)
    last_name: str = Field(..., min_length=1, max_length=100)


class UserCreate(UserBase):
    """User creation schema"""
    password: str = Field(..., min_length=6, max_length=72)


class UserUpdate(BaseModel):
    """User update schema"""
    email: Optional[EmailStr] = None
    phone: Optional[str] = None
    first_name: Optional[str] = Field(None, min_length=1, max_length=100)
    last_name: Optional[str] = Field(None, min_length=1, max_length=100)
    avatar: Optional[str] = None
    telegram_id: Optional[str] = None


class UserResponse(UserBase):
    """User response schema"""
    id: int
    role: UserRole
    avatar: Optional[str] = None
    telegram_id: Optional[str] = None
    is_active: bool
    is_verified: bool
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


class UserLogin(BaseModel):
    """User login schema"""
    phone: str
    password: str


class Token(BaseModel):
    """Token schema"""
    access_token: str
    token_type: str = "bearer"


class TokenData(BaseModel):
    """Token data schema"""
    user_id: Optional[int] = None


class PaginatedUsersResponse(BaseModel):
    """Paginated users response schema"""
    items: List[UserResponse]
    total: int
    skip: int
    limit: int


# --- Telegram auth (code-based link / login) ---


class TelegramCodeRequest(BaseModel):
    """Bot requests a code for this telegram_id (purpose: link or login)"""
    telegram_id: str
    purpose: str  # "link" | "login"


class TelegramCodeResponse(BaseModel):
    """Code to show in bot"""
    code: str


class TelegramCheckResponse(BaseModel):
    """Bot check: is this telegram_id already linked to a user"""
    linked: bool


class TelegramLinkRequest(BaseModel):
    """User on site submits code to link Telegram (requires JWT)"""
    code: str


class TelegramLoginRequest(BaseModel):
    """User on site submits code to log in"""
    code: str
