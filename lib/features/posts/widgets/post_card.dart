import 'package:flutter/material.dart';
import 'package:linkedin_clone/shared/models/company_post_model.dart';
import 'package:linkedin_clone/core/theme/app_colors.dart';
import 'package:linkedin_clone/core/theme/app_text_styles.dart';
import 'package:linkedin_clone/core/utils/extensions.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PostCard extends StatelessWidget {
  final CompanyPostModel post;
  final VoidCallback? onLikeTap;
  final VoidCallback? onTap;

  const PostCard({super.key, required this.post, this.onLikeTap, this.onTap});

  String _authorName() {
    final author = post.author;
    if (author == null) return 'Foydalanuvchi';
    final name = '${author.firstName} ${author.lastName}'.trim();
    return name.isEmpty ? 'Foydalanuvchi' : name;
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = post.author?.avatar;
    final hasImage = post.image != null && post.image!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
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
                  child: const Icon(LucideIcons.image, color: AppColors.textTertiary, size: 32),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl.fullImageUrl) : null,
                      child: (avatarUrl == null || avatarUrl.isEmpty)
                          ? Text(
                              _authorName().isNotEmpty ? _authorName()[0].toUpperCase() : '?',
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_authorName(), style: AppTextStyles.username),
                          if (post.company != null)
                            Text(post.company!.name, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(post.title, style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                Text(
                  post.content,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onLikeTap,
                  child: Row(
                    children: [
                      Icon(
                        post.liked ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: post.liked ? Colors.red : AppColors.textTertiary,
                      ),
                      const SizedBox(width: 6),
                      Text('${post.likesCount}', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }
}
