import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/env.dart';
import '../../../core/network/api_client.dart';

class PasswordResetState {
  final bool isLoading;
  final String? errorMessage;

  PasswordResetState({this.isLoading = false, this.errorMessage});

  PasswordResetState copyWith({bool? isLoading, String? errorMessage}) {
    return PasswordResetState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class PasswordResetNotifier extends StateNotifier<PasswordResetState> {
  PasswordResetNotifier() : super(PasswordResetState());

  String _extractError(http.Response response, String fallback) {
    try {
      final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['message'] ?? data['detail'] ?? data['error'] ?? fallback).toString();
    } catch (_) {
      return fallback;
    }
  }

  Future<bool> requestCode(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final Uri uri = Uri.parse(
        '${Environment.apiBaseUrl}/api/${Environment.apiVersion}/auth/forgot-password',
      );
      final http.Response response = await ApiClient.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        state = state.copyWith(isLoading: false);
        return true;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: _extractError(response, 'Kod yuborishda xatolik yuz berdi'),
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Xatolik: $e');
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final Uri uri = Uri.parse(
        '${Environment.apiBaseUrl}/api/${Environment.apiVersion}/auth/reset-password',
      );
      final http.Response response = await ApiClient.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'code': code,
          'email': email,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        state = state.copyWith(isLoading: false);
        return true;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: _extractError(response, 'Parolni tiklashda xatolik yuz berdi'),
      );
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Xatolik: $e');
      return false;
    }
  }
}

final passwordResetProvider =
    StateNotifierProvider.autoDispose<PasswordResetNotifier, PasswordResetState>((ref) {
  return PasswordResetNotifier();
});
