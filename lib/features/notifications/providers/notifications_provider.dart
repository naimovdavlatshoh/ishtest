import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:linkedin_clone/core/network/api_client.dart';
import 'package:linkedin_clone/shared/models/notification_item_model.dart';
import 'package:linkedin_clone/core/config/env.dart';
import 'package:linkedin_clone/core/services/token_storage.dart';

class NotificationsState {
  final List<NotificationItemModel> items;
  final bool isLoading;
  final String? errorMessage;
  final int unreadCount;

  NotificationsState({
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
    this.unreadCount = 0,
  });

  NotificationsState copyWith({
    List<NotificationItemModel>? items,
    bool? isLoading,
    String? errorMessage,
    int? unreadCount,
  }) {
    return NotificationsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  NotificationsNotifier() : super(NotificationsState()) {
    fetchUnreadCount();
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    const tokenStorage = TokenStorage();
    final String? token = await tokenStorage.getAccessToken();
    return {
      if (token != null) 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final Uri uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/notifications')
          .replace(queryParameters: {'skip': '0', 'limit': '50'});

      final http.Response response = await ApiClient.get(uri, headers: await _getAuthHeaders());

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic data = jsonDecode(response.body);
        final List<dynamic> rawItems = data['items'] ?? [];
        final items = rawItems.map((e) => NotificationItemModel.fromJson(e)).toList();
        final int unread = data['unreadCount'] as int? ?? 0;

        state = state.copyWith(items: items, unreadCount: unread, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, errorMessage: "Bildirishnomalarni yuklashda xatolik yuz berdi");
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Xatolik: $e');
    }
  }

  /// Lightweight fetch of just the unread count, so the drawer badge can be
  /// populated without loading the full notification list first.
  Future<void> fetchUnreadCount() async {
    try {
      final Uri uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/notifications/unread-count');
      final http.Response response = await ApiClient.get(uri, headers: await _getAuthHeaders());

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic data = jsonDecode(response.body);
        final int count = data['count'] as int? ?? 0;
        state = state.copyWith(unreadCount: count);
      }
    } catch (_) {}
  }

  Future<void> markRead(int notificationId) async {
    final int index = state.items.indexWhere((n) => n.id == notificationId);
    if (index == -1 || state.items[index].isRead) return;

    final List<NotificationItemModel> updated = [...state.items];
    updated[index] = updated[index].copyWith(isRead: true);
    state = state.copyWith(items: updated, unreadCount: (state.unreadCount - 1).clamp(0, 999999));

    try {
      final Map<String, String> headers = await _getAuthHeaders();
      final Uri uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/notifications/$notificationId/read');
      await ApiClient.patch(uri, headers: headers);
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    final List<NotificationItemModel> updated = state.items.map((n) => n.copyWith(isRead: true)).toList();
    state = state.copyWith(items: updated, unreadCount: 0);

    try {
      final Map<String, String> headers = await _getAuthHeaders();
      final Uri uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/notifications/read-all');
      await ApiClient.patch(uri, headers: headers);
    } catch (_) {}
  }
}

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier();
});

/// Convenience provider for badge UI (e.g. the drawer) that only needs the count.
final notificationsUnreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).unreadCount;
});
