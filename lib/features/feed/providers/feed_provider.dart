import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/post_model.dart';

class FeedState {
  final List<PostModel> posts;
  final bool isLoading;
  final String? errorMessage;

  FeedState({
    this.posts = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  FeedState copyWith({
    List<PostModel>? posts,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class FeedNotifier extends StateNotifier<FeedState> {
  FeedNotifier() : super(FeedState()) {
    loadPosts();
  }

  Future<void> loadPosts() async {
    state = state.copyWith(isLoading: true);

    try {
      // API call to be implemented
      await Future.delayed(const Duration(seconds: 1));
      
      state = state.copyWith(
        posts: [], // Replace with real API call later
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void toggleLike(String postId) {
    final List<PostModel> updatedPosts = state.posts.map((post) {
      if (post.id == postId) {
        return post.copyWith(
          isLiked: !post.isLiked,
          likes: post.isLiked ? post.likes - 1 : post.likes + 1,
        );
      }
      return post;
    }).toList();

    state = state.copyWith(posts: updatedPosts);
  }

  Future<void> refreshPosts() async {
    await loadPosts();
  }
}

final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  return FeedNotifier();
});
