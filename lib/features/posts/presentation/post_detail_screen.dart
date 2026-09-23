import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linkedin_clone/core/theme/app_colors.dart';
import 'package:linkedin_clone/core/theme/app_text_styles.dart';
import 'package:linkedin_clone/core/utils/extensions.dart';
import 'package:linkedin_clone/shared/models/company_post_model.dart';
import 'package:linkedin_clone/features/posts/providers/my_posts_provider.dart';
import 'package:linkedin_clone/features/posts/providers/posts_provider.dart';
import 'package:linkedin_clone/features/profile/providers/user_me_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final CompanyPostModel? post;
  final int? postId;

  const PostDetailScreen({super.key, this.post, this.postId}) : assert(post != null || postId != null);

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  CompanyPostModel? _post;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    if (_post == null && widget.postId != null) {
      _loadPost();
    }
  }

  Future<void> _loadPost() async {
    setState(() => _isLoading = true);
    final post = await ref.read(postsProvider.notifier).getPostById(widget.postId!);
    if (mounted) {
      setState(() {
        _post = post;
        _isLoading = false;
      });
    }
  }

  String _authorName(CompanyPostModel post) {
    final author = post.author;
    if (author == null) return 'Foydalanuvchi';
    final name = '${author.firstName} ${author.lastName}'.trim();
    return name.isEmpty ? 'Foydalanuvchi' : name;
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  void _handleLike() {
    if (_post == null) return;
    ref.read(postsProvider.notifier).toggleLike(_post!.id);
    // Reflect the optimistic toggle locally too, in case this post isn't
    // part of the currently loaded list (e.g. opened via a direct link).
    setState(() {
      final bool newLiked = !_post!.liked;
      final int newCount = (_post!.likesCount + (newLiked ? 1 : -1)).clamp(0, 999999);
      _post = _post!.copyWith(liked: newLiked, likesCount: newCount);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_post == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Post topilmadi')),
      );
    }

    final post = _post!;
    final hasImage = post.image != null && post.image!.isNotEmpty;
    final avatarUrl = post.author?.avatar;
    final int? myUserId = ref.watch(userMeProvider).valueOrNull?.id;
    final bool isMine = ref.watch(myPostsProvider).posts.any((item) => item.id == post.id) ||
        (myUserId != null && myUserId == post.authorId);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (isMine)
            IconButton(
              tooltip: 'Tahrirlash',
              icon: const Icon(LucideIcons.pencil, color: AppColors.primary, size: 20),
              onPressed: () => context.push('/posts/add', extra: post),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  post.image!.fullImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.surfaceVariant,
                    child: const Icon(LucideIcons.image, color: AppColors.textTertiary, size: 48),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                            ? NetworkImage(avatarUrl.fullImageUrl)
                            : null,
                        child: (avatarUrl == null || avatarUrl.isEmpty)
                            ? Text(
                                _authorName(post).isNotEmpty ? _authorName(post)[0].toUpperCase() : '?',
                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_authorName(post), style: AppTextStyles.username),
                            if (post.company != null)
                              Text(post.company!.name, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary))
                            else
                              Text(_formatDate(post.createdAt), style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(post.title, style: AppTextStyles.h2.copyWith(fontSize: 22)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(LucideIcons.calendar, size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 6),
                      Text(_formatDate(post.createdAt), style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    post.content,
                    style: AppTextStyles.bodyMedium.copyWith(height: 1.6, color: AppColors.textPrimary.withOpacity(0.85)),
                  ),
                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _handleLike,
                    child: Row(
                      children: [
                        Icon(
                          post.liked ? Icons.favorite : Icons.favorite_border,
                          size: 22,
                          color: post.liked ? Colors.red : AppColors.textTertiary,
                        ),
                        const SizedBox(width: 8),
                        Text('${post.likesCount}', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  if (isMine) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/posts/add', extra: post),
                        icon: const Icon(LucideIcons.pencil, size: 18, color: Colors.white),
                        label: const Text('Tahrirlash'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
