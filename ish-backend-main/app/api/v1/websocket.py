"""
WebSocket endpoint for real-time chat
"""
from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends, Query
from sqlalchemy.orm import Session
from typing import Dict, Set
import json
from datetime import datetime

from app.database.session import get_db
from app.utils.security import decode_access_token
from app.services.chat_service import ChatService
from app.repositories.chat_repository import ConversationRepository, MessageRepository
from app.schemas.chat_schema import MessageCreate, WSMessageType

router = APIRouter()


class ConnectionManager:
    """Manages WebSocket connections"""
    
    def __init__(self):
        # Map: user_id -> set of websockets
        self.active_connections: Dict[int, Set[WebSocket]] = {}
        # Map: conversation_id -> set of user_ids currently viewing
        self.conversation_viewers: Dict[int, Set[int]] = {}
    
    async def connect(self, websocket: WebSocket, user_id: int):
        """Accept connection and register user"""
        await websocket.accept()
        if user_id not in self.active_connections:
            self.active_connections[user_id] = set()
        self.active_connections[user_id].add(websocket)
    
    def disconnect(self, websocket: WebSocket, user_id: int):
        """Remove connection"""
        if user_id in self.active_connections:
            self.active_connections[user_id].discard(websocket)
            if not self.active_connections[user_id]:
                del self.active_connections[user_id]
        
        # Remove from all conversation viewers
        for viewers in self.conversation_viewers.values():
            viewers.discard(user_id)
    
    def join_conversation(self, conversation_id: int, user_id: int):
        """Mark user as viewing a conversation"""
        if conversation_id not in self.conversation_viewers:
            self.conversation_viewers[conversation_id] = set()
        self.conversation_viewers[conversation_id].add(user_id)
    
    def leave_conversation(self, conversation_id: int, user_id: int):
        """Mark user as not viewing a conversation"""
        if conversation_id in self.conversation_viewers:
            self.conversation_viewers[conversation_id].discard(user_id)
    
    def is_user_viewing_conversation(self, conversation_id: int, user_id: int) -> bool:
        """Check if user is currently viewing a conversation"""
        return (
            conversation_id in self.conversation_viewers and 
            user_id in self.conversation_viewers[conversation_id]
        )
    
    async def send_to_user(self, user_id: int, message: dict):
        """Send message to all connections of a user"""
        if user_id in self.active_connections:
            disconnected = set()
            for websocket in self.active_connections[user_id]:
                try:
                    await websocket.send_json(message)
                except Exception:
                    disconnected.add(websocket)
            
            # Clean up disconnected
            for ws in disconnected:
                self.active_connections[user_id].discard(ws)
    
    async def broadcast_to_conversation(
        self, 
        conversation_id: int, 
        message: dict, 
        exclude_user_id: int = None
    ):
        """Send message to all participants of a conversation"""
        if conversation_id in self.conversation_viewers:
            for user_id in self.conversation_viewers[conversation_id]:
                if user_id != exclude_user_id:
                    await self.send_to_user(user_id, message)


manager = ConnectionManager()


def authenticate_websocket(token: str) -> int:
    """Authenticate WebSocket connection and return user_id"""
    try:
        payload = decode_access_token(token)
        user_id = payload.get("sub")
        if not user_id:
            return None
        return int(user_id)
    except Exception:
        return None


@router.websocket("/chat")
async def websocket_endpoint(
    websocket: WebSocket,
    token: str = Query(...)
):
    """
    WebSocket endpoint for real-time chat.
    
    Connect with: ws://host/ws/chat?token=<jwt_token>
    
    Message format (client -> server):
    - {"type": "join", "conversation_id": 123}
    - {"type": "leave", "conversation_id": 123}
    - {"type": "message", "conversation_id": 123, "content": "Hello!"}
    - {"type": "read", "conversation_id": 123}
    - {"type": "delivered", "message_id": 456}
    
    Message format (server -> client):
    - {"type": "new_message", "data": {...message data...}}
    - {"type": "message_delivered", "data": {"message_id": 456}}
    - {"type": "message_read", "data": {"message_id": 456}}
    - {"type": "messages_read", "data": {"conversation_id": 123, "count": 5}}
    - {"type": "error", "data": {"message": "Error description"}}
    """
    # Authenticate
    user_id = authenticate_websocket(token)
    if not user_id:
        await websocket.close(code=4001, reason="Invalid or expired token")
        return
    
    await manager.connect(websocket, user_id)
    
    try:
        while True:
            data = await websocket.receive_json()
            msg_type = data.get("type")
            
            # Get database session for each operation
            db = next(get_db())
            
            try:
                if msg_type == "join":
                    conversation_id = data.get("conversation_id")
                    if conversation_id:
                        # Verify user is participant
                        try:
                            ChatService.get_conversation(db, conversation_id, user_id)
                            manager.join_conversation(conversation_id, user_id)
                        except Exception as e:
                            await websocket.send_json({
                                "type": WSMessageType.ERROR,
                                "data": {"message": str(e)}
                            })
                
                elif msg_type == "leave":
                    conversation_id = data.get("conversation_id")
                    if conversation_id:
                        manager.leave_conversation(conversation_id, user_id)
                
                elif msg_type == "message":
                    conversation_id = data.get("conversation_id")
                    content = data.get("content")
                    
                    if conversation_id and content:
                        try:
                            message = ChatService.send_message(
                                db, conversation_id, user_id, 
                                MessageCreate(content=content)
                            )
                            
                            # Get conversation to find recipient
                            conversation = ConversationRepository.get_by_id(db, conversation_id)
                            recipient_id = (
                                conversation.applicant_id 
                                if conversation.employer_id == user_id 
                                else conversation.employer_id
                            )
                            
                            message_data = {
                                "id": message.id,
                                "conversationId": message.conversation_id,
                                "senderId": message.sender_id,
                                "content": message.content,
                                "status": message.status,
                                "createdAt": message.created_at.isoformat(),
                                "readAt": None
                            }
                            
                            # Send to sender (confirmation)
                            await websocket.send_json({
                                "type": WSMessageType.NEW_MESSAGE,
                                "data": message_data
                            })
                            
                            # Send to recipient
                            await manager.send_to_user(recipient_id, {
                                "type": WSMessageType.NEW_MESSAGE,
                                "data": message_data
                            })
                            
                            # If recipient is viewing the conversation, auto-deliver
                            if manager.is_user_viewing_conversation(conversation_id, recipient_id):
                                MessageRepository.mark_as_delivered(db, message)
                                await websocket.send_json({
                                    "type": WSMessageType.MESSAGE_DELIVERED,
                                    "data": {"messageId": message.id}
                                })
                            
                        except Exception as e:
                            await websocket.send_json({
                                "type": WSMessageType.ERROR,
                                "data": {"message": str(e)}
                            })
                
                elif msg_type == "read":
                    conversation_id = data.get("conversation_id")
                    if conversation_id:
                        try:
                            count = ChatService.mark_conversation_as_read(
                                db, conversation_id, user_id
                            )
                            
                            # Notify the other user
                            conversation = ConversationRepository.get_by_id(db, conversation_id)
                            other_user_id = (
                                conversation.applicant_id 
                                if conversation.employer_id == user_id 
                                else conversation.employer_id
                            )
                            
                            await manager.send_to_user(other_user_id, {
                                "type": WSMessageType.MESSAGES_READ,
                                "data": {
                                    "conversationId": conversation_id,
                                    "readBy": user_id,
                                    "count": count
                                }
                            })
                        except Exception as e:
                            await websocket.send_json({
                                "type": WSMessageType.ERROR,
                                "data": {"message": str(e)}
                            })
                
                elif msg_type == "delivered":
                    message_id = data.get("message_id")
                    if message_id:
                        try:
                            message = ChatService.mark_message_as_delivered(
                                db, message_id, user_id
                            )
                            
                            # Notify sender
                            await manager.send_to_user(message.sender_id, {
                                "type": WSMessageType.MESSAGE_DELIVERED,
                                "data": {"messageId": message_id}
                            })
                        except Exception as e:
                            pass  # Silently ignore delivery errors
            
            finally:
                db.close()
    
    except WebSocketDisconnect:
        manager.disconnect(websocket, user_id)
    except Exception:
        manager.disconnect(websocket, user_id)
