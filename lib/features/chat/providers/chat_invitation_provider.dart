import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/env.dart';
import '../../../core/services/token_storage.dart';

class ChatInvitationNotifier extends StateNotifier<AsyncValue<void>> {
  ChatInvitationNotifier() : super(const AsyncValue.data(null));

  Future<Map<String, String>> _getAuthHeaders() async {
    const tokenStorage = TokenStorage();
    final String? token = await tokenStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> checkExistingChat(int userId) async {
    try {
      final Map<String, String> headers = await _getAuthHeaders();
      final String url = '${Environment.apiBaseUrl}/api/${Environment.apiVersion}/chat/with-user/$userId';
      final http.Response response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> sendInvitation(int toUserId, String message) async {
    state = const AsyncValue.loading();
    try {
      final Map<String, String> headers = await _getAuthHeaders();
      final String url = '${Environment.apiBaseUrl}/api/${Environment.apiVersion}/invitations';
      
      final http.Response response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({
          'message': message,
          'toUserId': toUserId,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        state = const AsyncValue.data(null);
        return true;
      } else {
        state = AsyncValue.error('Xatolik: ${response.statusCode}', StackTrace.current);
        return false;
      }
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
      return false;
    }
  }
}

final chatInvitationProvider = StateNotifierProvider<ChatInvitationNotifier, AsyncValue<void>>((ref) {
  return ChatInvitationNotifier();
});
