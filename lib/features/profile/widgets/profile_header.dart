import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/extensions.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String? headline;
  final String? location;
  final String? avatarUrl;
  final String? coverUrl;
  final int connections;
  final int followers;
  final VoidCallback? onEditProfile;
  final bool isCurrentUser;

  const ProfileHeader({
    super.key,
    required this.name,
    this.headline,
    this.location,
    this.avatarUrl,
    this.coverUrl,
    this.connections = 0,
    this.followers = 0,
    this.onEditProfile,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Cover Image
        Stack(
          children: [
            // Cover Photo
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                image: coverUrl != null
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(coverUrl!.fullImageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),

            // Profile Picture
            Positioned(
              bottom: 0,
              left: 16,
              child: Transform.translate(
                offset: const Offset(0, 40),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: avatarUrl != null
                        ? CachedNetworkImageProvider(avatarUrl!.fullImageUrl)
                        : null,
                    backgroundColor: AppColors.surfaceVariant,
                    child: avatarUrl == null
                        ? Text(
                            name[0].toUpperCase(),
                            style: AppTextStyles.h1,
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 48),

        // Profile Info
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppTextStyles.h2,
                        ),
                        if (headline != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            headline!,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                        if (location != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: AppColors.iconSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                location!,
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isCurrentUser)
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: onEditProfile,
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Connections & Followers
              Row(
                children: [
                  Text(
                    '${connections.compactFormat} connections',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${followers.compactFormat} followers',
                    style: AppTextStyles.label,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Action Buttons
              if (!isCurrentUser)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Connect
                        },
                        icon: const Icon(Icons.person_add_outlined, size: 20),
                        label: const Text('Connect'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Message
                        },
                        icon: const Icon(Icons.message_outlined, size: 20),
                        label: const Text('Message'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
