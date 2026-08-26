import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Called once when any request made through [ApiClient] comes back with
/// HTTP 401 (expired/invalid access token). Wired up in `main.dart` to log
/// the user out and let the router redirect to the login screen.
typedef UnauthorizedCallback = FutureOr<void> Function();

/// Drop-in replacement for the top-level functions in `package:http`
/// (same signatures, so existing call sites only need `http.` swapped for
/// `ApiClient.`). The only difference: every response is inspected for a
/// 401 status, and [onUnauthorized] is invoked so the expired session can
/// be handled centrally instead of every provider quietly showing an
/// error and leaving the user stuck on a stale/empty screen.
class ApiClient {
  ApiClient._();

  static UnauthorizedCallback? onUnauthorized;

  static bool _handlingUnauthorized = false;

  static Future<void> _reportIfUnauthorized(http.Response response) async {
    if (response.statusCode != 401) return;
    final UnauthorizedCallback? callback = onUnauthorized;
    if (callback == null || _handlingUnauthorized) return;

    _handlingUnauthorized = true;
    try {
      await callback();
    } finally {
      _handlingUnauthorized = false;
    }
  }

  static Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final http.Response response = await http.get(url, headers: headers);
    await _reportIfUnauthorized(response);
    return response;
  }

  static Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final http.Response response =
        await http.post(url, headers: headers, body: body, encoding: encoding);
    await _reportIfUnauthorized(response);
    return response;
  }

  static Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final http.Response response =
        await http.put(url, headers: headers, body: body, encoding: encoding);
    await _reportIfUnauthorized(response);
    return response;
  }

  static Future<http.Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final http.Response response =
        await http.patch(url, headers: headers, body: body, encoding: encoding);
    await _reportIfUnauthorized(response);
    return response;
  }

  static Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final http.Response response =
        await http.delete(url, headers: headers, body: body, encoding: encoding);
    await _reportIfUnauthorized(response);
    return response;
  }
}
