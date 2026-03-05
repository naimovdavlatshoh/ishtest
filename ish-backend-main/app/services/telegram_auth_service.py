"""
Telegram auth service - code-based link and login
"""
from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from app.database.models import User
from app.repositories.user_repository import UserRepository
from app.repositories.telegram_code_repository import TelegramCodeRepository


class TelegramAuthService:
    OLD_CODE_STILL_VALID_MSG = (
        "Eski kodingiz hali ham amal qiladi, iltimos uni ishlating yoki 1 daqiqat kuting."
    )

    @staticmethod
    def create_code_for_bot(db: Session, telegram_id: str, purpose: str) -> str:
        """
        Bot calls this to get a code for the user.
        - purpose=link: just store telegram_id, no user_id yet.
        - purpose=login: find user by telegram_id; if not found raise; else create code with user_id.
        Returns plain code string.
        """
        telegram_id = str(telegram_id).strip()
        if TelegramCodeRepository.has_valid_code(db, telegram_id, purpose):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=TelegramAuthService.OLD_CODE_STILL_VALID_MSG,
            )
        if purpose == "login":
            user = UserRepository.get_by_telegram_id(db, telegram_id)
            if not user:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Telegram ulanishmagan. Avval profil sozlamalarida Telegramni ulang.\n\nAccount not linked. Please link Telegram first in profile settings.",
                )
            return TelegramCodeRepository.create(db, telegram_id, purpose, user_id=user.id)
        if purpose == "link":
            return TelegramCodeRepository.create(db, telegram_id, purpose, user_id=None)
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid purpose")

    @staticmethod
    def link_telegram(db: Session, code: str, current_user_id: int) -> User:
        """User on site (logged in) submits code. Link telegram_id to current user."""
        row = TelegramCodeRepository.find_valid_by_code(db, code)
        if not row:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid or expired code. Please get a new code from the bot.",
            )
        if row.purpose != "link":
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid code type")
        user = UserRepository.get_by_id(db, current_user_id)
        if not user:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
        # Another user might already have this telegram_id
        existing = UserRepository.get_by_telegram_id(db, row.telegram_id)
        if existing and existing.id != current_user_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="This Telegram is already linked to another account.",
            )
        TelegramCodeRepository.delete(db, row)
        # Update user
        user.telegram_id = row.telegram_id
        db.commit()
        db.refresh(user)
        return user

    @staticmethod
    def login_with_code(db: Session, code: str) -> User | None:
        """User on site submits code. Return user if code is valid login code."""
        row = TelegramCodeRepository.find_valid_by_code(db, code)
        if not row:
            return None
        if row.purpose != "login" or not row.user_id:
            return None
        TelegramCodeRepository.delete(db, row)
        user = UserRepository.get_by_id(db, row.user_id)
        if not user or not user.is_active:
            return None
        return user
