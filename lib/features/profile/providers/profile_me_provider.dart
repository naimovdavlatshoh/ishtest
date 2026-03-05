import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../../core/config/env.dart';
import '../../../core/services/token_storage.dart';
import '../../../shared/models/profile_me_model.dart';

class ProfileMeState {
  final ProfileMe? profile;
  final bool isLoading;
  final String? error;

  ProfileMeState({this.profile, this.isLoading = false, this.error});

  ProfileMeState copyWith({ProfileMe? profile, bool? isLoading, String? error}) {
    return ProfileMeState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ProfileMeNotifier extends StateNotifier<AsyncValue<ProfileMe>> {
  ProfileMeNotifier() : super(const AsyncValue.loading()) {
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    state = const AsyncValue.loading();
    try {
      const tokenStorage = TokenStorage();
      final String? token = await tokenStorage.getAccessToken();

      if (token == null || token.isEmpty) {
        throw Exception('Access token not found');
      }

      final Uri uri = Uri.parse(
        '${Environment.apiBaseUrl}/api/${Environment.apiVersion}/profiles/me',
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
        state = AsyncValue.data(ProfileMe.fromJson(data));
      } else {
        throw Exception('Failed to load profile info');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      const tokenStorage = TokenStorage();
      final String? token = await tokenStorage.getAccessToken();

      if (token == null || token.isEmpty) return false;

      final Uri uri = Uri.parse(
        '${Environment.apiBaseUrl}/api/${Environment.apiVersion}/profiles/me',
      );

      final http.Response response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await fetchProfile(); // Refresh data after update
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> uploadFile(String filePath) async {
    try {
      const tokenStorage = TokenStorage();
      final String? token = await tokenStorage.getAccessToken();

      if (token == null || token.isEmpty) return false;

      final Uri uri = Uri.parse(
        '${Environment.apiBaseUrl}/api/${Environment.apiVersion}/profiles/me',
      );

      final http.MultipartRequest request = http.MultipartRequest('PUT', uri);
      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(
        await http.MultipartFile.fromPath(
          'cvFile',
          filePath,
          contentType: MediaType('application', 'pdf'), // Default to PDF for CV
        ),
      );

      final streamedResponse = await request.send();
      final http.Response response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await fetchProfile();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> linkTelegram(String code) async {
    try {
      const tokenStorage = TokenStorage();
      final String? token = await tokenStorage.getAccessToken();

      if (token == null || token.isEmpty) return false;

      final Uri uri = Uri.parse(
        '${Environment.apiBaseUrl}/api/${Environment.apiVersion}/auth/telegram/link',
      );

      final http.Response response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'code': code}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await fetchProfile();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

final profileMeProvider =
    StateNotifierProvider.autoDispose<ProfileMeNotifier, AsyncValue<ProfileMe>>(
        (ref) {
  return ProfileMeNotifier();
});

