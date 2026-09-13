import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:linkedin_clone/core/network/api_client.dart';
import 'package:linkedin_clone/shared/models/company_post_model.dart';
import 'package:linkedin_clone/core/config/env.dart';
import 'package:linkedin_clone/core/services/token_storage.dart';
import 'posts_provider.dart';

class MyPostsNotifier extends StateNotifier<PostsState> {
  MyPostsNotifier() : super(PostsState());

  Future<Map<String, String>> _getAuthHeaders() async {
    const tokenStorage = TokenStorage();
    final String? token = await tokenStorage.getAccessToken();
    return {
      if (token != null) 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<void> loadMyPosts() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final Uri uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/posts/my-posts')
          .replace(queryParameters: {'skip': '0', 'limit': '100'});

      final http.Response response = await ApiClient.get(uri, headers: await _getAuthHeaders());

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic data = jsonDecode(response.body);
        final List<dynamic>? items = data['items'];
        final int total = data['total'] as int? ?? (items?.length ?? 0);
        final List<CompanyPostModel> posts = (items ?? []).map((e) => CompanyPostModel.fromJson(e)).toList();

        state = state.copyWith(posts: posts, total: total, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, errorMessage: 'Mening postlarimni yuklashda xatolik yuz berdi');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Xatolik: $e');
    }
  }

  /// Creates a post and returns its id, or null on failure.
  Future<int?> createPost(Map<String, dynamic> data) async {
    try {
      final Map<String, String> headers = await _getAuthHeaders();
      final Uri uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/posts');
      final http.Response response = await ApiClient.post(uri, headers: headers, body: jsonEncode(data));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic created = jsonDecode(response.body);
        await loadMyPosts();
        return created['id'] as int?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Uploads an image for an existing post. Returns the hosted image URL, or null on failure.
  Future<String?> uploadPostImage(int postId, String filePath) async {
    try {
      const tokenStorage = TokenStorage();
      final String? token = await tokenStorage.getAccessToken();
      final Uri uri = Uri.parse(
        '${Environment.apiBaseUrl}/api/${Environment.apiVersion}/posts/$postId/image',
      );

      final request = http.MultipartRequest('POST', uri);
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic updated = jsonDecode(response.body);
        await loadMyPosts();
        return updated['image'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deletePost(int postId) async {
    try {
      final Map<String, String> headers = await _getAuthHeaders();
      final Uri uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/posts/$postId');
      final http.Response response = await ApiClient.delete(uri, headers: headers);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        state = state.copyWith(
          posts: state.posts.where((p) => p.id != postId).toList(),
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

final myPostsProvider = StateNotifierProvider<MyPostsNotifier, PostsState>((ref) {
  return MyPostsNotifier();
});
