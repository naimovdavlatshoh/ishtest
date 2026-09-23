import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/utils/extensions.dart';
import '../../companies/providers/company_provider.dart';
import '../providers/my_jobs_provider.dart';
import '../../../shared/models/job_model.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class JobFormScreen extends ConsumerStatefulWidget {
  final JobModel? job;
  final int? initialCompanyId;
  const JobFormScreen({super.key, this.job, this.initialCompanyId});

  @override
  ConsumerState<JobFormScreen> createState() => _JobFormScreenState();
}

class _JobFormScreenState extends ConsumerState<JobFormScreen> {
  static const Color _cardBlue = Color(0xFF3B82F6);
  static const Color _cardGreen = Color(0xFF22C55E);
  static const Color _cardPurple = Color(0xFF8B5CF6);
  static const Color _remoteTeal = Color(0xFF14B8A6);

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _salaryMinController;
  late final TextEditingController _salaryMaxController;
  late final TextEditingController _requirementInputController;

  List<String> _requirements = [];
  Uint8List? _pickedLogoBytes;
  String _pickedLogoName = 'logo.jpg';

  int? _selectedCompanyId = -1; // Default to 'Shaxsiy'
  String _selectedJobType = 'full-time';
  String _selectedCurrency = 'UZS';
  bool _isRemote = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.job?.title);
    _descriptionController = TextEditingController(text: widget.job?.description);
    _locationController = TextEditingController(text: widget.job?.location);
    _salaryMinController = TextEditingController(text: widget.job?.salaryMin?.toString());
    _salaryMaxController = TextEditingController(text: widget.job?.salaryMax?.toString());
    _requirementInputController = TextEditingController();
    _requirements = widget.job != null ? List<String>.from(widget.job!.requirements) : [];

    if (widget.job != null) {
      _selectedCompanyId = widget.job?.companyId ?? -1;
      _selectedJobType = widget.job?.jobType ?? 'full-time';
      _selectedCurrency = widget.job?.salaryCurrency ?? 'UZS';
      _isRemote = widget.job?.isRemote ?? false;
    } else if (widget.initialCompanyId != null) {
      _selectedCompanyId = widget.initialCompanyId;
    }
  }

  List<Map<String, String>> _jobTypesOf(AppLocalizations l10n) => [
        {'value': 'full-time', 'label': l10n.vacanciesFullTime},
        {'value': 'part-time', 'label': l10n.vacanciesPartTime},
        {'value': 'internship', 'label': l10n.vacanciesInternship},
        {'value': 'contract', 'label': l10n.vacanciesContract},
      ];

  final List<String> _currencies = ['UZS', 'USD', 'EUR', 'RUB'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _requirementInputController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final PlatformFile file = result.files.first;
    Uint8List? bytes = file.bytes;
    if ((bytes == null || bytes.isEmpty) && file.path != null) {
      bytes = await File(file.path!).readAsBytes();
    }
    if (bytes == null || bytes.isEmpty || !mounted) return;

    setState(() {
      _pickedLogoBytes = bytes;
      _pickedLogoName = file.name.trim().isEmpty ? 'logo.jpg' : file.name.trim();
    });
  }

  void _addRequirement() {
    final text = _requirementInputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _requirements.add(text);
      _requirementInputController.clear();
    });
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'location': _locationController.text.trim(),
      'company_id': _selectedCompanyId == -1 ? null : _selectedCompanyId, // Map -1 back to null for API
      'job_type': _selectedJobType,
      'salary_currency': _selectedCurrency,
      'salary_min': int.tryParse(_salaryMinController.text),
      'salary_max': int.tryParse(_salaryMaxController.text),
      'is_remote': _isRemote,
      'requirements': _requirements,
    };

    bool success;
    bool logoUploaded = true;
    if (widget.job != null) {
      success = await ref.read(myJobsProvider.notifier).updateJob(widget.job!.id, data);
      if (success && _pickedLogoBytes != null) {
        final String? imageUrl = await ref.read(myJobsProvider.notifier).uploadJobImage(
              widget.job!.id,
              _pickedLogoBytes!,
              _pickedLogoName,
            );
        logoUploaded = imageUrl != null;
      }
    } else {
      final int? newJobId = await ref.read(myJobsProvider.notifier).createJob(data);
      success = newJobId != null;
      if (success && _pickedLogoBytes != null) {
        final String? imageUrl = await ref.read(myJobsProvider.notifier).uploadJobImage(
              newJobId!,
              _pickedLogoBytes!,
              _pickedLogoName,
            );
        logoUploaded = imageUrl != null;
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        context.showSnackBar(
          logoUploaded
              ? (widget.job != null ? l10n.jobFormModified : l10n.jobFormCreated)
              : 'Ish saqlandi, lekin logo yuklanmadi',
          isError: !logoUploaded,
        );
        if (widget.job != null) {
          // Editing: this screen was pushed directly on top of My Jobs, so
          // popping is enough to return to it.
          context.pop();
        } else {
          // Creating: this screen can be reached from several places (My
          // Jobs, the drawer, a company page), so go there explicitly
          // instead of popping back to wherever the user came from.
          context.go('/jobs/my-jobs');
        }
      } else {
        context.showSnackBar(l10n.errorOccurred, isError: true);
      }
    }
  }

  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final jobTypes = _jobTypesOf(l10n);
    final companiesAsync = ref.watch(myCompaniesProvider);

    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.job == null) ...[
              Row(
                children: [
                  const Icon(LucideIcons.briefcase, color: AppColors.primary, size: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.jobFormTitleNew,
                      style: AppTextStyles.h2.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                l10n.jobFormSubtitle,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
            ],

            // Card 1: Asosiy ma'lumot
            _buildCard(
              icon: LucideIcons.fileText,
              iconColor: _cardBlue,
              title: l10n.jobFormSectionBasic,
              children: [
                _buildTextField(
                  label: l10n.jobFormLabelTitle,
                  controller: _titleController,
                  hint: l10n.jobFormHintTitle,
                  required: true,
                  validator: (val) => val == null || val.isEmpty ? l10n.jobFormErrorRequired : null,
                ),
                const SizedBox(height: 20),

                companiesAsync.when(
                  data: (companies) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDropdownField<int>(
                        label: l10n.jobFormLabelCompany,
                        value: _selectedCompanyId,
                        items: [
                          DropdownMenuItem(
                            value: -1,
                            child: Text(l10n.jobFormCompanyPersonal),
                          ),
                          ...companies.map((c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.name),
                              )),
                        ],
                        onChanged: (val) => setState(() => _selectedCompanyId = val),
                        hint: l10n.jobFormHintCompany,
                        prefixIcon: LucideIcons.building2,
                      ),
                      if (companies.isEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          l10n.jobFormCompanyNoneHelper,
                          style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ],
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => Text(l10n.jobFormErrorLoadingCompanies),
                ),
                const SizedBox(height: 20),

                _buildLogoPicker(l10n),
                const SizedBox(height: 20),

                _buildTextField(
                  label: l10n.jobFormLabelDescription,
                  controller: _descriptionController,
                  maxLines: 5,
                  hint: l10n.jobFormHintDescription,
                  required: true,
                  validator: (val) => val == null || val.isEmpty ? l10n.jobFormErrorRequired : null,
                ),
                const SizedBox(height: 20),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildDropdownField<String>(
                        label: l10n.jobFormLabelType,
                        value: _selectedJobType,
                        items: jobTypes.map((t) => DropdownMenuItem(
                              value: t['value'],
                              child: Text(t['label']!),
                            )).toList(),
                        onChanged: (val) => setState(() => _selectedJobType = val!),
                        required: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        label: l10n.jobFormLabelLocation,
                        controller: _locationController,
                        hint: l10n.jobFormHintLocation,
                        prefixIcon: LucideIcons.mapPin,
                        required: true,
                        validator: (val) => val == null || val.isEmpty ? l10n.jobFormErrorRequired : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: _isRemote,
                        onChanged: (val) => setState(() => _isRemote = val ?? false),
                        activeColor: AppColors.primary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(LucideIcons.globe, size: 18, color: _remoteTeal),
                    const SizedBox(width: 8),
                    Text(
                      l10n.jobFormLabelRemote,
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Card 2: Maosh
            _buildCard(
              icon: LucideIcons.dollarSign,
              iconColor: _cardGreen,
              title: l10n.jobFormSectionSalary,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: l10n.jobFormLabelMinSalary,
                        controller: _salaryMinController,
                        keyboardType: TextInputType.number,
                        hint: l10n.jobFormHintMinSalary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        label: l10n.jobFormLabelMaxSalary,
                        controller: _salaryMaxController,
                        keyboardType: TextInputType.number,
                        hint: l10n.jobFormHintMaxSalary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDropdownField<String>(
                  label: l10n.jobFormLabelCurrency,
                  value: _selectedCurrency,
                  items: _currencies.map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      )).toList(),
                  onChanged: (val) => setState(() => _selectedCurrency = val!),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Card 3: Talablar
            _buildCard(
              icon: LucideIcons.building2,
              iconColor: _cardPurple,
              title: l10n.jobFormSectionDetails,
              children: [
                _buildLabel(l10n.jobFormLabelRequirements, false),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _requirementInputController,
                        decoration: _fieldDecoration(hint: l10n.jobFormHintRequirements),
                        onFieldSubmitted: (_) => _addRequirement(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Material(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: _addRequirement,
                        child: const SizedBox(
                          width: 52,
                          height: 52,
                          child: Icon(LucideIcons.plus, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_requirements.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _requirements.map(_buildRequirementChip).toList(),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 32),
            PrimaryButton(
              text: widget.job != null ? l10n.vacanciesSave : l10n.jobFormBtnCreate,
              isLoading: _isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );

    if (widget.job == null) {
      return Container(
        color: AppColors.background,
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.jobFormTitleEdit),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: content,
    );
  }

  Widget _buildCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.h3.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLogoPicker(AppLocalizations l10n) {
    final String? existingImage = widget.job?.image;
    final bool hasImage = _pickedLogoBytes != null || (existingImage != null && existingImage.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(l10n.jobFormLabelLogo, false),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                image: _pickedLogoBytes != null
                    ? DecorationImage(image: MemoryImage(_pickedLogoBytes!), fit: BoxFit.cover)
                    : (existingImage != null && existingImage.isNotEmpty
                        ? DecorationImage(image: NetworkImage(existingImage.fullImageUrl), fit: BoxFit.cover)
                        : null),
              ),
              child: !hasImage
                  ? const Icon(LucideIcons.briefcase, color: AppColors.textTertiary)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickLogo,
                icon: const Icon(LucideIcons.imagePlus, size: 16),
                label: Text(l10n.jobFormChooseLogo),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          l10n.jobFormLogoHint,
          style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
        ),
      ],
    );
  }

  Widget _buildRequirementChip(String req) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Text(
              req,
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: () => setState(() => _requirements.remove(req)),
            child: const Icon(LucideIcons.x, size: 14, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label, bool required) {
    return RichText(
      text: TextSpan(
        style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        children: [
          TextSpan(text: label),
          if (required) const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration({String? hint, IconData? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18, color: AppColors.textTertiary) : null,
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    IconData? prefixIcon,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, required),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: _fieldDecoration(hint: hint, prefixIcon: prefixIcon),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? hint,
    IconData? prefixIcon,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, required),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          icon: const Icon(LucideIcons.chevronDown, color: AppColors.textTertiary),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16),
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          decoration: _fieldDecoration(hint: hint, prefixIcon: prefixIcon),
        ),
      ],
    );
  }
}
