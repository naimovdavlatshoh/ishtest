import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/loaders/app_loader.dart';
import '../../../core/widgets/empty_states/empty_state.dart';
import '../providers/jobs_provider.dart';
import '../providers/saved_jobs_provider.dart';
import '../widgets/job_card.dart';

class JobsScreen extends ConsumerStatefulWidget {
  const JobsScreen({super.key});

  @override
  ConsumerState<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends ConsumerState<JobsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() => ref.read(savedJobsProvider.notifier).loadSavedJobs());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final state = ref.read(jobsProvider);
      if (!state.isLoading && !state.isMoreLoading && state.jobs.length < state.total) {
        ref.read(jobsProvider.notifier).loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobsState = ref.watch(jobsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(
          'Vakansiyalar',
          style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _showFilters ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.tune,
                color: _showFilters ? AppColors.primary : AppColors.textPrimary,
                size: 22,
              ),
            ),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildFiltersSection(jobsState),
          Expanded(
            child: _buildJobsList(jobsState),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(JobsState state) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: _showFilters ? 90 : 50,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: state.filters.jobType ?? 'Ish turi',
                  isSelected: state.filters.jobType != null,
                  onTap: () => _showJobTypeDialog(state.filters),
                  onClear: state.filters.jobType != null 
                    ? () => ref.read(jobsProvider.notifier).updateFilters(state.filters.copyWith(clearJobType: true))
                    : null,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: state.filters.location ?? 'Viloyat',
                  isSelected: state.filters.location != null,
                  onTap: () => _showLocationDialog(state.filters),
                  onClear: state.filters.location != null 
                    ? () => ref.read(jobsProvider.notifier).updateFilters(state.filters.copyWith(clearLocation: true))
                    : null,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: state.filters.isRemote == true ? 'Masofaviy' : 'Ofisda',
                  isSelected: state.filters.isRemote != null,
                  onTap: () => _showRemoteDialog(state.filters),
                  onClear: state.filters.isRemote != null 
                    ? () => ref.read(jobsProvider.notifier).updateFilters(state.filters.copyWith(clearIsRemote: true))
                    : null,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: _formatSalaryLabel(state.filters),
                  isSelected: state.filters.salaryMin != null || state.filters.salaryMax != null,
                  onTap: () => _showSalaryDialog(state.filters),
                  onClear: state.filters.salaryMin != null || state.filters.salaryMax != null
                    ? () => ref.read(jobsProvider.notifier).updateFilters(state.filters.copyWith(clearSalaryMin: true, clearSalaryMax: true))
                    : null,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: state.filters.dateFrom ?? 'Sana',
                  isSelected: state.filters.dateFrom != null,
                  onTap: () => _showDateDialog(state.filters),
                  onClear: state.filters.dateFrom != null 
                    ? () => ref.read(jobsProvider.notifier).updateFilters(state.filters.copyWith(clearDateFrom: true))
                    : null,
                ),
              ],
            ),
          ),
          if (_showFilters) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '${state.total} ta natija topildi',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 11),
                ),
                const Spacer(),
                if (state.filters.jobType != null || state.filters.location != null || state.filters.isRemote != null || state.filters.salaryMin != null || state.filters.dateFrom != null)
                  GestureDetector(
                    onTap: () => ref.read(jobsProvider.notifier).clearFilters(),
                    child: Text(
                      'Tozalash', 
                      style: AppTextStyles.label.copyWith(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w600)
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatSalaryLabel(JobsFilters filters) {
    final min = filters.salaryMin;
    final max = filters.salaryMax;
    if (min == null && max == null) return 'Maosh';
    if (min != null && max != null) return '${min ~/ 1000}k - ${max ~/ 1000}k';
    if (min != null) return '>${min ~/ 1000}k';
    return '<${max! ~/ 1000}k';
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            if (isSelected && onClear != null)
              GestureDetector(
                onTap: () {
                  onClear();
                },
                child: const Icon(Icons.cancel, size: 14, color: Colors.white70),
              )
            else
              Icon(
                Icons.keyboard_arrow_down_rounded, 
                size: 16, 
                color: isSelected ? Colors.white70 : AppColors.textTertiary
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobsList(JobsState state) {
    if (state.isLoading) {
      return const AppLoader();
    }

    if (state.jobs.isEmpty) {
      return EmptyState(
        icon: Icons.work_outline,
        title: 'Vakansiyalar topilmadi',
        message: 'Filtrlarni o\'zgartirin',
        actionText: 'Yangilash',
        onAction: () => ref.read(jobsProvider.notifier).refreshJobs(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(jobsProvider.notifier).refreshJobs(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: state.jobs.length + (state.isMoreLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.jobs.length) {
            return const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            );
          }
          final job = state.jobs[index];
          final savedJobs = ref.watch(savedJobsProvider).jobs;
          final isSaved = savedJobs.any((j) => j.id == job.id);
          
          return JobCard(
            job: job,
            onTap: () {
              ref.read(jobsProvider.notifier).logJobView(job.id);
              context.push('/jobs/${job.id}', extra: job);
            },
            trailing: IconButton(
              icon: Icon(
                isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: isSaved ? AppColors.primary : AppColors.textTertiary,
              ),
              onPressed: () async {
                final notifier = ref.read(jobsProvider.notifier);
                final bool success;
                if (isSaved) {
                  success = await notifier.unsaveJob(job.id);
                } else {
                  success = await notifier.saveJob(job.id);
                }
                
                if (success) {
                  // Refresh saved jobs list to update UI everywhere
                  ref.read(savedJobsProvider.notifier).loadSavedJobs();
                }
              },
            ),
          );
        },
      ),
    );
  }

  void _showJobTypeDialog(JobsFilters current) {
    final options = ['full-time', 'part-time', 'internship', 'contract'];
    _showCustomDialog(
      title: 'Ish turi',
      content: (dialogContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((opt) => ListTile(
          title: Text(opt.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w500)),
          trailing: current.jobType == opt ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
          onTap: () {
            ref.read(jobsProvider.notifier).updateFilters(current.copyWith(jobType: opt));
            Navigator.of(dialogContext).pop();
          },
        )).toList(),
      ),
    );
  }

  void _showLocationDialog(JobsFilters current) {
    final controller = TextEditingController(text: current.location);
    _showCustomDialog(
      title: 'Manzil qidirish',
      content: (dialogContext) => TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Masalan: Toshkent',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
      actions: (dialogContext) => [
        TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text('Bekor qilish')),
        ElevatedButton(
          onPressed: () {
            ref.read(jobsProvider.notifier).updateFilters(current.copyWith(location: controller.text));
            Navigator.of(dialogContext).pop();
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
          child: const Text('Qidirish'),
        ),
      ],
    );
  }

  void _showRemoteDialog(JobsFilters current) {
    _showCustomDialog(
      title: 'Ish joyi',
      content: (dialogContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: Text('Masofaviy'),
            onTap: () {
              ref.read(jobsProvider.notifier).updateFilters(current.copyWith(isRemote: true));
              Navigator.of(dialogContext).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_city_outlined),
            title: const Text('Ofisda'),
            onTap: () {
              ref.read(jobsProvider.notifier).updateFilters(current.copyWith(isRemote: false));
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showSalaryDialog(JobsFilters current) {
    final minController = TextEditingController(text: current.salaryMin?.toString());
    final maxController = TextEditingController(text: current.salaryMax?.toString());
    _showCustomDialog(
      title: 'Maosh diapazoni',
      content: (dialogContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: minController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Minimum (so\'m)',
              labelStyle: const TextStyle(fontSize: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.remove_circle_outline, size: 20),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: maxController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Maksimum (so\'m)',
              labelStyle: const TextStyle(fontSize: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.add_circle_outline, size: 20),
            ),
          ),
        ],
      ),
      actions: (dialogContext) => [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(), 
          child: Text('Bekor qilish', style: TextStyle(color: Colors.grey[600]))
        ),
        ElevatedButton(
          onPressed: () {
            ref.read(jobsProvider.notifier).updateFilters(current.copyWith(
              salaryMin: int.tryParse(minController.text),
              salaryMax: int.tryParse(maxController.text),
            ));
            Navigator.of(dialogContext).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary, 
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
          ),
          child: Text('Saqlash'),
        ),
      ],
    );
  }

  void _showDateDialog(JobsFilters current) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2027),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final formattedDate = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      ref.read(jobsProvider.notifier).updateFilters(current.copyWith(dateFrom: formattedDate));
    }
  }

  void _showCustomDialog({
    required String title, 
    required Widget Function(BuildContext) content, 
    List<Widget> Function(BuildContext)? actions
  }) {
    showDialog(
      context: context,
      useRootNavigator: true, 
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
        title: Text(title, style: AppTextStyles.h3.copyWith(fontSize: 18)),
        content: content(dialogContext),
        actions: actions?.call(dialogContext),
        actionsPadding: const EdgeInsets.fromLTRB(0, 0, 16, 16),
      ),
    );
  }
}
