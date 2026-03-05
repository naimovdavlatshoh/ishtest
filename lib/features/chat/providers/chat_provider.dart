import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/message_model.dart';

class ChatListState {
  final List<ChatModel> chats;
  final bool isLoading;
  final String? errorMessage;

  ChatListState({
    this.chats = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ChatListState copyWith({
    List<ChatModel>? chats,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ChatListState(
      chats: chats ?? this.chats,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ChatListNotifier extends StateNotifier<ChatListState> {
  ChatListNotifier() : super(ChatListState()) {
    loadChats();
  }

  Future<void> loadChats() async {
    state = state.copyWith(isLoading: true);

    try {
      // API call to be implemented
      await Future.delayed(const Duration(milliseconds: 500));
      
      state = state.copyWith(
        chats: [], // Replace with real API call later
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}

class ChatRoomState {
  final ChatModel? chat;
  final List<MessageModel> messages;
  final bool isLoading;
  final String? errorMessage;
  final bool isSending;

  ChatRoomState({
    this.chat,
    this.messages = const [],
    this.isLoading = false,
    this.errorMessage,
    this.isSending = false,
  });

  ChatRoomState copyWith({
    ChatModel? chat,
    List<MessageModel>? messages,
    bool? isLoading,
    String? errorMessage,
    bool? isSending,
  }) {
    return ChatRoomState(
      chat: chat ?? this.chat,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isSending: isSending ?? this.isSending,
    );
  }
}

class ChatRoomNotifier extends StateNotifier<ChatRoomState> {
  final String chatId;

  ChatRoomNotifier(this.chatId) : super(ChatRoomState()) {
    loadChat();
  }

  Future<void> loadChat() async {
    state = state.copyWith(isLoading: true);

    try {
      // API call to be implemented
      await Future.delayed(const Duration(milliseconds: 500));
      
      state = state.copyWith(
        chat: null, // Replace with real API call later
        messages: [], // Replace with real API call later
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> sendMessage(String content, String senderId) async {
    if (content.trim().isEmpty) return;

    state = state.copyWith(isSending: true);

    try {
      // API call to be implemented
      await Future.delayed(const Duration(milliseconds: 300));

      final MessageModel newMessage = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: chatId,
        senderId: senderId,
        content: content,
        timestamp: DateTime.now(),
        isRead: false,
      );

      final List<MessageModel> updatedMessages = [...state.messages, newMessage];

      state = state.copyWith(
        messages: updatedMessages,
        isSending: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        errorMessage: e.toString(),
      );
    }
  }
}

final chatListProvider = StateNotifierProvider<ChatListNotifier, ChatListState>((ref) {
  return ChatListNotifier();
});

final chatRoomProvider = StateNotifierProvider.family<ChatRoomNotifier, ChatRoomState, String>(
  (ref, chatId) {
    return ChatRoomNotifier(chatId);
  },
);
