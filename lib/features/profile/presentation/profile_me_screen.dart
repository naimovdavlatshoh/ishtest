import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/loaders/app_loader.dart';
import '../providers/profile_me_provider.dart';
import '../../../shared/models/profile_me_model.dart';
import '../../../core/utils/extensions.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ProfileMeScreen extends ConsumerWidget {
  const ProfileMeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final AsyncValue<ProfileMe> profileAsync = ref.watch(profileMeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: profileAsync.when(
        loading: () => const Center(child: AppLoader()),
        error: (error, stack) => Center(child: Text('${l10n.errorOccurred}: $error')),
        data: (profile) => RefreshIndicator(
          onRefresh: () => ref.read(profileMeProvider.notifier).fetchProfile(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildHeader(context, ref, profile, l10n),
                _buildAbout(profile, l10n),
                _buildSkills(context, ref, profile, l10n),
                _buildExperience(ref, profile, l10n),
                _buildEducation(ref, profile, l10n),
                _buildResume(ref, profile, l10n),
                ..._buildDangerZone(context, ref, l10n),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, ProfileMe profile, AppLocalizations l10n) {
    final initial = profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : '?';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: profile.avatar != null ? NetworkImage(profile.avatar!.fullImageUrl) : null,
                child: profile.avatar == null
                    ? Text(
                        initial,
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 30),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(profile.fullName, style: AppTextStyles.h2.copyWith(fontSize: 21)),
                        const SizedBox(width: 6),
                        const Icon(LucideIcons.circleCheck, color: AppColors.primary, size: 18),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.title,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                    if (profile.city != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(LucideIcons.mapPin, size: 15, color: AppColors.textTertiary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              profile.city!,
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/profile/edit'),
                  icon: const Icon(LucideIcons.pencil, size: 17),
                  label: Text(l10n.profileEditBtn),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/feed'),
                  icon: const Icon(LucideIcons.eye, size: 17),
                  label: Text(l10n.profileViewBtn),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAbout(ProfileMe profile, AppLocalizations l10n) {
    if (profile.bio == null || profile.bio!.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.user, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(l10n.profileAboutMe, style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: 12),
          Text(profile.bio!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildSkills(BuildContext context, WidgetRef ref, ProfileMe profile, AppLocalizations l10n) {
    if (profile.skills.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(l10n.profileSkills, style: AppTextStyles.h3)),
              GestureDetector(
                onTap: () => context.push('/profile/edit'),
                child: Text(
                  l10n.profileEditBtn,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: profile.skills.map((skill) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                skill,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExperience(WidgetRef ref, ProfileMe profile, AppLocalizations l10n) {
    if (profile.experience.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.briefcase, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(l10n.profileExperience, style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: 24),
          ...profile.experience.map((exp) {
            final companyInitial = exp.company.isNotEmpty ? exp.company[0].toUpperCase() : '?';
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        companyInitial,
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(exp.title, style: AppTextStyles.h4),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                exp.company,
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (exp.location != null) ...[
                              const SizedBox(width: 8),
                              const Icon(LucideIcons.mapPin, size: 14, color: AppColors.textTertiary),
                              const SizedBox(width: 4),
                              Text(exp.location!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${exp.startDate} — ${exp.endDate ?? 'hozirgacha'}',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                        ),
                        if (exp.description != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            exp.description!,
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEducation(WidgetRef ref, ProfileMe profile, AppLocalizations l10n) {
    if (profile.education.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.graduationCap, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(l10n.profileEducation, style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: 24),
          ...profile.education.map((edu) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(edu.school, style: AppTextStyles.h4),
                      Text('${edu.degree} • ${edu.field}', style: AppTextStyles.bodyLarge),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(LucideIcons.calendar, size: 14, color: AppColors.textTertiary),
                          const SizedBox(width: 4),
                          Text(
                            '${edu.startDate} - ${edu.endDate ?? 'present'}',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildResume(WidgetRef ref, ProfileMe profile, AppLocalizations l10n) {
    if (profile.cvFile == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.fileText, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(l10n.profileResume, style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.fileText, color: Colors.red),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.cvFile?.split('/').last ?? 'resume_pdf',
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        l10n.profileUploadedCv,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.externalLink, size: 16),
                  label: Text(l10n.profileViewBtn),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
                const Icon(LucideIcons.triangleAlert,
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
                              context.showSnackBar(l10n.deleteAccountSuccess);
                              context.go('/login');
                            } else {
                              context.showSnackBar(l10n.deleteAccountError, isError: true);
                            }
                          }
                        }
                      },
                      icon: const Icon(LucideIcons.trash2,
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
              const Icon(LucideIcons.triangleAlert,
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
                          ? LucideIcons.eye
                          : LucideIcons.eyeOff,
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
