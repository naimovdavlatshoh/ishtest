import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:linkedin_clone/core/config/env.dart';
import 'package:linkedin_clone/core/services/token_storage.dart';
import 'package:linkedin_clone/shared/models/company_model.dart';

class MyCompaniesNotifier extends StateNotifier<AsyncValue<List<CompanyModel>>> {
  MyCompaniesNotifier() : super(const AsyncValue.loading()) {
    fetchMyCompanies();
  }

  Future<void> fetchMyCompanies() async {
    state = const AsyncValue.loading();
    try {
      const tokenStorage = TokenStorage();
      final token = await tokenStorage.getAccessToken();

      if (token == null || token.isEmpty) {
        throw Exception('Access token not found');
      }

      final uri = Uri.parse(
        '${Environment.apiBaseUrl}/api/${Environment.apiVersion}/companies/my-companies',
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        final companies = data.map((e) => CompanyModel.fromJson(e as Map<String, dynamic>)).toList();
        state = AsyncValue.data(companies);
      } else {
        throw Exception('Failed to load companies');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> createCompany(Map<String, dynamic> data) async {
    try {
      const tokenStorage = TokenStorage();
      final token = await tokenStorage.getAccessToken();

      print('DEBUG: Auth Token Found: ${token != null && token.isNotEmpty}');
      if (token == null || token.isEmpty) return false;

      final uri = Uri.parse(
        '${Environment.apiBaseUrl}/api/${Environment.apiVersion}/companies',
      );
      print('DEBUG: Create Company URL: $uri');

      print('DEBUG: Create Company Payload: ${jsonEncode(data)}');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      print('DEBUG: Create Company Status: ${response.statusCode}');
      print('DEBUG: Create Company Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await fetchMyCompanies();
        return true;
      }
      print('DEBUG: Create Company Failed with status: ${response.statusCode}');
      return false;
    } catch (e) {
      print('DEBUG: Create Company Exception: $e');
      return false;
    }
  }

  Future<bool> updateCompany(int id, Map<String, dynamic> data) async {
    try {
      const tokenStorage = TokenStorage();
      final token = await tokenStorage.getAccessToken();

      if (token == null || token.isEmpty) return false;

      final uri = Uri.parse(
        '${Environment.apiBaseUrl}/api/${Environment.apiVersion}/companies/$id',
      );

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      print('DEBUG: Update Company Status: ${response.statusCode}');
      print('DEBUG: Update Company Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await fetchMyCompanies();
        return true;
      }
      print('DEBUG: Update Company Failed with status: ${response.statusCode}');
      return false;
    } catch (e) {
      print('DEBUG: Update Company Exception: $e');
      return false;
    }
  }

  Future<bool> deleteCompany(int id) async {
    try {
      const tokenStorage = TokenStorage();
      final token = await tokenStorage.getAccessToken();

      if (token == null || token.isEmpty) return false;

      final uri = Uri.parse(
        '${Environment.apiBaseUrl}/api/${Environment.apiVersion}/companies/$id',
      );

      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('DEBUG: Delete Company Status: ${response.statusCode}');
      print('DEBUG: Delete Company Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await fetchMyCompanies();
        return true;
      }
      print('DEBUG: Delete Company Failed with status: ${response.statusCode}');
      return false;
    } catch (e) {
      print('DEBUG: Delete Company Exception: $e');
      return false;
    }
  }
}

final myCompaniesProvider =
    StateNotifierProvider.autoDispose<MyCompaniesNotifier, AsyncValue<List<CompanyModel>>>(
        (ref) {
  return MyCompaniesNotifier();
});
