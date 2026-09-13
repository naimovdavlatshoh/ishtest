import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../config/env.dart';
import '../network/api_client.dart';
import 'token_storage.dart';

/// Registers/unregisters this device's FCM token with the backend
/// (`POST` / `DELETE /api/v1/devices`, see ish-backend's `app/api/v1/devices.py`)
/// so the server knows where to send push notifications for the signed-in
/// user. Both endpoints require a Bearer access token, so calls made while
/// signed out are silently skipped.
class DeviceRegistrationService {
  DeviceRegistrationService({TokenStorage? tokenStorage})
      : _tokenStorage = tokenStorage ?? const TokenStorage();

  static final DeviceRegistrationService instance = DeviceRegistrationService();

  final TokenStorage _tokenStorage;

  String get _platform {
    if (kIsWeb) return 'web';
    return Platform.isIOS ? 'ios' : 'android';
  }

  Uri get _uri =>
      Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/devices');

  Future<void> register(String fcmToken) async {
    final String? accessToken = await _tokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) return;

    try {
      await ApiClient.post(
        _uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'token': fcmToken, 'platform': _platform}),
      );
    } catch (e) {
      debugPrint('Device token registration failed: $e');
    }
  }

  Future<void> unregister(String fcmToken) async {
    final String? accessToken = await _tokenStorage.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) return;

    try {
      await ApiClient.delete(
        _uri.replace(queryParameters: {'token': fcmToken}),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
    } catch (e) {
      debugPrint('Device token unregistration failed: $e');
    }
  }
}
