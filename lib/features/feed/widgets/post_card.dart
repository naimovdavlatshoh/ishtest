import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../shared/models/post_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'post_header.dart';
import 'post_actions.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onProfileTap;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    this.onComment,
    this.onShare,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
        side: BorderSide(color: AppColors.divider.withOpacity(0.5), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: PostHeader(
              authorName: post.authorName,
              authorHeadline: post.authorHeadline,
              authorAvatar: post.authorAvatar,
              timestamp: post.timestamp,
              onMenuTap: () {
                // TODO: Show post menu
              },
            ),
          ),

          // Post Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              post.content,
              style: AppTextStyles.bodyMedium.copyWith(height: 1.4),
            ),
          ),
          const SizedBox(height: 8),

          // Post Image
          if (post.imageUrl != null)
            CachedNetworkImage(
              imageUrl: post.imageUrl!,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 200,
                color: AppColors.surfaceVariant,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 200,
                color: AppColors.surfaceVariant,
                child: const Icon(Icons.image_not_supported_outlined),
              ),
            ),
          const SizedBox(height: 4),

          // Post Actions
          PostActions(
            likes: post.likes,
            comments: post.comments,
            shares: post.shares,
            isLiked: post.isLiked,
            onLike: onLike,
            onComment: onComment ?? () {},
            onShare: onShare ?? () {},
          ),
        ],
      ),
    );
  }
}
