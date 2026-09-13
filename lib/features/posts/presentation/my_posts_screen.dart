import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linkedin_clone/core/theme/app_colors.dart';
import 'package:linkedin_clone/core/theme/app_text_styles.dart';
import 'package:linkedin_clone/core/utils/extensions.dart';
import 'package:linkedin_clone/shared/models/company_post_model.dart';
import '../providers/my_posts_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MyPostsScreen extends ConsumerStatefulWidget {
  const MyPostsScreen({super.key});

  @override
  ConsumerState<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends ConsumerState<MyPostsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(myPostsProvider.notifier).loadMyPosts());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myPostsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.errorMessage != null
                ? Center(child: Text(state.errorMessage!))
                : RefreshIndicator(
                    onRefresh: () => ref.read(myPostsProvider.notifier).loadMyPosts(),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () => context.push('/posts/add'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(LucideIcons.circlePlus, color: Colors.white, size: 22),
                                const SizedBox(width: 8),
                                Text('Post yaratish', style: AppTextStyles.button.copyWith(color: Colors.white, fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        if (state.posts.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Center(
                              child: Text("Hozircha postlaringiz yo'q", style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary)),
                            ),
                          )
                        else
                          ...state.posts.map((p) => _buildPostCard(p)),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildPostCard(CompanyPostModel post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    post.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h3.copyWith(fontSize: 18, color: AppColors.textPrimary),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showDeleteConfirmation(post.id),
                  child: const Icon(LucideIcons.trash2, color: Colors.red, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              post.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(LucideIcons.heart, size: 16, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text('${post.likesCount}', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(int postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("O'chirish"),
        content: const Text("Ushbu postni o'chirmoqchimisiz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bekor qilish')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(myPostsProvider.notifier).deletePost(postId);
              if (context.mounted) {
                context.showSnackBar(success ? "O'chirildi" : 'Xatolik yuz berdi', isError: !success);
              }
            },
            child: const Text("O'chirish", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
