import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/job_applications_provider.dart';
import '../../../shared/models/application_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/extensions.dart';

class JobApplicationsScreen extends ConsumerStatefulWidget {
  final int jobId;
  final String jobTitle;

  const JobApplicationsScreen({
    super.key, 
    required this.jobId,
    required this.jobTitle,
  });

  @override
  ConsumerState<JobApplicationsScreen> createState() => _JobApplicationsScreenState();
}

class _JobApplicationsScreenState extends ConsumerState<JobApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(jobApplicationsProvider.notifier).loadApplications(widget.jobId));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(jobApplicationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.jobAppBack,
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary),
        ),
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.errorMessage != null
                ? Center(child: Text(state.errorMessage!))
                : RefreshIndicator(
                    onRefresh: () => ref.read(jobApplicationsProvider.notifier).loadApplications(widget.jobId),
                    child: CustomScrollView(
                      slivers: [
                        // Header
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.business_center, color: AppColors.primary, size: 36),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        l10n.jobAppTitle(widget.jobTitle),
                                        style: AppTextStyles.h2.copyWith(fontSize: 28, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.jobAppSubtitle,
                                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Applications List
                        SliverPadding(
                          padding: const EdgeInsets.all(20),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final application = state.applications[index];
                                return _buildApplicationCard(ref, application);
                              },
                              childCount: state.applications.length,
                            ),
                          ),
                        ),

                        // Stats Grid
                        if (state.applications.isNotEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                              child: _buildStatsGrid(ref, state),
                            ),
                          ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildApplicationCard(WidgetRef ref, ApplicationModel app) {
    final l10n = AppLocalizations.of(context)!;
    final initials = (app.applicant?.firstName.substring(0, 1).toUpperCase() ?? '') +
                     (app.applicant?.lastName.substring(0, 1).toUpperCase() ?? '');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
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
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Initials Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: AppTextStyles.h3.copyWith(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${app.applicant?.firstName} ${app.applicant?.lastName}',
                        style: AppTextStyles.h3.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.email_outlined, app.applicant?.email ?? ''),
                      const SizedBox(height: 4),
                      _buildInfoRow(Icons.phone_outlined, app.applicant?.phone ?? ''),
                      const SizedBox(height: 4),
                      _buildInfoRow(Icons.calendar_today_outlined, app.createdAt.toString().substring(0, 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Status Badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildStatusBadge(ref, app.status),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action Buttons
          if (app.status.toLowerCase() == l10n.jobAppStatusPending || app.status.toLowerCase() == 'reviewed')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (app.status.toLowerCase() == l10n.jobAppStatusPending)
                    Expanded(
                      child: _buildActionButton(
                        label: l10n.jobAppActionReview,
                        bgColor: AppColors.primary.withOpacity(0.08),
                        textColor: AppColors.primary,
                        onTap: () => _updateStatus(app.id, 'reviewed'),
                      ),
                    ),
                  if (app.status.toLowerCase() == l10n.jobAppStatusPending) const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      label: l10n.jobAppActionAccept,
                      bgColor: const Color(0xFFECFDF5),
                      textColor: const Color(0xFF10B981),
                      onTap: () => _updateStatus(app.id, l10n.jobAppStatusAccepted),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      label: l10n.jobAppActionReject,
                      bgColor: const Color(0xFFFEF2F2),
                      textColor: const Color(0xFFEF4444),
                      onTap: () => _updateStatus(app.id, 'rejected'),
                    ),
                  ),
                ],
              ),
            ),

          const Divider(height: 32, indent: 20, endIndent: 20),

          // Cover Letter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.description_outlined, size: 18, color: AppColors.textTertiary),
                    const SizedBox(width: 8),
                    Text(l10n.jobAppCoverLetter, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  app.coverLetter.isEmpty ? l10n.jobAppNotAvailable : app.coverLetter,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          const Divider(height: 32, indent: 20, endIndent: 20),

          // Full Profile Link
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: InkWell(
              onTap: () {
                 // Navigate to profile
              },
              child: Row(
                children: [
                  const Icon(Icons.person_outline, size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    l10n.jobAppFullProfile,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(WidgetRef ref, String status) {
    final l10n = AppLocalizations.of(context)!;
    String label = 'new';
    Color color = const Color(0xFFF59E0B);
    Color bgColor = const Color(0xFFFFFBEB);

    switch (status.toLowerCase()) {
      case 'pending':
        label = l10n.jobAppStatusPending;
        break;
      case 'reviewed':
        label = l10n.jobAppStatusPending;
        color = AppColors.primary;
        bgColor = AppColors.primary.withOpacity(0.08);
        break;
      case 'accepted':
        label = l10n.jobAppStatusAccepted;
        color = const Color(0xFF10B981);
        bgColor = const Color(0xFFECFDF5);
        break;
      case 'rejected':
        label = l10n.jobAppStatusRejected;
        color = const Color(0xFFEF4444);
        bgColor = const Color(0xFFFEF2F2);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(WidgetRef ref, dynamic state) {
    final l10n = AppLocalizations.of(context)!;
    final pending = state.applications.where((a) => a.status == l10n.jobAppStatusPending).length;
    final accepted = state.applications.where((a) => a.status == l10n.jobAppStatusAccepted).length;

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatItem('${state.applications.length}', l10n.jobAppTotal)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatItem('$pending', l10n.jobAppStatusPending, valueColor: const Color(0xFFF59E0B))),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatItem('0', l10n.jobAppStatusPending)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatItem('$accepted', l10n.jobAppStatusAccepted, valueColor: const Color(0xFF10B981))),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.h2.copyWith(color: valueColor ?? AppColors.textPrimary, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(int appId, String status) async {
    final l10n = AppLocalizations.of(context)!;
    final success = await ref.read(jobApplicationsProvider.notifier).updateApplicationStatus(appId, status);
    if (mounted) {
      context.showSnackBar(
        success ? l10n.jobAppDataSaved : l10n.errorOccurred,
        isError: !success,
      );
    }
  }
}
