import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:linkedin_clone/core/config/env.dart';
import 'package:linkedin_clone/core/services/token_storage.dart';

class UserProfileModel {
  final int id;
  final int userId;
  final String fullName;
  final String? city;
  final String? bio;
  final String? title;
  final String? avatar;
  final List<dynamic>? skills;
  final List<dynamic>? experience;
  final List<dynamic>? education;
  final bool openToJobSeeker;
  final bool openToEmployer;
  final bool isComplete;
  final String createdAt;

  UserProfileModel({
    required this.id,
    required this.userId,
    required this.fullName,
    this.city,
    this.bio,
    this.title,
    this.avatar,
    this.skills,
    this.experience,
    this.education,
    required this.openToJobSeeker,
    required this.openToEmployer,
    required this.isComplete,
    required this.createdAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      fullName: json['fullName'] ?? '',
      city: json['city'],
      bio: json['bio'],
      title: json['title'],
      avatar: json['avatar'],
      skills: json['skills'] as List<dynamic>?,
      experience: json['experience'] as List<dynamic>?,
      education: json['education'] as List<dynamic>?,
      openToJobSeeker: json['openToJobSeeker'] ?? false,
      openToEmployer: json['openToEmployer'] ?? false,
      isComplete: json['isComplete'] ?? false,
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class UserProfileState {
  final UserProfileModel? profile;
  final bool isLoading;
  final String? errorMessage;

  UserProfileState({
    this.profile,
    this.isLoading = false,
    this.errorMessage,
  });

  UserProfileState copyWith({
    UserProfileModel? profile,
    bool? isLoading,
    String? errorMessage,
  }) {
    return UserProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class UserProfileNotifier extends StateNotifier<UserProfileState> {
  UserProfileNotifier() : super(UserProfileState());

  Future<Map<String, String>> _getAuthHeaders() async {
    const tokenStorage = TokenStorage();
    final String? token = await tokenStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> loadProfile(int userId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final Map<String, String> headers = await _getAuthHeaders();
      final String url = '${Environment.apiBaseUrl}/api/${Environment.apiVersion}/profiles/user/$userId';
      final http.Response response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        state = state.copyWith(
          profile: UserProfileModel.fromJson(data),
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Profil topilmadi',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Xatolik: $e',
      );
    }
  }
}

final userProfileProvider = StateNotifierProvider.family<UserProfileNotifier, UserProfileState, int>((ref, userId) {
  return UserProfileNotifier();
});
