import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'package:linkedin_clone/core/config/env.dart';
import 'package:linkedin_clone/core/services/token_storage.dart';

/// Global unread message count state
class GlobalChatState {
  final int totalUnread;
  final bool isConnected;
  // conversationId -> unreadCount
  final Map<int, int> unreadByConversation;

  const GlobalChatState({
    this.totalUnread = 0,
    this.isConnected = false,
    this.unreadByConversation = const {},
  });

  GlobalChatState copyWith({
    int? totalUnread,
    bool? isConnected,
    Map<int, int>? unreadByConversation,
  }) {
    return GlobalChatState(
      totalUnread: totalUnread ?? this.totalUnread,
      isConnected: isConnected ?? this.isConnected,
      unreadByConversation: unreadByConversation ?? this.unreadByConversation,
    );
  }
}

class GlobalChatNotifier extends StateNotifier<GlobalChatState> {
  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  bool _disposed = false;

  GlobalChatNotifier() : super(const GlobalChatState()) {
    _initialize();
  }

  Future<String?> _getToken() async {
    const s = TokenStorage();
    return s.getAccessToken();
  }

  Future<void> _initialize() async {
    // First, fetch total unread count via REST
    await _fetchUnreadCount();
    // Then connect WebSocket for real-time
    await _connect();
  }

  Future<void> _fetchUnreadCount() async {
    try {
      const s = TokenStorage();
      final String? token = await s.getAccessToken();
      if (token == null) return;

      final String url = '${Environment.apiBaseUrl}/api/${Environment.apiVersion}/chat?skip=0&limit=50';
      final http.Response response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        final List<dynamic> items = data['items'] as List? ?? [];
        int total = 0;
        final Map<int, int> byConv = {};
        for (final item in items) {
          final convId = item['id'] as int? ?? 0;
          final unread = item['unreadCount'] as int? ?? 0;
          byConv[convId] = unread;
          total += unread;
        }
        if (!_disposed) {
          state = state.copyWith(
            totalUnread: total,
            unreadByConversation: byConv,
          );
        }
      }
    } catch (_) {}
  }

  Future<void> _connect() async {
    if (_disposed) return;
    final String? token = await _getToken();
    if (token == null) return;

    final String baseUrl = Environment.apiBaseUrl
        .replaceFirst('https://', 'wss://')
        .replaceFirst('http://', 'ws://');
    final String wsUrl = '$baseUrl/ws/chat?token=$token';

    try {
      _channel?.sink.close();
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      if (!_disposed) state = state.copyWith(isConnected: true);

      _channel!.stream.listen(
        _onMessage,
        onError: (_) => _onDisconnect(),
        onDone: () => _onDisconnect(),
        cancelOnError: false,
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic raw) {
    if (_disposed) return;
    try {
      final Map<String, dynamic> json = jsonDecode(raw.toString()) as Map<String, dynamic>;
      final String? type = json['type'] as String?;
      final Map<String, dynamic> data = json['data'] as Map<String, dynamic>? ?? {};

      if (type == 'new_message') {
        final int convId = data['conversationId'] as int? ?? 0;
        final Map<int, int> updated = Map.from(state.unreadByConversation);
        updated[convId] = (updated[convId] ?? 0) + 1;
        state = state.copyWith(
          totalUnread: state.totalUnread + 1,
          unreadByConversation: updated,
        );
      } else if (type == 'messages_read') {
        final int convId = data['conversationId'] as int? ?? 0;
        final Map<int, int> updated = Map.from(state.unreadByConversation);
        final removed = updated[convId] ?? 0;
        updated[convId] = 0;
        final newTotal = (state.totalUnread - removed).clamp(0, 99999);
        state = state.copyWith(
          totalUnread: newTotal,
          unreadByConversation: updated,
        );
      }
    } catch (_) {}
  }

  /// Call this when user opens a conversation (so we clear its badge)
  void markConversationRead(int conversationId) {
    final Map<int, int> updated = Map.from(state.unreadByConversation);
    final removed = updated[conversationId] ?? 0;
    updated[conversationId] = 0;
    final newTotal = (state.totalUnread - removed).clamp(0, 99999);
    state = state.copyWith(
      totalUnread: newTotal,
      unreadByConversation: updated,
    );
    // Also tell server via WS
    _sendWS({'type': 'read', 'conversation_id': conversationId});
  }

  void _sendWS(Map<String, dynamic> data) {
    try {
      _channel?.sink.add(jsonEncode(data));
    } catch (_) {}
  }

  void _onDisconnect() {
    if (_disposed) return;
    state = state.copyWith(isConnected: false);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    if (!_disposed) {
      _reconnectTimer = Timer(const Duration(seconds: 5), _connect);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    super.dispose();
  }
}

// Keep alive — don't use autoDispose
final globalChatProvider = StateNotifierProvider<GlobalChatNotifier, GlobalChatState>(
  (ref) => GlobalChatNotifier(),
);

/// Convenience provider for total unread count
final totalUnreadProvider = Provider<int>((ref) {
  return ref.watch(globalChatProvider).totalUnread;
});
