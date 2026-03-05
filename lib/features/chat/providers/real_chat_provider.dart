import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'package:linkedin_clone/core/config/env.dart';
import 'package:linkedin_clone/core/services/token_storage.dart';

// ─── Models ───────────────────────────────────────────────────────────────────

class MessageModel {
  final int id;
  final int conversationId;
  final int senderId;
  final String content;
  final String status; // sent | delivered | read
  final DateTime createdAt;
  final DateTime? readAt;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.status,
    required this.createdAt,
    this.readAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? 0,
      conversationId: json['conversationId'] ?? 0,
      senderId: json['senderId'] ?? 0,
      content: json['content'] ?? '',
      status: json['status'] ?? 'sent',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      readAt: json['readAt'] != null ? DateTime.tryParse(json['readAt']) : null,
    );
  }

  MessageModel copyWith({String? status, DateTime? readAt}) {
    return MessageModel(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      content: content,
      status: status ?? this.status,
      createdAt: createdAt,
      readAt: readAt ?? this.readAt,
    );
  }
}

class ParticipantModel {
  final int id;
  final String firstName;
  final String lastName;
  final String? avatar;

  ParticipantModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.avatar,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    final av = json['avatar'] as String?;
    return ParticipantModel(
      id: json['id'] ?? 0,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      avatar: (av != null && av.isNotEmpty) ? av : null,
    );
  }
}

class ConversationModel {
  final int id;
  final int employerId;
  final int applicantId;
  final ParticipantModel? employer;
  final ParticipantModel? applicant;
  final MessageModel? lastMessage;
  final int unreadCount;
  final String? jobTitle;

  ConversationModel({
    required this.id,
    required this.employerId,
    required this.applicantId,
    this.employer,
    this.applicant,
    this.lastMessage,
    this.unreadCount = 0,
    this.jobTitle,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] ?? 0,
      employerId: json['employerId'] ?? 0,
      applicantId: json['applicantId'] ?? 0,
      employer: json['employer'] != null ? ParticipantModel.fromJson(json['employer']) : null,
      applicant: json['applicant'] != null ? ParticipantModel.fromJson(json['applicant']) : null,
      lastMessage: json['lastMessage'] != null ? MessageModel.fromJson(json['lastMessage']) : null,
      unreadCount: json['unreadCount'] ?? 0,
      jobTitle: json['jobTitle'],
    );
  }

  ParticipantModel? otherParticipant(int myUserId) {
    if (employerId == myUserId) return applicant;
    return employer;
  }
}

// ─── Conversation List State ───────────────────────────────────────────────────

class ConversationListState {
  final List<ConversationModel> conversations;
  final bool isLoading;
  final String? error;

  ConversationListState({
    this.conversations = const [],
    this.isLoading = false,
    this.error,
  });

  ConversationListState copyWith({
    List<ConversationModel>? conversations,
    bool? isLoading,
    String? error,
  }) {
    return ConversationListState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ConversationListNotifier extends StateNotifier<ConversationListState> {
  ConversationListNotifier() : super(ConversationListState());

  Future<Map<String, String>> _headers() async {
    const s = TokenStorage();
    final String? token = await s.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final String url = '${Environment.apiBaseUrl}/api/${Environment.apiVersion}/chat?skip=0&limit=50';
      final http.Response response = await http.get(Uri.parse(url), headers: await _headers());
      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        final List<ConversationModel> items = (data['items'] as List? ?? [])
            .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
            .toList();
        state = state.copyWith(conversations: items, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: 'Suhbatlarni yuklashda xatolik');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateLastMessage(int conversationId, MessageModel message) {
    final updated = state.conversations.map((c) {
      if (c.id == conversationId) {
        return ConversationModel(
          id: c.id,
          employerId: c.employerId,
          applicantId: c.applicantId,
          employer: c.employer,
          applicant: c.applicant,
          lastMessage: message,
          unreadCount: c.unreadCount + 1,
          jobTitle: c.jobTitle,
        );
      }
      return c;
    }).toList();
    // Move updated conversation to top
    updated.sort((a, b) {
      final aTime = a.lastMessage?.createdAt ?? DateTime(0);
      final bTime = b.lastMessage?.createdAt ?? DateTime(0);
      return bTime.compareTo(aTime);
    });
    state = state.copyWith(conversations: updated);
  }
}

final conversationListProvider =
    StateNotifierProvider<ConversationListNotifier, ConversationListState>((ref) {
  return ConversationListNotifier();
});

// ─── Chat Room State ───────────────────────────────────────────────────────────

class ChatRoomState {
  final ConversationModel? conversation;
  final List<MessageModel> messages;
  final bool isLoading;
  final bool isSending;
  final bool isConnected;
  final String? error;

  ChatRoomState({
    this.conversation,
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.isConnected = false,
    this.error,
  });

  ChatRoomState copyWith({
    ConversationModel? conversation,
    List<MessageModel>? messages,
    bool? isLoading,
    bool? isSending,
    bool? isConnected,
    String? error,
  }) {
    return ChatRoomState(
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      isConnected: isConnected ?? this.isConnected,
      error: error,
    );
  }
}

class ChatRoomNotifier extends StateNotifier<ChatRoomState> {
  final int conversationId;
  WebSocketChannel? _channel;

  ChatRoomNotifier(this.conversationId) : super(ChatRoomState());

  Future<Map<String, String>> _headers() async {
    const s = TokenStorage();
    final String? token = await s.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<String?> _getToken() async {
    const s = TokenStorage();
    return s.getAccessToken();
  }

  /// Load conversation info + message history, then connect WS
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final Map<String, String> headers = await _headers();

      // 1. Load conversation info
      final String convUrl = '${Environment.apiBaseUrl}/api/${Environment.apiVersion}/chat/$conversationId';
      final http.Response convResp = await http.get(Uri.parse(convUrl), headers: headers);
      ConversationModel? conversation;
      if (convResp.statusCode == 200) {
        conversation = ConversationModel.fromJson(jsonDecode(convResp.body) as Map<String, dynamic>);
      }

      // 2. Load message history
      final String msgUrl = '${Environment.apiBaseUrl}/api/${Environment.apiVersion}/chat/$conversationId/messages?skip=0&limit=50';
      final http.Response msgResp = await http.get(Uri.parse(msgUrl), headers: headers);
      List<MessageModel> messages = [];
      if (msgResp.statusCode == 200) {
        final dynamic data = jsonDecode(msgResp.body);
        messages = (data['items'] as List? ?? [])
            .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      state = state.copyWith(
        conversation: conversation,
        messages: messages,
        isLoading: false,
      );

      // 3. Connect WebSocket
      await _connectWebSocket();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> _connectWebSocket() async {
    final String? token = await _getToken();
    if (token == null) return;

    // Build WebSocket URL from HTTP URL
    final String baseUrl = Environment.apiBaseUrl
        .replaceFirst('https://', 'wss://')
        .replaceFirst('http://', 'ws://');
    final String wsUrl = '$baseUrl/ws/chat?token=$token';

    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      state = state.copyWith(isConnected: true);

      // Join the conversation room
      _send({'type': 'join', 'conversation_id': conversationId});

      // Mark all as read when we join
      _send({'type': 'read', 'conversation_id': conversationId});

      // Listen to incoming messages
      _channel!.stream.listen(
        (raw) => _handleMessage(raw),
        onError: (_) => _onDisconnect(),
        onDone: () => _onDisconnect(),
        cancelOnError: false,
      );
    } catch (e) {
      state = state.copyWith(isConnected: false);
    }
  }

  void _handleMessage(dynamic raw) {
    try {
      final Map<String, dynamic> json = jsonDecode(raw.toString()) as Map<String, dynamic>;
      final String? type = json['type'] as String?;
      final Map<String, dynamic> data = json['data'] as Map<String, dynamic>? ?? {};

      switch (type) {
        case 'new_message':
          final message = MessageModel.fromJson(data);
          // Add message if not already present
          if (!state.messages.any((m) => m.id == message.id)) {
            final updated = [...state.messages, message];
            state = state.copyWith(messages: updated);
            // If received (not mine), mark as delivered
            // The backend does this automatically if we're viewing
          }
          break;

        case 'message_delivered':
          final messageId = data['messageId'] as int?;
          if (messageId != null) {
            final updated = state.messages.map((m) {
              if (m.id == messageId && m.status == 'sent') {
                return m.copyWith(status: 'delivered');
              }
              return m;
            }).toList();
            state = state.copyWith(messages: updated);
          }
          break;

        case 'message_read':
        case 'messages_read':
          final updated = state.messages.map((m) {
            if (m.status != 'read') return m.copyWith(status: 'read');
            return m;
          }).toList();
          state = state.copyWith(messages: updated);
          break;
      }
    } catch (_) {}
  }

  void _send(Map<String, dynamic> data) {
    try {
      _channel?.sink.add(jsonEncode(data));
    } catch (_) {}
  }

  void _onDisconnect() {
    state = state.copyWith(isConnected: false);
  }

  /// Send a message via WebSocket
  void sendMessage(String content) {
    if (content.trim().isEmpty || !state.isConnected) return;
    _send({
      'type': 'message',
      'conversation_id': conversationId,
      'content': content.trim(),
    });
  }

  /// Mark conversation as read (call when user opens chat)
  void markAsRead() {
    _send({'type': 'read', 'conversation_id': conversationId});
  }

  @override
  void dispose() {
    // Leave conversation and close WS
    _send({'type': 'leave', 'conversation_id': conversationId});
    _channel?.sink.close();
    super.dispose();
  }
}

final chatRoomProvider = StateNotifierProvider.family<ChatRoomNotifier, ChatRoomState, int>(
  (ref, conversationId) => ChatRoomNotifier(conversationId),
);
