import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:linkedin_clone/shared/models/job_model.dart';
import 'package:linkedin_clone/core/config/env.dart';
import 'package:linkedin_clone/core/services/token_storage.dart';

class JobsFilters {
  final String? jobType;
  final String? location;
  final bool? isRemote;
  final int? salaryMin;
  final int? salaryMax;
  final String? dateFrom;

  JobsFilters({
    this.jobType,
    this.location,
    this.isRemote,
    this.salaryMin,
    this.salaryMax,
    this.dateFrom,
  });

  JobsFilters copyWith({
    String? jobType,
    String? location,
    bool? isRemote,
    int? salaryMin,
    int? salaryMax,
    String? dateFrom,
    bool clearJobType = false,
    bool clearLocation = false,
    bool clearIsRemote = false,
    bool clearSalaryMin = false,
    bool clearSalaryMax = false,
    bool clearDateFrom = false,
  }) {
    return JobsFilters(
      jobType: clearJobType ? null : (jobType ?? this.jobType),
      location: clearLocation ? null : (location ?? this.location),
      isRemote: clearIsRemote ? null : (isRemote ?? this.isRemote),
      salaryMin: clearSalaryMin ? null : (salaryMin ?? this.salaryMin),
      salaryMax: clearSalaryMax ? null : (salaryMax ?? this.salaryMax),
      dateFrom: clearDateFrom ? null : (dateFrom ?? this.dateFrom),
    );
  }

  Map<String, String> toQueryParams() {
    final Map<String, String> params = <String, String>{};
    if (jobType != null && jobType!.isNotEmpty) params['job_type'] = jobType!;
    if (location != null && location!.isNotEmpty) params['location'] = location!;
    if (isRemote != null) params['is_remote'] = isRemote!.toString();
    if (salaryMin != null) params['salary_min'] = salaryMin!.toString();
    if (salaryMax != null) params['salary_max'] = salaryMax!.toString();
    if (dateFrom != null && dateFrom!.isNotEmpty) params['date_from'] = dateFrom!;
    return params;
  }
}

class JobsState {
  final List<JobModel> jobs;
  final bool isLoading;
  final bool isMoreLoading;
  final String? errorMessage;
  final int total;
  final int skip;
  final int limit;
  final JobsFilters filters;

  JobsState({
    this.jobs = const [],
    this.isLoading = false,
    this.isMoreLoading = false,
    this.errorMessage,
    this.total = 0,
    this.skip = 0,
    this.limit = 20,
    JobsFilters? filters,
  }) : filters = filters ?? JobsFilters();

  JobsState copyWith({
    List<JobModel>? jobs,
    bool? isLoading,
    bool? isMoreLoading,
    String? errorMessage,
    int? total,
    int? skip,
    int? limit,
    JobsFilters? filters,
  }) {
    return JobsState(
      jobs: jobs ?? this.jobs,
      isLoading: isLoading ?? this.isLoading,
      isMoreLoading: isMoreLoading ?? this.isMoreLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      total: total ?? this.total,
      skip: skip ?? this.skip,
      limit: limit ?? this.limit,
      filters: filters ?? this.filters,
    );
  }
}

class JobsNotifier extends StateNotifier<JobsState> {
  JobsNotifier() : super(JobsState()) {
    loadJobs();
  }

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
            'limit': '100', // Load all saved jobs for simplicity or handle pagination later
          });

      final http.Response response = await http.get(uri, headers: await _getAuthHeaders());

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic data = jsonDecode(response.body);
        final List<dynamic> items = data['items'];
        final int total = data['total'] as int;

        final List<JobModel> jobs = items.map((e) => JobModel.fromJson(e)).toList();

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

  Future<void> loadJobs({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(skip: 0, isLoading: true, errorMessage: null);
    } else {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    try {
      final Map<String, String> queryParams = {
        'skip': state.skip.toString(),
        'limit': state.limit.toString(),
        'status': 'active',
        ...state.filters.toQueryParams(),
      };

      final Uri uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/jobs')
          .replace(queryParameters: queryParams);

      final http.Response response = await http.get(uri, headers: await _getAuthHeaders());

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic data = jsonDecode(response.body);
        final List<dynamic> items = data['items'];
        final int total = data['total'] as int;

        final List<JobModel> jobs = items.map((e) => JobModel.fromJson(e)).toList();

        state = state.copyWith(
          jobs: jobs,
          total: total,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Vakansiyalarni yuklashda xatolik yuz berdi',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Xatolik: $e',
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isMoreLoading || state.jobs.length >= state.total) return;

    state = state.copyWith(isMoreLoading: true);

    try {
      final int nextSkip = state.skip + state.limit;
      final Map<String, String> queryParams = {
        'skip': nextSkip.toString(),
        'limit': state.limit.toString(),
        'status': 'active',
        ...state.filters.toQueryParams(),
      };

      final Uri uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/jobs')
          .replace(queryParameters: queryParams);

      final http.Response response = await http.get(uri, headers: await _getAuthHeaders());

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic data = jsonDecode(response.body);
        final List<dynamic> items = data['items'];
        
        final List<JobModel> newJobs = items.map((e) => JobModel.fromJson(e)).toList();

        state = state.copyWith(
          jobs: [...state.jobs, ...newJobs],
          skip: nextSkip,
          isMoreLoading: false,
        );
      } else {
        state = state.copyWith(isMoreLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isMoreLoading: false);
    }
  }

  void updateFilters(JobsFilters newFilters) {
    state = state.copyWith(filters: newFilters, skip: 0);
    loadJobs();
  }

  void clearFilters() {
    state = state.copyWith(filters: JobsFilters(), skip: 0);
    loadJobs();
  }

  Future<void> logJobView(int jobId) async {
    try {
      final Uri uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/jobs/$jobId/view');
      await http.post(uri, headers: await _getAuthHeaders());
    } catch (e) {
      // Background action, fail silently or log debug
      print('Error logging job view: $e');
    }
  }

  Future<bool> saveJob(int jobId) async {
    try {
      final Map<String, String> headers = await _getAuthHeaders();
      final Uri uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/jobs/$jobId/save');
      final http.Response response = await http.post(uri, headers: headers);
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('Error saving job: $e');
      return false;
    }
  }

  Future<bool> unsaveJob(int jobId) async {
    try {
      final Map<String, String> headers = await _getAuthHeaders();
      final Uri uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/jobs/$jobId/save');
      final http.Response response = await http.delete(uri, headers: headers);
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('Error unsaving job: $e');
      return false;
    }
  }

  Future<bool> applyToJob(int jobId, String coverLetter) async {
    try {
      final Map<String, String> headers = await _getAuthHeaders();
      final Uri uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/applications');
      
      print('DEBUG: Applying to job $jobId');
      print('DEBUG: URL: $uri');
      
      final http.Response response = await http.post(
        uri, 
        headers: headers,
        body: jsonEncode({
          'job_id': jobId,
          'cover_letter': coverLetter,
        }),
      );
      
      print('DEBUG: Application Result Status: ${response.statusCode}');
      print('DEBUG: Application Result Body: ${response.body}');
      
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('Error applying to job: $e');
      return false;
    }
  }

  Future<List<dynamic>> getApplicationsForJob(int jobId) async {
    try {
      final Map<String, String> headers = await _getAuthHeaders();
      final Uri uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/applications/job/$jobId');
      final http.Response response = await http.get(uri, headers: headers);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      print('Error fetching applications: $e');
      return [];
    }
  }

  Future<JobModel?> getJobById(int jobId) async {
    try {
      final Map<String, String> headers = await _getAuthHeaders();
      final Uri uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/jobs/$jobId');
      final http.Response response = await http.get(uri, headers: headers);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return JobModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error fetching job by ID: $e');
      return null;
    }
  }

  Future<void> refreshJobs() async {
    await loadJobs(isRefresh: true);
  }
}

final jobsProvider = StateNotifierProvider<JobsNotifier, JobsState>((ref) {
  return JobsNotifier();
});
