import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:linkedin_clone/core/network/api_client.dart';
import 'package:linkedin_clone/shared/models/company_post_model.dart';
import 'package:linkedin_clone/core/config/env.dart';
import 'package:linkedin_clone/core/services/token_storage.dart';

class PostsState {
  final List<CompanyPostModel> posts;
  final bool isLoading;
  final bool isMoreLoading;
  final String? errorMessage;
  final int total;
  final int skip;
  final int limit;
  final String? search;

  PostsState({
    this.posts = const [],
    this.isLoading = false,
    this.isMoreLoading = false,
    this.errorMessage,
    this.total = 0,
    this.skip = 0,
    this.limit = 20,
    this.search,
  });

  PostsState copyWith({
    List<CompanyPostModel>? posts,
    bool? isLoading,
    bool? isMoreLoading,
    String? errorMessage,
    int? total,
    int? skip,
    String? search,
    bool clearSearch = false,
  }) {
    return PostsState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isMoreLoading: isMoreLoading ?? this.isMoreLoading,
      errorMessage: errorMessage,
      total: total ?? this.total,
      skip: skip ?? this.skip,
      limit: limit,
      search: clearSearch ? null : (search ?? this.search),
    );
  }
}

class PostsNotifier extends StateNotifier<PostsState> {
  PostsNotifier() : super(PostsState()) {
    loadPosts();
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    const tokenStorage = TokenStorage();
    final String? token = await tokenStorage.getAccessToken();
    return {
      if (token != null) 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<void> loadPosts({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(skip: 0, isLoading: true, errorMessage: null);
    } else {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    try {
      final Map<String, String> queryParams = {
        'skip': state.skip.toString(),
        'limit': state.limit.toString(),
        'status': 'published',
        if (state.search != null && state.search!.isNotEmpty) 'search': state.search!,
      };

      final Uri uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/posts')
          .replace(queryParameters: queryParams);

      final http.Response response = await ApiClient.get(uri, headers: await _getAuthHeaders());

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic data = jsonDecode(response.body);
        final List<dynamic> items = data['items'];
        final int total = data['total'] as int;

        final List<CompanyPostModel> posts = items.map((e) => CompanyPostModel.fromJson(e)).toList();

        state = state.copyWith(posts: posts, total: total, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, errorMessage: 'Postlarni yuklashda xatolik yuz berdi');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Xatolik: $e');
    }
  }

  Future<void> loadMore() async {
    if (state.isMoreLoading || state.posts.length >= state.total) return;
    state = state.copyWith(isMoreLoading: true);

    try {
      final int nextSkip = state.skip + state.limit;
      final Map<String, String> queryParams = {
        'skip': nextSkip.toString(),
        'limit': state.limit.toString(),
        'status': 'published',
        if (state.search != null && state.search!.isNotEmpty) 'search': state.search!,
      };

      final Uri uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/posts')
          .replace(queryParameters: queryParams);

      final http.Response response = await ApiClient.get(uri, headers: await _getAuthHeaders());

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic data = jsonDecode(response.body);
        final List<dynamic> items = data['items'];
        final List<CompanyPostModel> newPosts = items.map((e) => CompanyPostModel.fromJson(e)).toList();

        state = state.copyWith(posts: [...state.posts, ...newPosts], skip: nextSkip, isMoreLoading: false);
      } else {
        state = state.copyWith(isMoreLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isMoreLoading: false);
    }
  }

  void setSearch(String? search) {
    if (state.search == search) return;
    state = state.copyWith(search: search, clearSearch: search == null, skip: 0);
    loadPosts();
  }

  Future<void> refreshPosts() async {
    await loadPosts(isRefresh: true);
  }

  Future<CompanyPostModel?> getPostById(int postId) async {
    try {
      final Map<String, String> headers = await _getAuthHeaders();
      final Uri uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/posts/$postId');
      final http.Response response = await ApiClient.get(uri, headers: headers);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return CompanyPostModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> toggleLike(int postId) async {
    final int index = state.posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final CompanyPostModel original = state.posts[index];
    final bool newLiked = !original.liked;
    final int newCount = (original.likesCount + (newLiked ? 1 : -1)).clamp(0, 999999);

    final List<CompanyPostModel> optimistic = [...state.posts];
    optimistic[index] = original.copyWith(liked: newLiked, likesCount: newCount);
    state = state.copyWith(posts: optimistic);

    try {
      final Map<String, String> headers = await _getAuthHeaders();
      final Uri uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/posts/$postId/like');
      final http.Response response = newLiked
          ? await ApiClient.post(uri, headers: headers)
          : await ApiClient.delete(uri, headers: headers);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final List<CompanyPostModel> reverted = [...state.posts];
        final int revertIndex = reverted.indexWhere((p) => p.id == postId);
        if (revertIndex != -1) reverted[revertIndex] = original;
        state = state.copyWith(posts: reverted);
      }
    } catch (e) {
      final List<CompanyPostModel> reverted = [...state.posts];
      final int revertIndex = reverted.indexWhere((p) => p.id == postId);
      if (revertIndex != -1) reverted[revertIndex] = original;
      state = state.copyWith(posts: reverted);
    }
  }
}

final postsProvider = StateNotifierProvider<PostsNotifier, PostsState>((ref) {
  return PostsNotifier();
});
