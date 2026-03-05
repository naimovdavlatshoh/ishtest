import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../shared/models/user_model.dart';
import '../../../core/config/env.dart';
import '../../../core/services/token_storage.dart';

class AuthState {
  final UserModel? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;

  AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({
    http.Client? client,
    TokenStorage? tokenStorage,
  })  : _client = client ?? http.Client(),
        _tokenStorage = tokenStorage ?? const TokenStorage(),
        super(AuthState());

  final http.Client _client;
  final TokenStorage _tokenStorage;

  Future<void> login(String phone, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      if (Environment.useMockData) {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 1));

        // Mock authentication - accept any credentials for demo
        if (phone.isNotEmpty && password.isNotEmpty) {
          final UserModel user = UserModel(
            id: '1',
            name: 'User',
            email: 'user@example.com',
            headline: 'Professional',
            location: 'Tashkent, Uzbekistan',
          );
          state = AuthState(
            user: user,
            isAuthenticated: true,
            isLoading: false,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'Invalid phone or password',
          );
        }
        return;
      }

      final Uri uri = Uri.parse(
        '${Environment.apiBaseUrl}/api/${Environment.apiVersion}/auth/login',
      );

      final http.Response response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone': phone,
          'password': password,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;

        final String? accessToken = data['access_token'] as String?;

        if (accessToken == null || accessToken.isEmpty) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'Login failed: access token missing',
          );
          return;
        }

        await _tokenStorage.saveAccessToken(accessToken);

        // Backend does not provide full user details in auth response,
        // so we just mark the user as authenticated.
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          errorMessage: null,
        );
      } else {
        String errorMessage = 'Login failed. Please try again.';
        try {
          final Map<String, dynamic> errorData =
              jsonDecode(response.body) as Map<String, dynamic>;
          errorMessage = (errorData['message'] ??
                  errorData['detail'] ??
                  errorData['error'] ??
                  errorMessage)
              .toString();
        } catch (_) {
          // Ignore JSON parse errors and use default message
        }

        state = state.copyWith(
          isLoading: false,
          errorMessage: errorMessage,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> register(
    String firstName,
    String lastName,
    String email,
    String phone,
    String password,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      if (Environment.useMockData) {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 1));

        if (firstName.isNotEmpty &&
            lastName.isNotEmpty &&
            email.isNotEmpty &&
            phone.isNotEmpty &&
            password.isNotEmpty) {
          final UserModel user = UserModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: '$firstName $lastName',
            email: email,
            headline: 'Professional',
            location: 'Tashkent, Uzbekistan',
          );

          state = AuthState(
            user: user,
            isAuthenticated: true,
            isLoading: false,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'Please fill all fields',
          );
        }
        return;
      }

      final Uri uri = Uri.parse(
        '${Environment.apiBaseUrl}/api/${Environment.apiVersion}/auth/register',
      );

      final http.Response response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'phone': phone,
          'first_name': firstName,
          'last_name': lastName,
          'password': password,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;

        final String? accessToken = data['access_token'] as String?;

        if (accessToken != null && accessToken.isNotEmpty) {
          await _tokenStorage.saveAccessToken(accessToken);
        }

        // After successful registration we consider the user authenticated.
        // You can extend this to parse user data when backend provides it.
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          errorMessage: null,
        );
      } else {
        String errorMessage = 'Registration failed. Please try again.';
        try {
          final Map<String, dynamic> errorData =
              jsonDecode(response.body) as Map<String, dynamic>;
          errorMessage = (errorData['message'] ??
                  errorData['detail'] ??
                  errorData['error'] ??
                  errorMessage)
              .toString();
        } catch (_) {
          // Ignore JSON parse errors and use default message
        }

        state = state.copyWith(
          isLoading: false,
          errorMessage: errorMessage,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clear();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
