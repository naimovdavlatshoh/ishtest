import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/loaders/app_loader.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/skill_chip.dart';
import '../../auth/providers/auth_provider.dart';


class ProfileScreen extends ConsumerWidget {
  final String userId;

  const ProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider(userId));
    final currentUser = ref.watch(authProvider).user;
    final isCurrentUser = currentUser?.id == userId;

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text('Mening profilim'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await ref.read(authProvider.notifier).logout();
                // After logout, navigate to the login screen.
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Text('Chiqish'),
              ),
            ],
          ),
        ],
      ),
      body: profileState.isLoading
          ? const AppLoader()
          : profileState.user == null
              ? Center(child: Text('Foydalanuvchi topilmadi'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Header
                      ProfileHeader(
                        name: profileState.user!.name,
                        headline: profileState.user!.headline,
                        location: profileState.user!.location,
                        avatarUrl: profileState.user!.avatarUrl,
                        coverUrl: profileState.user!.coverUrl,
                        connections: profileState.user!.connections,
                        followers: profileState.user!.followers,
                        isCurrentUser: isCurrentUser,
                        onEditProfile: () {
                          // TODO: Edit profile
                        },
                      ),

                      const Divider(height: 1),

                      // About Section
                      if (profileState.user!.bio != null)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Haqida',
                                style: AppTextStyles.h3,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                profileState.user!.bio!,
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        ),

                      const Divider(height: 1),

                      // Skills Section
                      if (profileState.user!.skills.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ko\'nikmalar',
                                style: AppTextStyles.h3,
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: profileState.user!.skills
                                    .map((skill) => SkillChip(skill: skill))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),

                      const Divider(height: 1),

                      // Experience Section
                      if (profileState.user!.experience.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tajriba',
                                style: AppTextStyles.h3,
                              ),
                              const SizedBox(height: 16),
                              ...profileState.user!.experience.map((exp) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceVariant,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Icon(
                                          Icons.business,
                                          color: AppColors.iconSecondary,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              exp.position,
                                              style: AppTextStyles.username,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              exp.company,
                                              style: AppTextStyles.bodyMedium,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              exp.duration,
                                              style: AppTextStyles.caption,
                                            ),
                                            if (exp.description != null) ...[
                                              const SizedBox(height: 8),
                                              Text(
                                                exp.description!,
                                                style: AppTextStyles.bodySmall,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}
