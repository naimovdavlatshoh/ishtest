import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/extensions.dart';

class PostHeader extends StatelessWidget {
  final String authorName;
  final String authorHeadline;
  final String authorAvatar;
  final DateTime timestamp;
  final VoidCallback? onMenuTap;

  const PostHeader({
    super.key,
    required this.authorName,
    required this.authorHeadline,
    required this.authorAvatar,
    required this.timestamp,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Avatar
        CircleAvatar(
          radius: 24,
          backgroundImage: authorAvatar.isNotEmpty ? NetworkImage(authorAvatar.fullImageUrl) : null,
          backgroundColor: AppColors.surfaceVariant,
        ),
        const SizedBox(width: 12),

        // Author Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                authorName,
                style: AppTextStyles.username,
              ),
              Text(
                authorHeadline,
                style: AppTextStyles.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                timestamp.timeAgo,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),

        // Menu Button
        IconButton(
          icon: const Icon(Icons.more_horiz),
          onPressed: onMenuTap,
          color: AppColors.iconSecondary,
        ),
      ],
    );
  }
}
