import 'dart:async';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

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
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
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
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.length >= 2) {
        ref.read(jobsProvider.notifier).setSearch(query);
      } else if (query.isEmpty) {
        ref.read(jobsProvider.notifier).setSearch(null);
      }
    });
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: '${l10n.vacanciesSearchHint}...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary, fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: AppColors.iconSecondary, size: 18),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
          ),
        ),
        actions: const [
          SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          _buildFiltersSection(jobsState, l10n),
          Expanded(
            child: _buildJobsList(jobsState, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection(JobsState state, AppLocalizations l10n) {
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
                  label: state.filters.jobType ?? l10n.vacanciesFilterType,
                  isSelected: state.filters.jobType != null,
                  onTap: () => _showJobTypeDialog(state.filters, l10n),
                  onClear: state.filters.jobType != null 
                    ? () => ref.read(jobsProvider.notifier).updateFilters(state.filters.copyWith(clearJobType: true))
                    : null,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: state.filters.location ?? l10n.vacanciesFilterLocation,
                  isSelected: state.filters.location != null,
                  onTap: () => _showLocationDialog(state.filters, l10n),
                  onClear: state.filters.location != null 
                    ? () => ref.read(jobsProvider.notifier).updateFilters(state.filters.copyWith(clearLocation: true))
                    : null,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: state.filters.isRemote == true ? l10n.vacanciesFilterRemote : l10n.vacanciesFilterOffice,
                  isSelected: state.filters.isRemote != null,
                  onTap: () => _showRemoteDialog(state.filters, l10n),
                  onClear: state.filters.isRemote != null 
                    ? () => ref.read(jobsProvider.notifier).updateFilters(state.filters.copyWith(clearIsRemote: true))
                    : null,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: _formatSalaryLabel(state.filters, l10n),
                  isSelected: state.filters.salaryMin != null || state.filters.salaryMax != null,
                  onTap: () => _showSalaryDialog(state.filters, l10n),
                  onClear: state.filters.salaryMin != null || state.filters.salaryMax != null
                    ? () => ref.read(jobsProvider.notifier).updateFilters(state.filters.copyWith(clearSalaryMin: true, clearSalaryMax: true))
                    : null,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: state.filters.dateFrom ?? l10n.vacanciesFilterDate,
                  isSelected: state.filters.dateFrom != null,
                  onTap: () => _showDateDialog(state.filters, l10n),
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
                  l10n.vacanciesResultsFound(state.total),
                  style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 11),
                ),
                const Spacer(),
                if (state.filters.jobType != null || state.filters.location != null || state.filters.isRemote != null || state.filters.salaryMin != null || state.filters.dateFrom != null)
                  GestureDetector(
                    onTap: () => ref.read(jobsProvider.notifier).clearFilters(),
                    child: Text(
                      l10n.vacanciesClear, 
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

  String _formatSalaryLabel(JobsFilters filters, AppLocalizations l10n) {
    final min = filters.salaryMin;
    final max = filters.salaryMax;
    if (min == null && max == null) return l10n.vacanciesFilterSalary;
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

  Widget _buildJobsList(JobsState state, AppLocalizations l10n) {
    if (state.isLoading) {
      return const AppLoader();
    }

    if (state.jobs.isEmpty) {
      return EmptyState(
        icon: Icons.work_outline,
        title: l10n.vacanciesNotFound,
        message: l10n.vacanciesChangeFilters,
        actionText: l10n.vacanciesRefresh,
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

  void _showJobTypeDialog(JobsFilters current, AppLocalizations l10n) {
    final options = ['full-time', 'part-time', 'internship', 'contract'];
    _showCustomDialog(
      title: l10n.vacanciesFilterType,
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

  void _showLocationDialog(JobsFilters current, AppLocalizations l10n) {
    final controller = TextEditingController(text: current.location);
    _showCustomDialog(
      title: l10n.vacanciesSearchLocation,
      content: (dialogContext) => TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: l10n.vacanciesSearchHint,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
      actions: (dialogContext) => [
        TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(l10n.vacanciesCancel)),
        ElevatedButton(
          onPressed: () {
            ref.read(jobsProvider.notifier).updateFilters(current.copyWith(location: controller.text));
            Navigator.of(dialogContext).pop();
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
          child: Text(l10n.vacanciesSearchBtn),
        ),
      ],
    );
  }

  void _showRemoteDialog(JobsFilters current, AppLocalizations l10n) {
    _showCustomDialog(
      title: l10n.vacanciesWorkPlace,
      content: (dialogContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: Text(l10n.vacanciesFilterRemote),
            onTap: () {
              ref.read(jobsProvider.notifier).updateFilters(current.copyWith(isRemote: true));
              Navigator.of(dialogContext).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_city_outlined),
            title: Text(l10n.vacanciesFilterOffice),
            onTap: () {
              ref.read(jobsProvider.notifier).updateFilters(current.copyWith(isRemote: false));
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showSalaryDialog(JobsFilters current, AppLocalizations l10n) {
    final minController = TextEditingController(text: current.salaryMin?.toString());
    final maxController = TextEditingController(text: current.salaryMax?.toString());
    _showCustomDialog(
      title: l10n.vacanciesSalaryRange,
      content: (dialogContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: minController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: l10n.vacanciesMinSalary,
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
              labelText: l10n.vacanciesMaxSalary,
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
          child: Text(l10n.vacanciesCancel, style: TextStyle(color: Colors.grey[600]))
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
          child: Text(l10n.vacanciesSave),
        ),
      ],
    );
  }

  void _showDateDialog(JobsFilters current, AppLocalizations l10n) async {
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
