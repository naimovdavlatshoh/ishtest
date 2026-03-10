import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/job_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class JobCard extends ConsumerWidget {
  final JobModel job;
  final VoidCallback? onTap;
  final Widget? trailing;

  const JobCard({
    super.key,
    required this.job,
    this.onTap,
    this.trailing,
  });

  String _formatSalary(int? min, int? max, String currency, AppLocalizations l10n) {
    if (min == null && max == null) return l10n.vacanciesSalaryNegotiable;
    if (min != null && max != null) {
      return '$min - $max $currency';
    } else if (min != null) {
      return '${l10n.vacanciesSalaryFrom} $min $currency';
    } else {
      return '$max $currency ${l10n.vacanciesSalaryTo}';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final companyName = job.company?.name ?? l10n.vacanciesCompany;
    final companyIndustry = job.company?.industry ?? l10n.vacanciesIndustryNotSpecified;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.business_center, color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: AppTextStyles.h4.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            companyName,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            companyIndustry,
                            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildTag(Icons.location_on_outlined, job.location, maxWidth: 220),
                    _buildTag(Icons.work_outline, _getJobTypeName(job.jobType, l10n)),
                    if (job.isRemote)
                      _buildTag(Icons.home_outlined, l10n.vacanciesFilterRemote, color: AppColors.success),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _formatSalary(job.salaryMin, job.salaryMax, job.salaryCurrency, l10n),
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(job.createdAt, l10n),
                      style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.remove_red_eye_outlined, size: 14, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          '${job.viewsCount}',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getJobTypeName(String type, AppLocalizations l10n) {
    switch (type.toLowerCase()) {
      case 'full-time': return l10n.vacanciesFullTime;
      case 'part-time': return l10n.vacanciesPartTime;
      case 'internship': return l10n.vacanciesInternship;
      case 'contract': return l10n.vacanciesContract;
      default: return type;
    }
  }

  String _formatDate(String dateStr, AppLocalizations l10n) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays == 0) return l10n.feedToday;
      if (diff.inDays == 1) return l10n.messagesYesterday;
      if (diff.inDays < 7) return '${diff.inDays} ${l10n.feedDaysAgo}';
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  Widget _buildTag(IconData icon, String label, {Color? color, double? maxWidth}) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: (color ?? AppColors.textTertiary).withOpacity(0.05),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color ?? AppColors.textTertiary),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: color ?? AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
