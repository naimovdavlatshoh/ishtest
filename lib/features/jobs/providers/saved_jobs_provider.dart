import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:linkedin_clone/shared/models/job_model.dart';
import 'package:linkedin_clone/core/config/env.dart';
import 'package:linkedin_clone/core/services/token_storage.dart';
import 'jobs_provider.dart';

class SavedJobsNotifier extends StateNotifier<JobsState> {
  SavedJobsNotifier() : super(JobsState());

  Future<Map<String, String>> _getAuthHeaders() async {
    const tokenStorage = TokenStorage();
    final String? token = await tokenStorage.getAccessToken();
    return {
      if (token != null) 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<void> loadSavedJobs() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final Uri uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/jobs/saved')
          .replace(queryParameters: {
            'skip': '0',
            'limit': '100',
          });

      final http.Response response = await http.get(uri, headers: await _getAuthHeaders());

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic data = jsonDecode(response.body);
        final List<dynamic>? items = data['items'];
        final int total = data['total'] as int? ?? (items?.length ?? 0);

        final List<JobModel> jobs = (items ?? []).map((e) => JobModel.fromJson(e)).toList();

        state = state.copyWith(
          jobs: jobs,
          total: total,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Saqlangan vakansiyalarni yuklashda xatolik yuz berdi',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Xatolik: $e',
      );
    }
  }

  Future<bool> unsaveJob(int jobId) async {
    try {
      final Map<String, String> headers = await _getAuthHeaders();
      final Uri uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/jobs/$jobId/save');
      final http.Response response = await http.delete(uri, headers: headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        state = state.copyWith(
          jobs: state.jobs.where((j) => j.id != jobId).toList(),
          total: state.total - 1,
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Error unsaving job: $e');
      return false;
    }
  }
}

final savedJobsProvider = StateNotifierProvider<SavedJobsNotifier, JobsState>((ref) {
  return SavedJobsNotifier();
});
