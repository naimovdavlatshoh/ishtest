"""
Chat routes
"""
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from typing import Optional

from app.database.session import get_db
from app.api.dependencies import get_current_active_user
from app.services.chat_service import ChatService
from app.schemas.chat_schema import (
    MessageCreate,
    MessageResponse,
    ConversationResponse,
    ConversationListResponse,
    MessageListResponse,
    ConversationParticipant,
    ChatWithUserResponse,
    InvitationResponse,
    InvitationParticipant,
)
from app.database.models import User

router = APIRouter()


def conversation_to_response(conv_data: dict, user_id: int) -> ConversationResponse:
    """Convert conversation data to response schema"""
    conv = conv_data["conversation"]
    last_message = conv_data.get("last_message")
    
    return ConversationResponse(
        id=conv.id,
        applicationId=conv.application_id,
        employerId=conv.employer_id,
        applicantId=conv.applicant_id,
        createdAt=conv.created_at,
        updatedAt=conv.updated_at,
        employer=ConversationParticipant(
            id=conv.employer.id,
            firstName=conv.employer.first_name,
            lastName=conv.employer.last_name,
            avatar=conv.employer.avatar
        ) if conv.employer else None,
        applicant=ConversationParticipant(
            id=conv.applicant.id,
            firstName=conv.applicant.first_name,
            lastName=conv.applicant.last_name,
            avatar=conv.applicant.avatar
        ) if conv.applicant else None,
        lastMessage=MessageResponse(
            id=last_message.id,
            conversationId=last_message.conversation_id,
            senderId=last_message.sender_id,
            content=last_message.content,
            status=last_message.status,
            createdAt=last_message.created_at,
            readAt=last_message.read_at
        ) if last_message else None,
        unreadCount=conv_data.get("unread_count", 0),
        jobTitle=conv_data.get("job_title")
    )


def message_to_response(message) -> MessageResponse:
    """Convert message to response schema"""
    return MessageResponse(
        id=message.id,
        conversationId=message.conversation_id,
        senderId=message.sender_id,
        content=message.content,
        status=message.status,
        createdAt=message.created_at,
        readAt=message.read_at
    )


@router.get("", response_model=ConversationListResponse)
async def get_conversations(
    skip: int = Query(0, ge=0),
    limit: int = Query(20, ge=1, le=100),
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Get all conversations for current user"""
    conversations_data, total = ChatService.get_user_conversations(
        db, current_user.id, skip, limit
    )
    
    return ConversationListResponse(
        items=[conversation_to_response(c, current_user.id) for c in conversations_data],
        total=total
    )


def _invitation_to_response(inv) -> Optional[InvitationResponse]:
    if not inv:
        return None
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


@router.get("/with-user/{user_id}", response_model=ChatWithUserResponse)
async def get_chat_with_user(
    user_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
):
    """Get conversation and/or pending invitation(s) with a specific user. Use this to show 'Open chat' vs 'Send invitation' on profile/employees."""
    from app.services.chat_service import ChatService
    from app.repositories.invitation_repository import InvitationRepository
    from app.repositories.chat_repository import MessageRepository

    conversation = ChatService.get_conversation_with_user(db, current_user.id, user_id)
    pending_from_me = InvitationRepository.get_pending_between(db, current_user.id, user_id)
    pending_from_them = InvitationRepository.get_pending_between(db, user_id, current_user.id)
    if pending_from_me:
        pending_from_me = InvitationRepository.get_by_id(db, pending_from_me.id)
    if pending_from_them:
        pending_from_them = InvitationRepository.get_by_id(db, pending_from_them.id)

    conv_response = None
    if conversation:
        last_message = MessageRepository.get_last_message(db, conversation.id)
        unread_count = MessageRepository.get_unread_count(db, conversation.id, current_user.id)
        job_title = None
        if conversation.application and conversation.application.job:
            job_title = conversation.application.job.title
        conv_response = conversation_to_response({
            "conversation": conversation,
            "last_message": last_message,
            "unread_count": unread_count,
            "job_title": job_title,
        }, current_user.id)

    return ChatWithUserResponse(
        conversation=conv_response,
        pendingInvitationFromMe=_invitation_to_response(pending_from_me) if pending_from_me else None,
        pendingInvitationFromThem=_invitation_to_response(pending_from_them) if pending_from_them else None,
    )


@router.get("/application/{application_id}", response_model=Optional[ConversationResponse])
async def get_conversation_by_application(
    application_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Get conversation by application ID"""
    conversation = ChatService.get_conversation_by_application(
        db, application_id, current_user.id
    )
    
    if not conversation:
        return None
    
    from app.repositories.chat_repository import MessageRepository
    last_message = MessageRepository.get_last_message(db, conversation.id)
    unread_count = MessageRepository.get_unread_count(db, conversation.id, current_user.id)
    
    job_title = None
    if conversation.application and conversation.application.job:
        job_title = conversation.application.job.title
    
    return conversation_to_response({
        "conversation": conversation,
        "last_message": last_message,
        "unread_count": unread_count,
        "job_title": job_title
    }, current_user.id)


@router.get("/{conversation_id}", response_model=ConversationResponse)
async def get_conversation(
    conversation_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Get conversation by ID"""
    conversation = ChatService.get_conversation(db, conversation_id, current_user.id)
    
    from app.repositories.chat_repository import MessageRepository
    last_message = MessageRepository.get_last_message(db, conversation.id)
    unread_count = MessageRepository.get_unread_count(db, conversation.id, current_user.id)
    
    job_title = None
    if conversation.application and conversation.application.job:
        job_title = conversation.application.job.title
    
    return conversation_to_response({
        "conversation": conversation,
        "last_message": last_message,
        "unread_count": unread_count,
        "job_title": job_title
    }, current_user.id)


@router.get("/{conversation_id}/messages", response_model=MessageListResponse)
async def get_messages(
    conversation_id: int,
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    before_id: Optional[int] = Query(None),
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Get messages for a conversation"""
    messages, total, has_more = ChatService.get_messages(
        db, conversation_id, current_user.id, skip, limit, before_id
    )
    
    return MessageListResponse(
        items=[message_to_response(m) for m in messages],
        total=total,
        hasMore=has_more
    )


@router.post("/{conversation_id}/messages", response_model=MessageResponse)
async def send_message(
    conversation_id: int,
    message_data: MessageCreate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Send a message in a conversation"""
    message = ChatService.send_message(
        db, conversation_id, current_user.id, message_data
    )
    
    return message_to_response(message)


@router.put("/{conversation_id}/read")
async def mark_conversation_as_read(
    conversation_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Mark all messages in a conversation as read"""
    count = ChatService.mark_conversation_as_read(db, conversation_id, current_user.id)
    return {"marked_as_read": count}


@router.put("/messages/{message_id}/delivered", response_model=MessageResponse)
async def mark_message_as_delivered(
    message_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Mark a message as delivered"""
    message = ChatService.mark_message_as_delivered(db, message_id, current_user.id)
    return message_to_response(message)


@router.put("/messages/{message_id}/read", response_model=MessageResponse)
async def mark_message_as_read(
    message_id: int,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """Mark a message as read"""
    message = ChatService.mark_message_as_read(db, message_id, current_user.id)
    return message_to_response(message)
