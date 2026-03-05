import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/env.dart';
import '../../../core/services/token_storage.dart';
import '../../../shared/models/user_me_model.dart';

class UserMeNotifier extends StateNotifier<AsyncValue<UserMe>> {
  UserMeNotifier() : super(const AsyncValue.loading()) {
    fetchUserMe();
  }

  Future<void> fetchUserMe() async {
    state = const AsyncValue.loading();
    try {
      const tokenStorage = TokenStorage();
      final String? token = await tokenStorage.getAccessToken();

      if (token == null || token.isEmpty) {
        throw Exception('Access token not found');
      }

      final Uri uri = Uri.parse(
        '${Environment.apiBaseUrl}/api/${Environment.apiVersion}/users/me',
      );

      final http.Response response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        state = AsyncValue.data(UserMe.fromJson(data));
      } else {
        throw Exception('Failed to load user info');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final userMeProvider =
    StateNotifierProvider.autoDispose<UserMeNotifier, AsyncValue<UserMe>>(
        (ref) {
  return UserMeNotifier();
});
