"""
Authentication routes
"""
from fastapi import APIRouter, Depends, HTTPException, status, Header, Query
from sqlalchemy.orm import Session
from datetime import timedelta
from app.database.session import get_db
from app.schemas.user_schema import (
    UserLogin,
    UserCreate,
    UserResponse,
    Token,
    TelegramCodeRequest,
    TelegramCodeResponse,
    TelegramCheckResponse,
    TelegramLinkRequest,
    TelegramLoginRequest,
)
from app.services.user_service import UserService
from app.services.telegram_auth_service import TelegramAuthService
from app.repositories.user_repository import UserRepository
from app.repositories.telegram_code_repository import TelegramCodeRepository
from app.utils.security import create_access_token
from app.core.config import settings
from app.api.dependencies import get_current_user

router = APIRouter()


def verify_bot_api_key(x_bot_token: str | None = Header(None, alias="X-Bot-Token")):
    """Only the Telegram bot can call code-creation endpoint."""
    key = x_bot_token or ""
    if not settings.TELEGRAM_BOT_API_KEY or key != settings.TELEGRAM_BOT_API_KEY:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid bot token")
    return key


@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def register(user_data: UserCreate, db: Session = Depends(get_db)):
    """Register new user"""
    user = UserService.create_user(db, user_data)
    return user


@router.post("/login", response_model=Token)
async def login(credentials: UserLogin, db: Session = Depends(get_db)):
    """Login user"""
    user = UserService.authenticate_user(db, credentials.phone, credentials.password)
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect phone or password"
        )
    
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": str(user.id)},  # JWT requires sub to be a string
        expires_delta=access_token_expires
    )
    
    return {"access_token": access_token, "token_type": "bearer"}


# --- Telegram code-based link / login ---


@router.get("/telegram/check", response_model=TelegramCheckResponse)
async def telegram_check_linked(
    telegram_id: str = Query(..., alias="telegram_id"),
    db: Session = Depends(get_db),
    _: str = Depends(verify_bot_api_key),
):
    """Bot only: check if this telegram_id is already linked to a user."""
    user = UserRepository.get_by_telegram_id(db, telegram_id.strip())
    return TelegramCheckResponse(linked=user is not None)


@router.post("/telegram/code", response_model=TelegramCodeResponse)
async def telegram_create_code(
    body: TelegramCodeRequest,
    db: Session = Depends(get_db),
    _: str = Depends(verify_bot_api_key),
):
    """Bot only: create a one-time code for link or login. User shows this code in bot."""
    if body.purpose not in ("link", "login"):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid purpose")
    code = TelegramAuthService.create_code_for_bot(db, body.telegram_id, body.purpose)
    return TelegramCodeResponse(code=code)


@router.post("/telegram/link", response_model=UserResponse)
async def telegram_link(
    body: TelegramLinkRequest,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    """User (logged in) submits code from bot to link Telegram to account."""
    user = TelegramAuthService.link_telegram(db, body.code, current_user.id)
    return user


@router.post("/telegram/login", response_model=Token)
async def telegram_login(body: TelegramLoginRequest, db: Session = Depends(get_db)):
    """User submits code from bot to log in (no password)."""
    user = TelegramAuthService.login_with_code(db, body.code)
    if not user:
        # If code is valid but for linking, tell user to get a login code
        row = TelegramCodeRepository.find_valid_by_code(db, body.code)
        if row and row.purpose == "link":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="This code is for linking your account. To log in, open the bot and tap 'Kirish kodi', then enter that code here.",
            )
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired code. Get a new code from the Telegram bot.",
        )
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": str(user.id)},
        expires_delta=access_token_expires,
    )
    return {"access_token": access_token, "token_type": "bearer"}


# Note: /me endpoint is in users.py
