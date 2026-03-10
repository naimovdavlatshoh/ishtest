import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/extensions.dart';
import '../providers/user_profile_provider.dart';
import '../presentation/widgets/chat_invitation_dialog.dart';

class EmployeeProfileScreen extends ConsumerStatefulWidget {
  final int userId;
  final String? userName;

  const EmployeeProfileScreen({
    super.key,
    required this.userId,
    this.userName,
  });

  @override
  ConsumerState<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends ConsumerState<EmployeeProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      ref.read(userProfileProvider(widget.userId).notifier).loadProfile(widget.userId)
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(userProfileProvider(widget.userId));

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
              ? _buildError(state.errorMessage!, l10n)
              : state.profile == null
                  ? Center(child: Text(l10n.employeesProfileNotFound))
                  : _buildProfile(state.profile!, l10n),
    );
  }

  Widget _buildError(String message, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 64),
          const SizedBox(height: 16),
          Text(message, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(userProfileProvider(widget.userId).notifier).loadProfile(widget.userId),
            child: Text(l10n.employeesRetry),
          ),
        ],
      ),
    );
  }

  Widget _buildProfile(UserProfileModel profile, AppLocalizations l10n) {
    final initials = profile.fullName.isNotEmpty
        ? profile.fullName.trim().split(' ').map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').take(2).join()
        : '?';

    final avatarUrl = profile.avatar != null ? profile.avatar!.fullImageUrl : null;

    return CustomScrollView(
      slivers: [
        // Hero Header Sliver
        SliverAppBar(
          expandedHeight: 240,
          floating: false,
          pinned: true,
          backgroundColor: AppColors.primary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Gradient background
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                // Abstract pattern
                Positioned(
                  top: -30,
                  right: -30,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.07),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: -40,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),
                // Profile info
                Positioned(
                  bottom: 24,
                  left: 24,
                  right: 24,
                  child: Row(
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.2),
                          border: Border.all(color: Colors.white, width: 3),
                          image: avatarUrl != null
                              ? DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover)
                              : null,
                        ),
                        child: avatarUrl == null
                            ? Center(
                                child: Text(
                                  initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              profile.fullName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            if (profile.title != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                profile.title!,
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            ],
                            if (profile.city != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: Colors.white60, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    profile.city!,
                                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
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

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Chips
                Row(
                  children: [
                    if (profile.openToJobSeeker)
                      _buildStatusChip(l10n.employeesOpenToJob, const Color(0xFF10B981), const Color(0xFFE9FFF2)),
                    if (profile.openToJobSeeker && profile.openToEmployer)
                      const SizedBox(width: 8),
                    if (profile.openToEmployer)
                      _buildStatusChip(l10n.employeesLookingForWorker, const Color(0xFF3B82F6), const Color(0xFFEFF6FF)),
                  ],
                ),
                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => ChatInvitationDialog(
                              userId: profile.userId,
                              userName: profile.fullName,
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat_bubble_outline, size: 18),
                        label: Text(l10n.employeesSendMessage),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),

                // Bio
                if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  _buildSectionCard(
                    icon: Icons.person_outline,
                    title: l10n.employeesAbout,
                    child: Text(
                      profile.bio!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: const Color(0xFF475467),
                        height: 1.6,
                      ),
                    ),
                  ),
                ],

                // Skills
                if (profile.skills != null && profile.skills!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    icon: Icons.code,
                    title: l10n.employeesSkillsHeader,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: profile.skills!.map((skill) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: Text(
                          skill.toString(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                ],

                // Experience
                if (profile.experience != null && profile.experience!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    icon: Icons.work_outline,
                    title: l10n.employeesExperience,
                    child: Column(
                      children: profile.experience!.asMap().entries.map((entry) {
                        final exp = entry.value as Map<String, dynamic>;
                        final isLast = entry.key == profile.experience!.length - 1;
                        return Padding(
                          padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                          child: _buildTimelineItem(
                            icon: Icons.business,
                            title: exp['position'] ?? exp['title'] ?? '',
                            subtitle: exp['company'] ?? exp['companyName'] ?? '',
                            duration: exp['duration'] ?? exp['period'] ?? '',
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],

                // Education
                if (profile.education != null && profile.education!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    icon: Icons.school_outlined,
                    title: l10n.employeesEducation,
                    child: Column(
                      children: profile.education!.asMap().entries.map((entry) {
                        final edu = entry.value as Map<String, dynamic>;
                        final isLast = entry.key == profile.education!.length - 1;
                        return Padding(
                          padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                          child: _buildTimelineItem(
                            icon: Icons.school,
                            title: edu['degree'] ?? edu['field'] ?? '',
                            subtitle: edu['institution'] ?? edu['school'] ?? '',
                            duration: edu['year'] ?? edu['period'] ?? '',
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],

                // Empty state for no data
                if ((profile.bio == null || profile.bio!.isEmpty) &&
                    (profile.skills == null || profile.skills!.isEmpty) &&
                    (profile.experience == null || profile.experience!.isEmpty) &&
                    (profile.education == null || profile.education!.isEmpty)) ...[
                  const SizedBox(height: 32),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person_search, color: Colors.grey, size: 40),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.employeesProfileNotFilled,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: textColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required IconData icon, required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF2F4F7)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String duration,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE4E7EC)),
          ),
          child: Icon(icon, color: AppColors.textSecondary, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
              if (duration.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(duration, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
