import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:linkedin_clone/core/network/api_client.dart';
import 'package:linkedin_clone/shared/models/service_model.dart';
import 'package:linkedin_clone/core/config/env.dart';
import 'package:linkedin_clone/core/services/token_storage.dart';

class ServicesFilters {
  final String? category;
  final String? location;
  final String? search;

  ServicesFilters({this.category, this.location, this.search});

  ServicesFilters copyWith({
    String? category,
    String? location,
    String? search,
    bool clearCategory = false,
    bool clearSearch = false,
  }) {
    return ServicesFilters(
      category: clearCategory ? null : (category ?? this.category),
      location: location ?? this.location,
      search: clearSearch ? null : (search ?? this.search),
    );
  }

  Map<String, String> toQueryParams() {
    final Map<String, String> params = <String, String>{};
    if (category != null && category!.isNotEmpty) params['category'] = category!;
    if (location != null && location!.isNotEmpty) params['location'] = location!;
    if (search != null && search!.isNotEmpty) params['search'] = search!;
    return params;
  }
}

class ServicesState {
  final List<ServiceModel> services;
  final bool isLoading;
  final bool isMoreLoading;
  final String? errorMessage;
  final int total;
  final int skip;
  final int limit;
  final ServicesFilters filters;

  ServicesState({
    this.services = const [],
    this.isLoading = false,
    this.isMoreLoading = false,
    this.errorMessage,
    this.total = 0,
    this.skip = 0,
    this.limit = 20,
    ServicesFilters? filters,
  }) : filters = filters ?? ServicesFilters();

  ServicesState copyWith({
    List<ServiceModel>? services,
    bool? isLoading,
    bool? isMoreLoading,
    String? errorMessage,
    int? total,
    int? skip,
    ServicesFilters? filters,
  }) {
    return ServicesState(
      services: services ?? this.services,
      isLoading: isLoading ?? this.isLoading,
      isMoreLoading: isMoreLoading ?? this.isMoreLoading,
      errorMessage: errorMessage,
      total: total ?? this.total,
      skip: skip ?? this.skip,
      limit: limit,
      filters: filters ?? this.filters,
    );
  }
}

class ServicesNotifier extends StateNotifier<ServicesState> {
  ServicesNotifier() : super(ServicesState()) {
    loadServices();
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    const tokenStorage = TokenStorage();
    final String? token = await tokenStorage.getAccessToken();
    return {
      if (token != null) 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<void> loadServices({bool isRefresh = false}) async {
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

      final Uri uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/services')
          .replace(queryParameters: queryParams);

      final http.Response response = await ApiClient.get(uri, headers: await _getAuthHeaders());

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic data = jsonDecode(response.body);
        final List<dynamic> items = data['items'];
        final int total = data['total'] as int;

        final List<ServiceModel> services = items.map((e) => ServiceModel.fromJson(e)).toList();

        state = state.copyWith(services: services, total: total, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, errorMessage: 'Xizmatlarni yuklashda xatolik yuz berdi');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Xatolik: $e');
    }
  }

  Future<void> loadMore() async {
    if (state.isMoreLoading || state.services.length >= state.total) return;

    state = state.copyWith(isMoreLoading: true);

    try {
      final int nextSkip = state.skip + state.limit;
      final Map<String, String> queryParams = {
        'skip': nextSkip.toString(),
        'limit': state.limit.toString(),
        'status': 'active',
        ...state.filters.toQueryParams(),
      };

      final Uri uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/services')
          .replace(queryParameters: queryParams);

      final http.Response response = await ApiClient.get(uri, headers: await _getAuthHeaders());

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic data = jsonDecode(response.body);
        final List<dynamic> items = data['items'];
        final List<ServiceModel> newServices = items.map((e) => ServiceModel.fromJson(e)).toList();

        state = state.copyWith(
          services: [...state.services, ...newServices],
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

  void updateFilters(ServicesFilters newFilters) {
    state = state.copyWith(filters: newFilters, skip: 0);
    loadServices();
  }

  void setSearch(String? search) {
    if (state.filters.search == search) return;
    state = state.copyWith(
      filters: state.filters.copyWith(search: search, clearSearch: search == null),
      skip: 0,
    );
    loadServices();
  }

  Future<void> refreshServices() async {
    await loadServices(isRefresh: true);
  }

  Future<ServiceModel?> getServiceById(int serviceId) async {
    try {
      final Map<String, String> headers = await _getAuthHeaders();
      final Uri uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/services/$serviceId');
      final http.Response response = await ApiClient.get(uri, headers: headers);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ServiceModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

final servicesProvider = StateNotifierProvider<ServicesNotifier, ServicesState>((ref) {
  return ServicesNotifier();
});
