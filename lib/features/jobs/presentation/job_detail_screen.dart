import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linkedin_clone/core/theme/app_colors.dart';
import 'package:linkedin_clone/core/theme/app_text_styles.dart';
import 'package:linkedin_clone/core/widgets/buttons/primary_button.dart';
import 'package:linkedin_clone/shared/models/job_model.dart';
import 'package:linkedin_clone/shared/models/application_model.dart';
import 'package:linkedin_clone/features/jobs/providers/jobs_provider.dart';
import 'package:linkedin_clone/core/utils/extensions.dart';
import 'package:linkedin_clone/features/profile/providers/profile_me_provider.dart';
import 'package:linkedin_clone/features/jobs/providers/saved_jobs_provider.dart';

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

  void _showApplicationsModal(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
              child: Row(
                children: [
                  Text(l10n.vacanciesApplicationsList, style: AppTextStyles.h3),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.textTertiary),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _applications.isEmpty
                ? Center(child: Text(l10n.vacanciesNoApplications))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _applications.length,
                    itemBuilder: (context, index) {
                      final app = _applications[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.primary.withOpacity(0.1),
                                  child: Text(
                                    app.applicant?.firstName.substring(0, 1).toUpperCase() ?? 'U',
                                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${app.applicant?.firstName} ${app.applicant?.lastName}',
                                        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        app.applicant?.email ?? app.applicant?.phone ?? '',
                                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    app.status.toUpperCase(),
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (app.coverLetter.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text(l10n.vacanciesCoverLetterLabel, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(app.coverLetter, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                            ],
                            const SizedBox(height: 12),
                            Text(
                              DateTime.parse(app.createdAt).toLocal().toString().substring(0, 16),
                              style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
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
                      icon: const Icon(Icons.close, color: AppColors.textTertiary),
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
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: _isSaving 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Icon(isSaved ? Icons.bookmark : Icons.bookmark_border, color: isSaved ? AppColors.primary : AppColors.textPrimary),
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
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.business_center, color: AppColors.primary, size: 32),
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
                    _buildIconLabel(Icons.location_on_outlined, _job!.location),
                    _buildIconLabel(Icons.work_outline, _job!.jobType.toUpperCase()),
                    if (_job!.isRemote) _buildIconLabel(Icons.home_outlined, l10n.vacanciesFilterRemote, color: AppColors.success),
                    _buildIconLabel(Icons.calendar_today_outlined, _formatDate(_job!.createdAt)),
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
                onPressed: (_hasApplied || isAuthor) ? () => _showApplicationsModal(l10n) : () => _showApplyModal(l10n),
              ),
            ),
          ),
        ],
      ),
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
