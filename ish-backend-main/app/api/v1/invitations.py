"""
Chat invitation routes
"""
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.database.session import get_db
from app.api.dependencies import get_current_active_user
from app.services.invitation_service import InvitationService
from app.schemas.chat_schema import (
    InvitationCreate,
    InvitationResponse,
    InvitationListResponse,
    InvitationParticipant,
)
from app.database.models import User

router = APIRouter()


def invitation_to_response(inv) -> InvitationResponse:
    return InvitationResponse(
        id=inv.id,
        fromUserId=inv.from_user_id,
        toUserId=inv.to_user_id,
        message=inv.message,
        status=inv.status,
        conversationId=inv.conversation_id,
        createdAt=inv.created_at,
        fromUser=InvitationParticipant(
            id=inv.from_user.id,
            firstName=inv.from_user.first_name,
            lastName=inv.from_user.last_name,
            avatar=inv.from_user.avatar,
        ) if inv.from_user else None,
        toUser=InvitationParticipant(
            id=inv.to_user.id,
            firstName=inv.to_user.first_name,
            lastName=inv.to_user.last_name,
            avatar=inv.to_user.avatar,
        ) if inv.to_user else None,
    )


@router.post("", response_model=InvitationResponse, status_code=201)
async def create_invitation(
    body: InvitationCreate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
):
    """Send a chat invitation to another user (e.g. from Employees page). They can accept to open a chat."""
    inv = InvitationService.create(db, current_user.id, body.to_user_id, message=body.message)
    # Reload with relationships
    inv = InvitationService.get_invitation(db, inv.id, current_user.id)
    return invitation_to_response(inv)


@router.get("", response_model=InvitationListResponse)
async def list_invitations(
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    received: bool = Query(True, description="Include invitations received by me"),
    sent: bool = Query(True, description="Include invitations sent by me"),
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
):
    """List my invitations (received and/or sent)."""
    items, total = InvitationService.get_user_invitations(
        db, current_user.id, skip=skip, limit=limit, received=received, sent=sent
    )
    return InvitationListResponse(
        items=[invitation_to_response(i) for i in items],
        total=total,
    )


@router.get("/received", response_model=InvitationListResponse)
async def list_received(
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
):
    """List invitations I received (pending accept/reject)."""
    items, total = InvitationService.get_user_invitations(
        db, current_user.id, skip=skip, limit=limit, received=True, sent=False
    )
    return InvitationListResponse(
        items=[invitation_to_response(i) for i in items],
        total=total,
    )


@router.get("/{invitation_id}", response_model=InvitationResponse)
async def get_invitation(
    invitation_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
):
    """Get a single invitation by ID."""
    inv = InvitationService.get_invitation(db, invitation_id, current_user.id)
    return invitation_to_response(inv)


@router.post("/{invitation_id}/accept", response_model=InvitationResponse)
async def accept_invitation(
    invitation_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
):
    """Accept a chat invitation. A conversation is created and you can open the chat."""
    inv = InvitationService.accept(db, invitation_id, current_user.id)
    inv = InvitationService.get_invitation(db, inv.id, current_user.id)
    return invitation_to_response(inv)


@router.post("/{invitation_id}/reject", response_model=InvitationResponse)
async def reject_invitation(
    invitation_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
):
    """Reject a chat invitation."""
    inv = InvitationService.reject(db, invitation_id, current_user.id)
    inv = InvitationService.get_invitation(db, inv.id, current_user.id)
    return invitation_to_response(inv)
