"""
Invitation service for chat invitations
"""
from sqlalchemy.orm import Session
from typing import List, Tuple, Optional

from app.repositories.invitation_repository import InvitationRepository
from app.repositories.user_repository import UserRepository
from app.database.models import ChatInvitation
from app.exceptions.custom_exceptions import NotFoundError, ForbiddenError, ConflictError


class InvitationService:
    """Service for chat invitation operations"""

    @staticmethod
    def create(db: Session, from_user_id: int, to_user_id: int, message: Optional[str] = None) -> ChatInvitation:
        """Send a chat invitation from current user to another user."""
        if from_user_id == to_user_id:
            raise ConflictError("You cannot send an invitation to yourself")

        to_user = UserRepository.get_by_id(db, to_user_id)
        if not to_user:
            raise NotFoundError("User", str(to_user_id))

        # Already have pending from me to them
        existing = InvitationRepository.get_pending_between(db, from_user_id, to_user_id)
        if existing:
            raise ConflictError("You have already sent an invitation to this user")

        # They sent me a pending invitation - could auto-accept or tell user to accept
        from_them = InvitationRepository.get_pending_between(db, to_user_id, from_user_id)
        if from_them:
            raise ConflictError("This user has already sent you an invitation. Check your invitations to accept.")

        return InvitationRepository.create(db, {
            "from_user_id": from_user_id,
            "to_user_id": to_user_id,
            "message": message or None,
            "status": "pending",
        })

    @staticmethod
    def get_user_invitations(
        db: Session,
        user_id: int,
        skip: int = 0,
        limit: int = 50,
        received: bool = True,
        sent: bool = True,
    ) -> Tuple[List[ChatInvitation], int]:
        return InvitationRepository.get_user_invitations(
            db, user_id, skip, limit, received=received, sent=sent
        )

    @staticmethod
    def get_invitation(db: Session, invitation_id: int, user_id: int) -> ChatInvitation:
        inv = InvitationRepository.get_by_id(db, invitation_id)
        if not inv:
            raise NotFoundError("Invitation", str(invitation_id))
        if inv.to_user_id != user_id and inv.from_user_id != user_id:
            raise ForbiddenError("You can only view your own invitations")
        return inv

    @staticmethod
    def accept(db: Session, invitation_id: int, user_id: int) -> ChatInvitation:
        """Accept an invitation (only recipient can accept). Returns invitation with conversation created."""
        inv = InvitationService.get_invitation(db, invitation_id, user_id)
        if inv.to_user_id != user_id:
            raise ForbiddenError("Only the recipient can accept the invitation")
        if inv.status != "pending":
            raise ConflictError("This invitation has already been accepted or rejected")

        from app.services.chat_service import ChatService
        conversation = ChatService.create_conversation_for_invitation(
            db, inv.from_user_id, inv.to_user_id
        )
        InvitationRepository.update(db, inv, {
            "status": "accepted",
            "conversation_id": conversation.id,
        })
        db.refresh(inv)
        return inv

    @staticmethod
    def reject(db: Session, invitation_id: int, user_id: int) -> ChatInvitation:
        """Reject an invitation (only recipient can reject)."""
        inv = InvitationService.get_invitation(db, invitation_id, user_id)
        if inv.to_user_id != user_id:
            raise ForbiddenError("Only the recipient can reject the invitation")
        if inv.status != "pending":
            raise ConflictError("This invitation has already been accepted or rejected")

        InvitationRepository.update(db, inv, {"status": "rejected"})
        db.refresh(inv)
        return inv
