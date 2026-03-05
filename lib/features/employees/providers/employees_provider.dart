import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:linkedin_clone/core/config/env.dart';
import 'package:linkedin_clone/core/services/token_storage.dart';

class EmployeeModel {
  final int id;
  final String email;
  final String phone;
  final String firstName;
  final String lastName;
  final String role;
  final String? avatar;
  final String? telegramId;
  final bool isActive;
  final bool isVerified;
  final String createdAt;
  final String updatedAt;

  EmployeeModel({
    required this.id,
    required this.email,
    required this.phone,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.avatar,
    this.telegramId,
    required this.isActive,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'],
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      role: json['role'] ?? '',
      avatar: json['avatar'],
      telegramId: json['telegram_id'],
      isActive: json['is_active'] ?? true,
      isVerified: json['is_verified'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class EmployeesState {
  final List<EmployeeModel> employees;
  final bool isLoading;
  final String? errorMessage;
  final int total;
  final int skip;
  final int limit;
  final List<String> selectedSkills;

  EmployeesState({
    this.employees = const [],
    this.isLoading = false,
    this.errorMessage,
    this.total = 0,
    this.skip = 0,
    this.limit = 20,
    this.selectedSkills = const [],
  });

  EmployeesState copyWith({
    List<EmployeeModel>? employees,
    bool? isLoading,
    String? errorMessage,
    int? total,
    int? skip,
    int? limit,
    List<String>? selectedSkills,
  }) {
    return EmployeesState(
      employees: employees ?? this.employees,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      total: total ?? this.total,
      skip: skip ?? this.skip,
      limit: limit ?? this.limit,
      selectedSkills: selectedSkills ?? this.selectedSkills,
    );
  }
}

class EmployeesNotifier extends StateNotifier<EmployeesState> {
  EmployeesNotifier() : super(EmployeesState());

  Future<Map<String, String>> _getAuthHeaders() async {
    const tokenStorage = TokenStorage();
    final String? token = await tokenStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> loadEmployees({int? skip, List<String>? skills}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final int currentSkip = skip ?? state.skip;
      final List<String> currentSkills = skills ?? state.selectedSkills;
      
      String url = '${Environment.apiBaseUrl}/api/${Environment.apiVersion}/users/employees?skip=$currentSkip&limit=${state.limit}';
      
      if (currentSkills.isNotEmpty) {
        url += '&skills=${currentSkills.join(',')}';
      }

      final Map<String, String> headers = await _getAuthHeaders();
      final http.Response response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        final List<dynamic> items = data['items'];
        final List<EmployeeModel> employees = items.map((json) => EmployeeModel.fromJson(json as Map<String, dynamic>)).toList();
        
        state = state.copyWith(
          employees: employees,
          total: data['total'],
          skip: currentSkip,
          selectedSkills: currentSkills,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Ma\'lumotlarni yuklashda xatolik yuz berdi',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Aloqa xatosi: $e',
      );
    }
  }

  void addSkill(String skill) {
    if (skill.isEmpty) return;
    final List<String> newSkills = [...state.selectedSkills, skill];
    loadEmployees(skip: 0, skills: newSkills);
  }

  void removeSkill(String skill) {
    final List<String> newSkills = state.selectedSkills.where((s) => s != skill).toList();
    loadEmployees(skip: 0, skills: newSkills);
  }
}

final employeesProvider = StateNotifierProvider<EmployeesNotifier, EmployeesState>((ref) {
  return EmployeesNotifier();
});
