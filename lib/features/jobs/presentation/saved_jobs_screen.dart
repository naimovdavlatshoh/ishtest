import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/saved_jobs_provider.dart';
import '../widgets/job_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class SavedJobsScreen extends ConsumerStatefulWidget {
  const SavedJobsScreen({super.key});

  @override
  ConsumerState<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends ConsumerState<SavedJobsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(savedJobsProvider.notifier).loadSavedJobs());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(savedJobsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.savedJobsTitle),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
              ? Center(child: Text(state.errorMessage!))
              : state.jobs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bookmark_border, size: 64, color: AppColors.textTertiary.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text(
                            l10n.savedJobsEmpty,
                            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => ref.read(savedJobsProvider.notifier).loadSavedJobs(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.jobs.length,
                        itemBuilder: (context, index) {
                          final job = state.jobs[index];
                          return JobCard(
                            job: job,
                            onTap: () => context.push('/jobs/${job.id}', extra: job),
                            trailing: IconButton(
                              icon: const Icon(Icons.bookmark, color: AppColors.primary),
                              onPressed: () => ref.read(savedJobsProvider.notifier).unsaveJob(job.id),
                              tooltip: 'remove',
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
