"""
Chat repository for database operations
"""
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import or_, and_, func, desc
from typing import List, Optional, Tuple
from datetime import datetime

from app.database.models import Conversation, Message, User


class ConversationRepository:
    """Repository for conversation operations"""
    
    @staticmethod
    def get_by_id(db: Session, conversation_id: int) -> Optional[Conversation]:
        """Get conversation by ID with relationships"""
        return db.query(Conversation).options(
            joinedload(Conversation.employer),
            joinedload(Conversation.applicant),
            joinedload(Conversation.application)
        ).filter(Conversation.id == conversation_id).first()
    
    @staticmethod
    def get_by_application_id(db: Session, application_id: int) -> Optional[Conversation]:
        """Get conversation by application ID"""
        return db.query(Conversation).filter(
            Conversation.application_id == application_id
        ).first()

    @staticmethod
    def get_direct_conversation(db: Session, user_id_1: int, user_id_2: int) -> Optional[Conversation]:
        """Get direct conversation (no application) between two users."""
        return db.query(Conversation).filter(
            Conversation.application_id.is_(None),
            or_(
                (Conversation.employer_id == user_id_1) & (Conversation.applicant_id == user_id_2),
                (Conversation.employer_id == user_id_2) & (Conversation.applicant_id == user_id_1),
            )
        ).first()

    @staticmethod
    def get_conversation_between_users(
        db: Session, user_id_1: int, user_id_2: int
    ) -> Optional[Conversation]:
        """Get any conversation (application or direct) between two users."""
        return db.query(Conversation).options(
            joinedload(Conversation.employer),
            joinedload(Conversation.applicant),
            joinedload(Conversation.application)
        ).filter(
            or_(
                (Conversation.employer_id == user_id_1) & (Conversation.applicant_id == user_id_2),
                (Conversation.employer_id == user_id_2) & (Conversation.applicant_id == user_id_1),
            )
        ).first()
    
    @staticmethod
    def get_user_conversations(
        db: Session, 
        user_id: int, 
        skip: int = 0, 
        limit: int = 20
    ) -> Tuple[List[Conversation], int]:
        """Get all conversations for a user with pagination"""
        query = db.query(Conversation).filter(
            or_(
                Conversation.employer_id == user_id,
                Conversation.applicant_id == user_id
            )
        ).options(
            joinedload(Conversation.employer),
            joinedload(Conversation.applicant),
            joinedload(Conversation.application)
        ).order_by(desc(Conversation.updated_at))
        
        total = query.count()
        conversations = query.offset(skip).limit(limit).all()
        
        return conversations, total
    
    @staticmethod
    def create(db: Session, data: dict) -> Conversation:
        """Create a new conversation"""
        conversation = Conversation(**data)
        db.add(conversation)
        db.commit()
        db.refresh(conversation)
        return conversation
    
    @staticmethod
    def update_timestamp(db: Session, conversation: Conversation) -> Conversation:
        """Update conversation's updated_at timestamp"""
        conversation.updated_at = datetime.utcnow()
        db.commit()
        db.refresh(conversation)
        return conversation
    
    @staticmethod
    def user_is_participant(conversation: Conversation, user_id: int) -> bool:
        """Check if user is a participant in the conversation"""
        return conversation.employer_id == user_id or conversation.applicant_id == user_id


class MessageRepository:
    """Repository for message operations"""
    
    @staticmethod
    def get_by_id(db: Session, message_id: int) -> Optional[Message]:
        """Get message by ID"""
        return db.query(Message).filter(Message.id == message_id).first()
    
    @staticmethod
    def get_conversation_messages(
        db: Session, 
        conversation_id: int, 
        skip: int = 0, 
        limit: int = 50,
        before_id: Optional[int] = None
    ) -> Tuple[List[Message], int, bool]:
        """Get messages for a conversation with pagination"""
        query = db.query(Message).filter(
            Message.conversation_id == conversation_id
        )
        
        if before_id:
            query = query.filter(Message.id < before_id)
        
        total = query.count()
        messages = query.order_by(desc(Message.created_at)).offset(skip).limit(limit + 1).all()
        
        has_more = len(messages) > limit
        if has_more:
            messages = messages[:limit]
        
        # Reverse to get chronological order
        messages.reverse()
        
        return messages, total, has_more
    
    @staticmethod
    def create(db: Session, data: dict) -> Message:
        """Create a new message"""
        message = Message(**data)
        db.add(message)
        db.commit()
        db.refresh(message)
        return message
    
    @staticmethod
    def mark_as_delivered(db: Session, message: Message) -> Message:
        """Mark message as delivered"""
        if message.status == "sent":
            message.status = "delivered"
            db.commit()
            db.refresh(message)
        return message
    
    @staticmethod
    def mark_as_read(db: Session, message: Message) -> Message:
        """Mark message as read"""
        if message.status != "read":
            message.status = "read"
            message.read_at = datetime.utcnow()
            db.commit()
            db.refresh(message)
        return message
    
    @staticmethod
    def mark_conversation_messages_as_read(
        db: Session, 
        conversation_id: int, 
        user_id: int
    ) -> int:
        """Mark all unread messages in a conversation as read (messages not sent by user)"""
        now = datetime.utcnow()
        result = db.query(Message).filter(
            and_(
                Message.conversation_id == conversation_id,
                Message.sender_id != user_id,
                Message.status != "read"
            )
        ).update({
            "status": "read",
            "read_at": now
        }, synchronize_session=False)
        db.commit()
        return result
    
    @staticmethod
    def get_unread_count(db: Session, conversation_id: int, user_id: int) -> int:
        """Get count of unread messages for a user in a conversation"""
        return db.query(Message).filter(
            and_(
                Message.conversation_id == conversation_id,
                Message.sender_id != user_id,
                Message.status != "read"
            )
        ).count()

    @staticmethod
    def get_total_unread_count_for_user(db: Session, user_id: int) -> int:
        """Get total count of unread messages for a user across all conversations"""
        return db.query(Message).join(Conversation).filter(
            or_(
                Conversation.employer_id == user_id,
                Conversation.applicant_id == user_id
            ),
            Message.sender_id != user_id,
            Message.status != "read"
        ).count()
    
    @staticmethod
    def get_last_message(db: Session, conversation_id: int) -> Optional[Message]:
        """Get the last message in a conversation"""
        return db.query(Message).filter(
            Message.conversation_id == conversation_id
        ).order_by(desc(Message.created_at)).first()
