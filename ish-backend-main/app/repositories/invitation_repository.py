"""
Invitation repository for chat invitations
"""
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import or_, desc

from app.database.models import ChatInvitation


class InvitationRepository:
    """Repository for chat invitation operations"""

    @staticmethod
    def get_by_id(db: Session, invitation_id: int):
        return db.query(ChatInvitation).options(
            joinedload(ChatInvitation.from_user),
            joinedload(ChatInvitation.to_user),
        ).filter(ChatInvitation.id == invitation_id).first()

    @staticmethod
    def get_pending_between(db: Session, from_user_id: int, to_user_id: int):
        """Get pending invitation from A to B (if any)"""
        return db.query(ChatInvitation).filter(
            ChatInvitation.from_user_id == from_user_id,
            ChatInvitation.to_user_id == to_user_id,
            ChatInvitation.status == "pending"
        ).first()

    @staticmethod
    def get_pending_between_any(db: Session, user_id_1: int, user_id_2: int):
        """Get pending invitation between two users (either direction)"""
        return db.query(ChatInvitation).filter(
            or_(
                (ChatInvitation.from_user_id == user_id_1) & (ChatInvitation.to_user_id == user_id_2),
                (ChatInvitation.from_user_id == user_id_2) & (ChatInvitation.to_user_id == user_id_1),
            ),
            ChatInvitation.status == "pending"
        ).first()

    @staticmethod
    def get_user_invitations(
        db: Session,
        user_id: int,
        skip: int = 0,
        limit: int = 50,
        received: bool = True,
        sent: bool = True,
    ):
        """Get invitations where user is receiver and/or sender"""
        q = db.query(ChatInvitation).options(
            joinedload(ChatInvitation.from_user),
            joinedload(ChatInvitation.to_user),
        ).order_by(desc(ChatInvitation.created_at))

        if received and sent:
            q = q.filter(
                or_(
                    ChatInvitation.to_user_id == user_id,
                    ChatInvitation.from_user_id == user_id,
                )
            )
        elif received:
            q = q.filter(ChatInvitation.to_user_id == user_id)
        else:
            q = q.filter(ChatInvitation.from_user_id == user_id)

        total = q.count()
        items = q.offset(skip).limit(limit).all()
        return items, total

    @staticmethod
    def create(db: Session, data: dict) -> ChatInvitation:
        inv = ChatInvitation(**data)
        db.add(inv)
        db.commit()
        db.refresh(inv)
        return inv

    @staticmethod
    def update(db: Session, invitation: ChatInvitation, data: dict) -> ChatInvitation:
        for k, v in data.items():
            setattr(invitation, k, v)
        db.commit()
        db.refresh(invitation)
        return invitation
