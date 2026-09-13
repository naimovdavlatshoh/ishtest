import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:linkedin_clone/core/network/api_client.dart';
import 'package:linkedin_clone/shared/models/service_model.dart';
import 'package:linkedin_clone/core/config/env.dart';
import 'package:linkedin_clone/core/services/token_storage.dart';
import 'services_provider.dart';

class MyServicesNotifier extends StateNotifier<ServicesState> {
  MyServicesNotifier() : super(ServicesState());

  Future<Map<String, String>> _getAuthHeaders() async {
    const tokenStorage = TokenStorage();
    final String? token = await tokenStorage.getAccessToken();
    return {
      if (token != null) 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<void> loadMyServices() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final Uri uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/services/my-services')
          .replace(queryParameters: {'skip': '0', 'limit': '100'});

      final http.Response response = await ApiClient.get(uri, headers: await _getAuthHeaders());

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic data = jsonDecode(response.body);
        final List<dynamic>? items = data['items'];
        final int total = data['total'] as int? ?? (items?.length ?? 0);

        final List<ServiceModel> services = (items ?? []).map((e) => ServiceModel.fromJson(e)).toList();

        state = state.copyWith(services: services, total: total, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, errorMessage: 'Mening xizmatlarimni yuklashda xatolik yuz berdi');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Xatolik: $e');
    }
  }

  Future<bool> updateServiceStatus(int serviceId, String status) async {
    try {
      final Map<String, String> headers = await _getAuthHeaders();
      final Uri uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/services/$serviceId');

      final http.Response response = await ApiClient.put(
        uri,
        headers: headers,
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        state = state.copyWith(
          services: state.services.map((s) => s.id == serviceId ? s.copyWith(status: status) : s).toList(),
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Creates a service and returns its id, or null on failure.
  Future<int?> createService(Map<String, dynamic> data) async {
    try {
      final Map<String, String> headers = await _getAuthHeaders();
      final Uri uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/services');

      final http.Response response = await ApiClient.post(uri, headers: headers, body: jsonEncode(data));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic created = jsonDecode(response.body);
        await loadMyServices();
        return created['id'] as int?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Uploads an image for an existing service. Returns the hosted image URL, or null on failure.
  Future<String?> uploadServiceImage(int serviceId, String filePath) async {
    try {
      const tokenStorage = TokenStorage();
      final String? token = await tokenStorage.getAccessToken();
      final Uri uri = Uri.parse(
        '${Environment.apiBaseUrl}/api/${Environment.apiVersion}/services/$serviceId/image',
      );

      final request = http.MultipartRequest('POST', uri);
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic updated = jsonDecode(response.body);
        await loadMyServices();
        return updated['image'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteService(int serviceId) async {
    try {
      final Map<String, String> headers = await _getAuthHeaders();
      final Uri uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/services/$serviceId');
      final http.Response response = await ApiClient.delete(uri, headers: headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        state = state.copyWith(
          services: state.services.where((s) => s.id != serviceId).toList(),
          total: (state.total - 1).clamp(0, 999999),
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

final myServicesProvider = StateNotifierProvider<MyServicesNotifier, ServicesState>((ref) {
  return MyServicesNotifier();
});
