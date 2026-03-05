"""
Chat service for business logic
"""
from sqlalchemy.orm import Session
from typing import List, Optional, Tuple

from app.repositories.chat_repository import ConversationRepository, MessageRepository
from app.repositories.job_repository import JobRepository
from app.database.models import Conversation, Message, Application
from app.schemas.chat_schema import MessageCreate
from app.exceptions.custom_exceptions import NotFoundError, ForbiddenError


class ChatService:
    """Service for chat operations"""
    
    @staticmethod
    def get_conversation(db: Session, conversation_id: int, user_id: int) -> Conversation:
        """Get conversation by ID, verifying user is a participant"""
        conversation = ConversationRepository.get_by_id(db, conversation_id)
        if not conversation:
            raise NotFoundError("Conversation", str(conversation_id))
        
        if not ConversationRepository.user_is_participant(conversation, user_id):
            raise ForbiddenError("You are not a participant in this conversation")
        
        return conversation
    
    @staticmethod
    def get_user_conversations(
        db: Session, 
        user_id: int, 
        skip: int = 0, 
        limit: int = 20
    ) -> Tuple[List[dict], int]:
        """Get all conversations for a user with additional data"""
        conversations, total = ConversationRepository.get_user_conversations(
            db, user_id, skip, limit
        )
        
        result = []
        for conv in conversations:
            # Get last message and unread count
            last_message = MessageRepository.get_last_message(db, conv.id)
            unread_count = MessageRepository.get_unread_count(db, conv.id, user_id)
            
            # Get job title from application
            job_title = None
            if conv.application and conv.application.job:
                job_title = conv.application.job.title
            
            result.append({
                "conversation": conv,
                "last_message": last_message,
                "unread_count": unread_count,
                "job_title": job_title
            })
        
        return result, total
    
    @staticmethod
    def create_conversation_for_application(
        db: Session,
        application: Application,
        employer_id: int
    ) -> Conversation:
        """Create a conversation when application is accepted"""
        # Check if conversation already exists
        existing = ConversationRepository.get_by_application_id(db, application.id)
        if existing:
            return existing

        conversation_data = {
            "application_id": application.id,
            "employer_id": employer_id,
            "applicant_id": application.applicant_id
        }

        return ConversationRepository.create(db, conversation_data)

    @staticmethod
    def create_conversation_for_invitation(
        db: Session,
        from_user_id: int,
        to_user_id: int
    ) -> Conversation:
        """Create a direct conversation when chat invitation is accepted."""
        existing = ConversationRepository.get_direct_conversation(db, from_user_id, to_user_id)
        if existing:
            return existing

        conversation_data = {
            "application_id": None,
            "employer_id": from_user_id,
            "applicant_id": to_user_id
        }
        return ConversationRepository.create(db, conversation_data)

    @staticmethod
    def get_conversation_with_user(
        db: Session,
        current_user_id: int,
        other_user_id: int
    ) -> Optional[Conversation]:
        """Get existing direct or application-based conversation between two users, if any."""
        return ConversationRepository.get_conversation_between_users(
            db, current_user_id, other_user_id
        )
    
    @staticmethod
    def get_messages(
        db: Session,
        conversation_id: int,
        user_id: int,
        skip: int = 0,
        limit: int = 50,
        before_id: Optional[int] = None
    ) -> Tuple[List[Message], int, bool]:
        """Get messages for a conversation"""
        # Verify user is participant
        conversation = ChatService.get_conversation(db, conversation_id, user_id)
        
        return MessageRepository.get_conversation_messages(
            db, conversation_id, skip, limit, before_id
        )
    
    @staticmethod
    def send_message(
        db: Session,
        conversation_id: int,
        sender_id: int,
        message_data: MessageCreate
    ) -> Message:
        """Send a message in a conversation"""
        # Verify sender is participant
        conversation = ChatService.get_conversation(db, conversation_id, sender_id)
        
        data = {
            "conversation_id": conversation_id,
            "sender_id": sender_id,
            "content": message_data.content
        }
        
        message = MessageRepository.create(db, data)
        
        # Update conversation timestamp
        ConversationRepository.update_timestamp(db, conversation)
        
        return message
    
    @staticmethod
    def mark_message_as_delivered(db: Session, message_id: int, user_id: int) -> Message:
        """Mark a message as delivered"""
        message = MessageRepository.get_by_id(db, message_id)
        if not message:
            raise NotFoundError("Message", str(message_id))
        
        # Verify user is the recipient (not the sender)
        conversation = ConversationRepository.get_by_id(db, message.conversation_id)
        if not ConversationRepository.user_is_participant(conversation, user_id):
            raise ForbiddenError("You are not a participant in this conversation")
        
        if message.sender_id == user_id:
            return message  # Sender can't mark their own message as delivered
        
        return MessageRepository.mark_as_delivered(db, message)
    
    @staticmethod
    def mark_message_as_read(db: Session, message_id: int, user_id: int) -> Message:
        """Mark a message as read"""
        message = MessageRepository.get_by_id(db, message_id)
        if not message:
            raise NotFoundError("Message", str(message_id))
        
        # Verify user is the recipient
        conversation = ConversationRepository.get_by_id(db, message.conversation_id)
        if not ConversationRepository.user_is_participant(conversation, user_id):
            raise ForbiddenError("You are not a participant in this conversation")
        
        if message.sender_id == user_id:
            return message  # Sender can't mark their own message as read
        
        return MessageRepository.mark_as_read(db, message)
    
    @staticmethod
    def mark_conversation_as_read(
        db: Session, 
        conversation_id: int, 
        user_id: int
    ) -> int:
        """Mark all messages in a conversation as read"""
        # Verify user is participant
        ChatService.get_conversation(db, conversation_id, user_id)
        
        return MessageRepository.mark_conversation_messages_as_read(
            db, conversation_id, user_id
        )
    
    @staticmethod
    def get_conversation_by_application(
        db: Session,
        application_id: int,
        user_id: int
    ) -> Optional[Conversation]:
        """Get conversation by application ID if user is participant"""
        conversation = ConversationRepository.get_by_application_id(db, application_id)
        if not conversation:
            return None
        
        if not ConversationRepository.user_is_participant(conversation, user_id):
            raise ForbiddenError("You are not a participant in this conversation")
        
        return conversation
