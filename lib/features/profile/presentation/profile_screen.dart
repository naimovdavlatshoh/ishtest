import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(l10n.profileTitle),
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
                child: Text(l10n.drawerLogout),
              ),
            ],
          ),
        ],
      ),
      body: profileState.isLoading
          ? const AppLoader()
          : profileState.user == null
              ? Center(child: Text(l10n.employeesProfileNotFound))
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
                                l10n.employeesAbout,
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
                                l10n.profileSkills,
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
                                l10n.profileExperience,
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

                      // Danger Zone - only for current user
                      if (isCurrentUser) ..._buildDangerZone(context, ref, l10n),
                    ],
                  ),
                ),
    );
  }


  List<Widget> _buildDangerZone(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    return [
      const SizedBox(height: 24),
      const Divider(height: 1),
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.error, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.dangerZone,
                  style: AppTextStyles.h3.copyWith(color: AppColors.error),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(8),
                color: AppColors.error.withValues(alpha: 0.05),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.deleteAccountTitle,
                    style: AppTextStyles.username.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.deleteAccountSubtitle,
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final password = await _showDeletePasswordDialog(
                          context,
                          l10n,
                        );
                        if (password != null && password.isNotEmpty && context.mounted) {
                          final success = await ref
                              .read(authProvider.notifier)
                              .deleteAccount(password);
                          if (context.mounted) {
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.deleteAccountSuccess),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              context.go('/login');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.deleteAccountError),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        }
                      },
                      icon: const Icon(Icons.delete_forever_outlined,
                          color: AppColors.error),
                      label: Text(
                        l10n.deleteAccountBtn,
                        style: const TextStyle(color: AppColors.error),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 32),
    ];
  }

  Future<String?> _showDeletePasswordDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final passwordController = TextEditingController();
    bool obscure = true;
    String? errorText;

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: AppColors.error, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.deleteAccountConfirmTitle,
                  style: AppTextStyles.h3.copyWith(color: AppColors.error),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.deleteAccountConfirmMsg,
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 20),
              Text(
                l10n.deleteAccountPasswordLabel,
                style: AppTextStyles.label,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: obscure,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l10n.deleteAccountPasswordHint,
                  errorText: errorText,
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => obscure = !obscure),
                  ),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                onChanged: (_) {
                  if (errorText != null) {
                    setState(() => errorText = null);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final pw = passwordController.text.trim();
                if (pw.isEmpty) {
                  setState(
                    () => errorText = l10n.deleteAccountPasswordRequired,
                  );
                  return;
                }
                Navigator.of(ctx).pop(pw);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.deleteAccountConfirmBtn),
            ),
          ],
        ),
      ),
    );
  }
}

