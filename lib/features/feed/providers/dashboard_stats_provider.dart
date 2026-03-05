import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/env.dart';
import '../../../core/services/token_storage.dart';
import '../../../shared/models/dashboard_stats_model.dart';

final FutureProvider<DashboardStats> dashboardStatsProvider =
    FutureProvider<DashboardStats>((ref) async {
  if (Environment.useMockData) {
    // Static mock data for development mode
    return const DashboardStats(
      profileViews: 0,
      jobsApplied: 1,
      connections: 0,
      notifications: 0,
    );
  }

  const tokenStorage = TokenStorage();
  final String? token = await tokenStorage.getAccessToken();

  if (token == null || token.isEmpty) {
    throw Exception('Access token not found');
  }

  final Uri uri = Uri.parse(
    '${Environment.apiBaseUrl}/api/${Environment.apiVersion}/profiles/me/dashboard-stats',
  );

  final http.Response response = await http.get(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode >= 200 && response.statusCode < 300) {
    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    return DashboardStats.fromJson(data);
  } else {
    String errorMessage =
        'Failed to load dashboard stats (${response.statusCode})';
    try {
      final Map<String, dynamic> errorData =
          jsonDecode(response.body) as Map<String, dynamic>;
      errorMessage = (errorData['message'] ??
              errorData['detail'] ??
              errorData['error'] ??
              errorMessage)
          .toString();
    } catch (_) {
      // ignore parse errors
    }
    throw Exception(errorMessage);
  }
});

