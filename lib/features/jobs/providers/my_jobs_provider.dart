import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:linkedin_clone/shared/models/job_model.dart';
import 'package:linkedin_clone/core/config/env.dart';
import 'package:linkedin_clone/core/services/token_storage.dart';
import 'jobs_provider.dart';

class MyJobsNotifier extends StateNotifier<JobsState> {
  MyJobsNotifier() : super(JobsState());

  Future<Map<String, String>> _getAuthHeaders() async {
    const tokenStorage = TokenStorage();
    final String? token = await tokenStorage.getAccessToken();
    return {
      if (token != null) 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<void> loadMyJobs() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final Uri uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/jobs/my-jobs')
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
          errorMessage: 'Mening ishlarimni yuklashda xatolik yuz berdi',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Xatolik: $e',
      );
    }
  }

  Future<bool> updateJobStatus(int jobId, String status) async {
    try {
      final Map<String, String> headers = await _getAuthHeaders();
      final Uri uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/jobs/$jobId');
      
      final http.Response response = await http.put(
        uri,
        headers: headers,
        body: jsonEncode({'status': status}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        state = state.copyWith(
          jobs: state.jobs.map((j) {
            if (j.id == jobId) {
              return j.copyWith(status: status);
            }
            return j;
          }).toList(),
        );
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> createJob(Map<String, dynamic> data) async {
    try {
      final Map<String, String> headers = await _getAuthHeaders();
      final Uri uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/jobs');
      
      final http.Response response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await loadMyJobs();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateJob(int jobId, Map<String, dynamic> data) async {
    try {
      final Map<String, String> headers = await _getAuthHeaders();
      final Uri uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/jobs/$jobId');
      
      final http.Response response = await http.put(
        uri,
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await loadMyJobs();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteJob(int jobId) async {
    try {
       final Map<String, String> headers = await _getAuthHeaders();
       final Uri uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/jobs/$jobId');
       final http.Response response = await http.delete(uri, headers: headers);
       if (response.statusCode >= 200 && response.statusCode < 300) {
         state = state.copyWith(
           jobs: state.jobs.where((j) => j.id != jobId).toList(),
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

final myJobsProvider = StateNotifierProvider<MyJobsNotifier, JobsState>((ref) {
  return MyJobsNotifier();
});
