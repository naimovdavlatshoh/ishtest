"""
Chat schemas
"""
from pydantic import BaseModel, ConfigDict, Field
from typing import Optional, List
from datetime import datetime


class MessageCreate(BaseModel):
    """Schema for creating a message"""
    content: str = Field(..., min_length=1, max_length=5000)


class MessageResponse(BaseModel):
    """Schema for message response"""
    id: int
    conversation_id: int = Field(..., alias="conversationId")
    sender_id: int = Field(..., alias="senderId")
    content: str
    status: str
    created_at: datetime = Field(..., alias="createdAt")
    read_at: Optional[datetime] = Field(None, alias="readAt")
    
    model_config = ConfigDict(
        from_attributes=True,
        populate_by_name=True
    )


class ConversationParticipant(BaseModel):
    """Schema for conversation participant"""
    id: int
    first_name: str = Field(..., alias="firstName")
    last_name: str = Field(..., alias="lastName")
    avatar: Optional[str] = None
    
    model_config = ConfigDict(
        from_attributes=True,
        populate_by_name=True
    )


class ConversationResponse(BaseModel):
    """Schema for conversation response"""
    id: int
    application_id: Optional[int] = Field(None, alias="applicationId")
    employer_id: int = Field(..., alias="employerId")
    applicant_id: int = Field(..., alias="applicantId")
    created_at: datetime = Field(..., alias="createdAt")
    updated_at: datetime = Field(..., alias="updatedAt")
    
    # Populated fields
    employer: Optional[ConversationParticipant] = None
    applicant: Optional[ConversationParticipant] = None
    last_message: Optional[MessageResponse] = Field(None, alias="lastMessage")
    unread_count: int = Field(0, alias="unreadCount")
    job_title: Optional[str] = Field(None, alias="jobTitle")
    
    model_config = ConfigDict(
        from_attributes=True,
        populate_by_name=True
    )


class ConversationListResponse(BaseModel):
    """Schema for list of conversations"""
    items: List[ConversationResponse]
    total: int


class MessageListResponse(BaseModel):
    """Schema for list of messages"""
    items: List[MessageResponse]
    total: int
    has_more: bool = Field(..., alias="hasMore")
    
    model_config = ConfigDict(populate_by_name=True)


# WebSocket message types
class WSMessageType:
    NEW_MESSAGE = "new_message"
    MESSAGE_DELIVERED = "message_delivered"
    MESSAGE_READ = "message_read"
    MESSAGES_READ = "messages_read"
    ERROR = "error"


class WSMessage(BaseModel):
    """WebSocket message format"""
    type: str
    data: dict


# Chat invitation schemas
class InvitationCreate(BaseModel):
    """Schema for creating a chat invitation"""
    to_user_id: int = Field(..., alias="toUserId")
    message: Optional[str] = Field(None, max_length=1000)

    model_config = ConfigDict(populate_by_name=True)


class InvitationParticipant(BaseModel):
    """Minimal user info for invitation display"""
    id: int
    first_name: str = Field(..., alias="firstName")
    last_name: str = Field(..., alias="lastName")
    avatar: Optional[str] = None

    model_config = ConfigDict(populate_by_name=True, from_attributes=True)


class InvitationResponse(BaseModel):
    """Schema for chat invitation response"""
    id: int
    from_user_id: int = Field(..., alias="fromUserId")
    to_user_id: int = Field(..., alias="toUserId")
    message: Optional[str] = None
    status: str
    conversation_id: Optional[int] = Field(None, alias="conversationId")
    created_at: datetime = Field(..., alias="createdAt")
    from_user: Optional[InvitationParticipant] = Field(None, alias="fromUser")
    to_user: Optional[InvitationParticipant] = Field(None, alias="toUser")

    model_config = ConfigDict(populate_by_name=True, from_attributes=True)


class InvitationListResponse(BaseModel):
    """List of invitations"""
    items: List[InvitationResponse]
    total: int


class ChatWithUserResponse(BaseModel):
    """Response for 'get chat status with user' - conversation and/or pending invitation"""
    conversation: Optional[ConversationResponse] = None
    pending_invitation_from_me: Optional[InvitationResponse] = Field(None, alias="pendingInvitationFromMe")
    pending_invitation_from_them: Optional[InvitationResponse] = Field(None, alias="pendingInvitationFromThem")

    model_config = ConfigDict(populate_by_name=True)
