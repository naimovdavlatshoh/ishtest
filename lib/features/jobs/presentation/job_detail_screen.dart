import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linkedin_clone/core/theme/app_colors.dart';
import 'package:linkedin_clone/core/theme/app_text_styles.dart';
import 'package:linkedin_clone/core/widgets/buttons/primary_button.dart';
import 'package:linkedin_clone/shared/models/job_model.dart';
import 'package:linkedin_clone/shared/models/application_model.dart';
import 'package:linkedin_clone/features/jobs/providers/jobs_provider.dart';
import 'package:linkedin_clone/core/utils/extensions.dart';
import 'package:linkedin_clone/features/profile/providers/profile_me_provider.dart';
import 'package:linkedin_clone/features/jobs/providers/saved_jobs_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class JobDetailScreen extends ConsumerStatefulWidget {
  final JobModel? job;
  final int? jobId;

  const JobDetailScreen({
    super.key, 
    this.job,
    this.jobId,
  }) : assert(job != null || jobId != null);

  @override
  ConsumerState<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends ConsumerState<JobDetailScreen> {
  bool _isSaving = false;
  late Future<List<dynamic>> _applicationsFuture;
  List<ApplicationModel> _applications = [];
  bool _hasApplied = false;
  JobModel? _job;
  bool _isLoadingJob = false;

  @override
  void initState() {
    super.initState();
    _job = widget.job;
    if (_job == null && widget.jobId != null) {
      _loadJob();
    } else if (_job != null) {
      _fetchApplications();
    }
    Future.microtask(() => ref.read(savedJobsProvider.notifier).loadSavedJobs());
  }

  Future<void> _loadJob() async {
    setState(() => _isLoadingJob = true);
    final job = await ref.read(jobsProvider.notifier).getJobById(widget.jobId!);
    if (mounted) {
      setState(() {
        _job = job;
        _isLoadingJob = false;
      });
      if (_job != null) {
        _fetchApplications();
      }
    }
  }

  void _fetchApplications() {
    if (_job == null) return;
    _applicationsFuture = ref.read(jobsProvider.notifier).getApplicationsForJob(_job!.id);
    
    _applicationsFuture.then((data) {
      if (mounted) {
        final applications = (data as List).map((e) => ApplicationModel.fromJson(e)).toList();
        final profileAsync = ref.read(profileMeProvider);
        final currentUserId = profileAsync.asData?.value.userId;
        
        setState(() {
          _applications = applications;
          _hasApplied = currentUserId != null && applications.any((app) => app.applicantId == currentUserId);
        });
      }
    });
  }

  void _handleSave() async {
    if (_isSaving || _job == null) return;
    
    setState(() => _isSaving = true);
    
    final isSaved = ref.read(savedJobsProvider).jobs.any((j) => j.id == _job!.id);
    final bool success;
    if (isSaved) {
      success = await ref.read(jobsProvider.notifier).unsaveJob(_job!.id);
    } else {
      success = await ref.read(jobsProvider.notifier).saveJob(_job!.id);
    }
    
    if (mounted) {
      if (success) {
        await ref.read(savedJobsProvider.notifier).loadSavedJobs();
      }
      setState(() => _isSaving = false);
    }
  }

  String _formatSalary(int? min, int? max, String currency, AppLocalizations l10n) {
    if (min == null && max == null) return l10n.vacanciesSalaryNegotiable;
    if (min != null && max != null) {
      return '${min.toString()} - ${max.toString()} $currency';
    } else if (min != null) {
      return '${l10n.vacanciesSalaryFrom} ${min.toString()} $currency';
    } else {
      return '${max.toString()} $currency ${l10n.vacanciesSalaryTo}';
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  void _openApplications() {
    final JobModel? job = _job;
    if (job == null) return;
    context.push('/jobs/${job.id}/applications', extra: job.title);
  }

  void _showApplyModal(AppLocalizations l10n) {
    final TextEditingController coverLetterController = TextEditingController(text: "test");
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 16, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.vacanciesApplyTitle, style: AppTextStyles.h3.copyWith(fontSize: 20)),
                          const SizedBox(height: 8),
                          Text(
                            l10n.vacanciesApplyInvite(_job!.company?.name?.toUpperCase() ?? l10n.vacanciesCompany),
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(LucideIcons.x, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.vacanciesCoverLetter, style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: coverLetterController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: l10n.vacanciesWriteHereHint,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      text: l10n.vacanciesApplyBtn,
                      isLoading: isSubmitting,
                      onPressed: () async {
                        final l10n = AppLocalizations.of(context)!;
                        setModalState(() => isSubmitting = true);
                        final success = await ref.read(jobsProvider.notifier).applyToJob(_job!.id, coverLetterController.text);
                        if (context.mounted) {
                          Navigator.pop(context);
                          context.showSnackBar(
                            success ? l10n.vacanciesApplySuccess : l10n.vacanciesApplyError,
                            isError: !success,
                          );
                          if (success) _fetchApplications();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoadingJob) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_job == null) return Scaffold(appBar: AppBar(), body: Center(child: Text(l10n.vacanciesNoJobs)));

    final profileAsync = ref.watch(profileMeProvider);
    final currentUserId = profileAsync.asData?.value.userId;
    final isAuthor = currentUserId != null && _job!.authorId == currentUserId;
    final isSaved = ref.watch(savedJobsProvider).jobs.any((j) => j.id == _job!.id);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: _isSaving 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Icon(isSaved ? LucideIcons.bookmark : LucideIcons.bookmark, color: isSaved ? AppColors.primary : AppColors.textPrimary),
            onPressed: _handleSave,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _job!.image != null && _job!.image!.isNotEmpty
                          ? Image.network(
                              _job!.image!.fullImageUrl,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _jobLogoPlaceholder(),
                            )
                          : _jobLogoPlaceholder(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_job!.title, style: AppTextStyles.h2.copyWith(fontSize: 22)),
                          const SizedBox(height: 4),
                          Text(_job!.company?.name ?? l10n.vacanciesCompany, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12, runSpacing: 12,
                  children: [
                    _buildIconLabel(LucideIcons.mapPin, _job!.location),
                    _buildIconLabel(LucideIcons.briefcase, _job!.jobType.toUpperCase()),
                    if (_job!.isRemote) _buildIconLabel(LucideIcons.house, l10n.vacanciesFilterRemote, color: AppColors.success),
                    _buildIconLabel(LucideIcons.calendar, _formatDate(_job!.createdAt)),
                  ],
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider()),
                Text(l10n.vacanciesSalaryLabel, style: AppTextStyles.h3),
                const SizedBox(height: 8),
                Text(_formatSalary(_job!.salaryMin, _job!.salaryMax, _job!.salaryCurrency, l10n), style: AppTextStyles.h2.copyWith(color: AppColors.success, fontSize: 20)),
                const SizedBox(height: 32),
                Text(l10n.vacanciesDescriptionLabel, style: AppTextStyles.h3),
                const SizedBox(height: 12),
                Text(_job!.description, style: AppTextStyles.bodyMedium.copyWith(height: 1.6, color: AppColors.textPrimary.withOpacity(0.8))),
                const SizedBox(height: 32),
                if (_job!.requirements.isNotEmpty) ...[
                  Text(l10n.vacanciesRequirementsLabel, style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  ..._job!.requirements.map((req) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(margin: const EdgeInsets.only(top: 6), width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                        const SizedBox(width: 12),
                        Expanded(child: Text(req, style: AppTextStyles.bodyMedium.copyWith(height: 1.4))),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))]),
              child: PrimaryButton(
                text: (_hasApplied || isAuthor) ? l10n.vacanciesSeeApplications : l10n.vacanciesApplyBtn,
                onPressed: (_hasApplied || isAuthor) ? _openApplications : () => _showApplyModal(l10n),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _jobLogoPlaceholder() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(LucideIcons.briefcase, color: AppColors.primary, size: 32),
    );
  }

  Widget _buildIconLabel(IconData icon, String label, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color ?? AppColors.textTertiary),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: color ?? AppColors.textSecondary, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
