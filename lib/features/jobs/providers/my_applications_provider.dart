import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:linkedin_clone/shared/models/application_model.dart';
import 'package:linkedin_clone/core/config/env.dart';
import 'package:linkedin_clone/core/services/token_storage.dart';

class MyApplicationsState {
  final List<ApplicationModel> applications;
  final bool isLoading;
  final String? error;

  MyApplicationsState({
    this.applications = const [],
    this.isLoading = false,
    this.error,
  });

  MyApplicationsState copyWith({
    List<ApplicationModel>? applications,
    bool? isLoading,
    String? error,
  }) {
    return MyApplicationsState(
      applications: applications ?? this.applications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MyApplicationsNotifier extends StateNotifier<MyApplicationsState> {
  MyApplicationsNotifier() : super(MyApplicationsState());

  Future<Map<String, String>> _headers() async {
    const s = TokenStorage();
    final String? token = await s.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final String url = '${Environment.apiBaseUrl}/api/${Environment.apiVersion}/applications/my-applications';
      final http.Response response = await http.get(Uri.parse(url), headers: await _headers());

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        List<ApplicationModel> apps;
        if (data is List) {
          apps = data.map((e) => ApplicationModel.fromJson(e)).toList();
        } else if (data is Map && data['items'] != null) {
          apps = (data['items'] as List).map((e) => ApplicationModel.fromJson(e)).toList();
        } else {
          apps = [];
        }
        state = state.copyWith(applications: apps, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: 'Xatolik yuz berdi');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> withdraw(int applicationId) async {
    try {
      final String url = '${Environment.apiBaseUrl}/api/${Environment.apiVersion}/applications/$applicationId';
      final http.Response response = await http.delete(Uri.parse(url), headers: await _headers());
      if (response.statusCode == 204 || response.statusCode == 200) {
        state = state.copyWith(
          applications: state.applications.where((a) => a.id != applicationId).toList(),
        );
        return true;
      }
    } catch (_) {}
    return false;
  }
}

final myApplicationsProvider =
    StateNotifierProvider<MyApplicationsNotifier, MyApplicationsState>((ref) {
  return MyApplicationsNotifier();
});
