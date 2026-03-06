import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/my_jobs_provider.dart';
import '../../../shared/models/job_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/extensions.dart';
import 'job_form_screen.dart';

class MyJobsScreen extends ConsumerStatefulWidget {
  const MyJobsScreen({super.key});

  @override
  ConsumerState<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends ConsumerState<MyJobsScreen> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(myJobsProvider.notifier).loadMyJobs());
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myJobsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.errorMessage != null
                ? Center(child: Text(state.errorMessage!))
                : RefreshIndicator(
                    onRefresh: () => ref.read(myJobsProvider.notifier).loadMyJobs(),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.business_center, color: AppColors.primary, size: 36),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Mening vakansiyalarim',
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.h2.copyWith(fontSize: 28, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Vakansiya qo'shish",
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () => context.push('/jobs/add'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add, color: Colors.white, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  'Vakansiya qo\'shish',
                                  style: AppTextStyles.button.copyWith(color: Colors.white, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        ...state.jobs.map((job) => _buildJobCard(job)),
                        const SizedBox(height: 12),
                        if (state.jobs.isNotEmpty) ...[
                          _buildStatsSection(state),
                          const SizedBox(height: 20),
                        ],
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildJobCard(JobModel job) {
    final bool isDraft = job.status == 'Qoralama' || job.status == 'pending';
    final bool isClosed = job.status == 'closed';
    final bool isActive = job.status == 'Faol';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h3.copyWith(fontSize: 18, color: AppColors.textPrimary),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showJobActions(job),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.more_vert, color: AppColors.textTertiary, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildSmallIconText(Icons.location_on_outlined, job.location),
                const SizedBox(width: 16),
                _buildSmallIconText(Icons.business_center_outlined, _translateJobType(job.jobType)),
                const SizedBox(width: 16),
                _buildSmallIconText(Icons.calendar_today_outlined, _formatDate(job.createdAt)),
              ],
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (isDraft)
                    _buildBadge(
                      icon: Icons.edit_note,
                      label: 'Qoralama',
                      color: const Color(0xFF6B7280),
                      bgColor: const Color(0xFFF3F4F6),
                    )
                  else if (isClosed)
                    _buildBadge(
                      icon: Icons.cancel_outlined,
                      label: 'closed',
                      color: const Color(0xFFEF4444),
                      bgColor: const Color(0xFFFEE2E2),
                    )
                  else
                    _buildBadge(
                      icon: Icons.check_circle_outline,
                      label: 'Faol',
                      color: const Color(0xFF10B981),
                      bgColor: const Color(0xFFECFDF5),
                    ),
                  
                  const SizedBox(width: 8),
                  _buildBadge(
                    icon: Icons.people_outline,
                    label: 'applications',
                    color: AppColors.primary,
                    bgColor: AppColors.primary.withOpacity(0.1),
                    onTap: () => context.push('/jobs/${job.id}/applications', extra: job.title),
                  ),
                  
                  if (isDraft) ...[
                    const SizedBox(width: 8),
                    _buildBadge(
                      icon: Icons.send,
                      label: 'publish',
                      color: Colors.white,
                      bgColor: const Color(0xFF10B981),
                      onTap: () => _updateStatus(job.id, 'Faol'),
                    ),
                  ] else if (isActive) ...[
                    const SizedBox(width: 8),
                    _buildBadge(
                      icon: Icons.block,
                      label: 'close_job',
                      color: Colors.white,
                      bgColor: const Color(0xFFF59E0B),
                      onTap: () => _updateStatus(job.id, 'closed'),
                    ),
                  ],
                  
                  const SizedBox(width: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.visibility_outlined, size: 18, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                        '${job.viewsCount}',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showJobActions(JobModel job) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionItem(
              icon: Icons.visibility_outlined,
              label: "Ko'rish",
              onTap: () {
                Navigator.pop(context);
                context.push('/jobs/${job.id}', extra: job);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: Color(0xFF10B981)),
              title: Text(
                'Tahrirlash',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: const Color(0xFF10B981),
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                context.pop(); // Close bottom sheet
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => JobFormScreen(job: job),
                  ),
                );
              },
            ),
            if (job.status == 'Qoralama' || job.status == 'pending')
              _buildActionItem(
                icon: Icons.send_outlined,
                label: 'publish',
                color: const Color(0xFF10B981),
                onTap: () {
                  Navigator.pop(context);
                  _updateStatus(job.id, 'Faol');
                },
              )
            else if (job.status == 'Faol')
              _buildActionItem(
                icon: Icons.block_outlined,
                label: 'close_job',
                color: const Color(0xFFF59E0B),
                onTap: () {
                  Navigator.pop(context);
                  _updateStatus(job.id, 'closed');
                },
              ),
            const Divider(indent: 20, endIndent: 20),
            _buildActionItem(
              icon: Icons.delete_outline,
              label: 'O\'chirish',
              color: Colors.red,
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(job.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? const Color(0xFF374151)),
      title: Text(
        label,
        style: AppTextStyles.bodyLarge.copyWith(
          color: color ?? const Color(0xFF374151),
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  void _updateStatus(int jobId, String status) async {
    final success = await ref.read(myJobsProvider.notifier).updateJobStatus(jobId, status);
    if (context.mounted) {
      context.showSnackBar(
        success ? 'Holat yangilandi' : 'Xatolik yuz berdi',
        isError: !success,
      );
    }
  }

  void _showDeleteConfirmation(int jobId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('O\'chirish'),
        content: Text('Ushbu vakansiyani o\'chirmoqchimisiz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Bekor qilish')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(myJobsProvider.notifier).deleteJob(jobId);
              if (context.mounted) {
                context.showSnackBar(
                  success ? 'Vakansiya o\'chirildi' : 'O\'chirishda xatolik',
                  isError: !success,
                );
              }
            },
            child: Text('O\'chirish', style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildStatsSection(dynamic state) {
    final activeCount = state.jobs.where((j) => j.status == 'Faol').length;
    final draftCount = state.jobs.where((j) => j.status == 'Qoralama' || j.status == 'pending').length;
    final totalViews = state.jobs.fold(0, (sum, j) => sum + (j.viewsCount ?? 0));
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatItem('${state.jobs.length}', 'Jami')),
            const SizedBox(width: 16),
            Expanded(child: _buildStatItem('$activeCount', 'Faol')),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatItem('$draftCount', 'Qoralama')),
            const SizedBox(width: 16),
            Expanded(child: _buildStatItem('$totalViews', 'Ko\'rishlar', isViews: true)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label, {bool isViews = false}) {
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
            style: AppTextStyles.h2.copyWith(
              color: isViews ? AppColors.primary : AppColors.textPrimary,
              fontSize: 28,
            ),
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

  String _translateJobType(String type) {
    switch (type.toLowerCase()) {
      case 'full-time': return 'To\'liq kun';
      case 'part-time': return 'Yarim kun';
      case 'internship': return 'Amaliyot';
      case 'contract': return 'Kontrakt';
      default: return type;
    }
  }
}
