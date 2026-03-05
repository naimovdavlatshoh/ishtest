import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:linkedin_clone/shared/models/application_model.dart';
import 'package:linkedin_clone/core/config/env.dart';
import 'package:linkedin_clone/core/services/token_storage.dart';

class JobApplicationsState {
  final List<ApplicationModel> applications;
  final bool isLoading;
  final String? errorMessage;

  JobApplicationsState({
    this.applications = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  JobApplicationsState copyWith({
    List<ApplicationModel>? applications,
    bool? isLoading,
    String? errorMessage,
  }) {
    return JobApplicationsState(
      applications: applications ?? this.applications,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class JobApplicationsNotifier extends StateNotifier<JobApplicationsState> {
  JobApplicationsNotifier() : super(JobApplicationsState());

  Future<Map<String, String>> _getAuthHeaders() async {
    const tokenStorage = TokenStorage();
    final String? token = await tokenStorage.getAccessToken();
    return {
      if (token != null) 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<void> loadApplications(int jobId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final Map<String, String> headers = await _getAuthHeaders();
      final Uri uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/applications/job/$jobId');
      final http.Response response = await http.get(uri, headers: headers);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic decodedData = jsonDecode(response.body);
        List<ApplicationModel> applications = [];
        
        if (decodedData is List) {
          applications = decodedData.map((e) => ApplicationModel.fromJson(e)).toList();
        } else if (decodedData is Map<String, dynamic>) {
          // If for some reason it returns a single object
          applications = [ApplicationModel.fromJson(decodedData)];
        }
        
        state = state.copyWith(applications: applications, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, errorMessage: 'Arizalarni yuklab bo\'lmadi');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Xatolik: $e');
    }
  }

  Future<bool> updateApplicationStatus(int applicationId, String status) async {
    try {
      final Map<String, String> headers = await _getAuthHeaders();
      final Uri uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/applications/$applicationId');
      
      final http.Response response = await http.put(
        uri,
        headers: headers,
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        state = state.copyWith(
          applications: state.applications.map((app) {
            if (app.id == applicationId) {
              return app.copyWith(status: status);
            }
            return app;
          }).toList().cast<ApplicationModel>(),
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

final jobApplicationsProvider = StateNotifierProvider.autoDispose<JobApplicationsNotifier, JobApplicationsState>((ref) {
  return JobApplicationsNotifier();
});
