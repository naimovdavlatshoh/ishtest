import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linkedin_clone/core/theme/app_colors.dart';
import 'package:linkedin_clone/core/widgets/loaders/app_loader.dart';
import 'package:linkedin_clone/core/widgets/empty_states/empty_state.dart';
import 'package:linkedin_clone/shared/models/company_post_model.dart';
import '../providers/posts_provider.dart';
import '../widgets/post_card.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PostsScreen extends ConsumerStatefulWidget {
  const PostsScreen({super.key});

  @override
  ConsumerState<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends ConsumerState<PostsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.length >= 2) {
        ref.read(postsProvider.notifier).setSearch(query);
      } else if (query.isEmpty) {
        ref.read(postsProvider.notifier).setSearch(null);
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final state = ref.read(postsProvider);
      if (!state.isLoading && !state.isMoreLoading && state.posts.length < state.total) {
        ref.read(postsProvider.notifier).loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Container(
          height: 40,
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Postlarni qidirish...',
              hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
              prefixIcon: const Icon(LucideIcons.search, color: AppColors.iconSecondary, size: 18),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            style: const TextStyle(fontSize: 13),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Material(
              color: AppColors.primary,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => context.push('/posts/add'),
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(LucideIcons.plus, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildList(state),
    );
  }

  Widget _buildList(PostsState state) {
    if (state.isLoading && state.posts.isEmpty) {
      return const AppLoader();
    }

    if (state.posts.isEmpty) {
      return EmptyState(
        icon: LucideIcons.image,
        title: 'Postlar topilmadi',
        message: "Boshqa qidiruv so'zi bilan urinib ko'ring",
        actionText: 'Yangilash',
        onAction: () => ref.read(postsProvider.notifier).refreshPosts(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(postsProvider.notifier).refreshPosts(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        itemCount: state.posts.length + (state.isMoreLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.posts.length) {
            return const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary))),
            );
          }
          final CompanyPostModel post = state.posts[index];
          return PostCard(
            post: post,
            onLikeTap: () => ref.read(postsProvider.notifier).toggleLike(post.id),
            onTap: () => context.push('/posts/${post.id}', extra: post),
          );
        },
      ),
    );
  }
}
