import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/extensions.dart';

class PostActions extends StatelessWidget {
  final int likes;
  final int comments;
  final int shares;
  final bool isLiked;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const PostActions({
    super.key,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.isLiked,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Stats Row
        if (likes > 0 || comments > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                if (likes > 0) ...[
                  Icon(
                    Icons.thumb_up,
                    size: 16,
                    color: AppColors.like,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    likes.compactFormat,
                    style: AppTextStyles.caption,
                  ),
                ],
                const Spacer(),
                if (comments > 0) ...[
                  Text(
                    '${comments.compactFormat} comments',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(width: 16),
                ],
                if (shares > 0)
                  Text(
                    '${shares.compactFormat} shares',
                    style: AppTextStyles.caption,
                  ),
              ],
            ),
          ),

        const Divider(height: 1),

        // Action Buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ActionButton(
                icon: isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                label: 'Like',
                onTap: onLike,
                color: isLiked ? AppColors.like : AppColors.iconSecondary,
              ),
              _ActionButton(
                icon: Icons.comment_outlined,
                label: 'Comment',
                onTap: onComment,
              ),
              _ActionButton(
                icon: Icons.share_outlined,
                label: 'Share',
                onTap: onShare,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: color ?? AppColors.iconSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: color ?? AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
