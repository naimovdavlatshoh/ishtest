"""
Telegram code repository - one-time codes for link/login
"""
import hashlib
import secrets
from datetime import datetime, timezone, timedelta
from typing import Optional
from sqlalchemy.orm import Session
from app.database.models import TelegramCode, User


CODE_LENGTH = 6
CODE_EXPIRE_MINUTES = 1


def _hash_code(code: str) -> str:
    return hashlib.sha256(code.encode()).hexdigest()


class TelegramCodeRepository:
    @staticmethod
    def has_valid_code(db: Session, telegram_id: str, purpose: str) -> bool:
        """True if user already has a non-expired code for this purpose."""
        now = datetime.now(timezone.utc)
        return (
            db.query(TelegramCode)
            .filter(
                TelegramCode.telegram_id == telegram_id,
                TelegramCode.purpose == purpose,
                TelegramCode.expires_at > now,
            )
            .first()
            is not None
        )

    @staticmethod
    def create(
        db: Session,
        telegram_id: str,
        purpose: str,
        user_id: Optional[int] = None,
        expire_minutes: int = CODE_EXPIRE_MINUTES,
    ) -> str:
        """Create a one-time code. Returns the plain code (to show in bot)."""
        code = "".join(secrets.choice("0123456789") for _ in range(CODE_LENGTH))
        code_hash = _hash_code(code)
        expires_at = datetime.now(timezone.utc) + timedelta(minutes=expire_minutes)
        row = TelegramCode(
            code_hash=code_hash,
            telegram_id=telegram_id,
            purpose=purpose,
            user_id=user_id,
            expires_at=expires_at,
        )
        db.add(row)
        db.commit()
        return code

    @staticmethod
    def find_valid_by_code(db: Session, code: str) -> Optional[TelegramCode]:
        """Find a non-expired code by plain code. Returns the row or None."""
        code_hash = _hash_code(code.strip())
        row = (
            db.query(TelegramCode)
            .filter(TelegramCode.code_hash == code_hash)
            .first()
        )
        if not row or row.expires_at < datetime.now(timezone.utc):
            return None
        return row

    @staticmethod
    def delete(db: Session, row: TelegramCode) -> None:
        db.delete(row)
        db.commit()
