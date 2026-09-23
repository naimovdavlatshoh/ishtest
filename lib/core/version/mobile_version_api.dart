import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/env.dart';
import 'app_version.dart';

/// Public version check. No auth header and no `/api/v1` prefix.
/// Any failure returns null so a temporary outage does not block startup.
class MobileVersionApi {
  MobileVersionApi({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? Environment.apiBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  static const Duration timeout = Duration(seconds: 8);

  Future<MobileVersionCatalog?> fetch() async {
    try {
      final String root = _baseUrl.endsWith('/')
          ? _baseUrl.substring(0, _baseUrl.length - 1)
          : _baseUrl;
      final Uri uri = Uri.parse('$root/mobile/version');
      final http.Response response = await _client.get(uri).timeout(timeout);
      if (response.statusCode != 200) return null;
      return MobileVersionCatalog.fromJson(jsonDecode(response.body));
    } catch (_) {
      return null;
    }
  }
}
