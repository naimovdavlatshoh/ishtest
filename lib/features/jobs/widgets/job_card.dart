import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/models/job_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class JobCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback? onTap;
  final Widget? trailing;

  const JobCard({
    super.key,
    required this.job,
    this.onTap,
    this.trailing,
  });

  String _formatSalary(int? min, int? max, String currency) {
    if (min == null && max == null) return 'Maosh kelishiladi';
    final formatter = NumberFormat.decimalPattern('uz');
    if (min != null && max != null) {
      return '${formatter.format(min)} - ${formatter.format(max)} $currency';
    } else if (min != null) {
      return 'dan ${formatter.format(min)} $currency';
    } else {
      return '${formatter.format(max)} $currency gacha';
    }
  }

  @override
  Widget build(BuildContext context) {
    final companyName = job.company?.name ?? 'Kompaniya nomi ko\'rsatilmagan';
    final companyIndustry = job.company?.industry ?? 'Soha ko\'rsatilmagan';

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
                    // Company Logo Placeholder
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
                    _buildTag(Icons.work_outline, _getJobTypeName(job.jobType)),
                    if (job.isRemote)
                      _buildTag(Icons.home_outlined, 'Masofaviy', color: AppColors.success),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _formatSalary(job.salaryMin, job.salaryMax, job.salaryCurrency),
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
                      _formatDate(job.createdAt),
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

  String _getJobTypeName(String type) {
    switch (type.toLowerCase()) {
      case 'full-time': return 'To\'liq stavka';
      case 'part-time': return 'Yarim stavka';
      case 'internship': return 'Stajirovka';
      case 'contract': return 'Shartnoma';
      default: return type;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      
      if (diff.inDays == 0) return 'Bugun';
      if (diff.inDays == 1) return 'Kecha';
      if (diff.inDays < 7) return '${diff.inDays} kun oldin';
      return DateFormat('dd.MM.yyyy').format(date);
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
