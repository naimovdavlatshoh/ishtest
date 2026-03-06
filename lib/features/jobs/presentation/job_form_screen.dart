import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/utils/extensions.dart';
import '../../companies/providers/company_provider.dart';
import '../providers/my_jobs_provider.dart';
import '../../../shared/models/job_model.dart';

class JobFormScreen extends ConsumerStatefulWidget {
  final JobModel? job;
  final int? initialCompanyId;
  const JobFormScreen({super.key, this.job, this.initialCompanyId});

  @override
  ConsumerState<JobFormScreen> createState() => _JobFormScreenState();
}

class _JobFormScreenState extends ConsumerState<JobFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _salaryMinController;
  late final TextEditingController _salaryMaxController;
  late final TextEditingController _requirementsController;
  
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
    _requirementsController = TextEditingController(text: widget.job?.requirements.join('\n'));
    
    if (widget.job != null) {
      _selectedCompanyId = widget.job?.companyId ?? -1;
      _selectedJobType = widget.job?.jobType ?? 'full-time';
      _selectedCurrency = widget.job?.salaryCurrency ?? 'UZS';
      _isRemote = widget.job?.isRemote ?? false;
    } else if (widget.initialCompanyId != null) {
      _selectedCompanyId = widget.initialCompanyId;
    }
  }

  late final List<Map<String, String>> _jobTypes;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _jobTypes = [
      {'value': 'full-time', 'label': 'To\'liq kun'},
      {'value': 'part-time', 'label': 'Yarim kun'},
      {'value': 'internship', 'label': 'Amaliyot'},
      {'value': 'contract', 'label': 'Kontrakt'},
    ];
  }

  final List<String> _currencies = ['UZS', 'USD', 'EUR', 'RUB'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _requirementsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final requirements = _requirementsController.text
        .split('\n')
        .where((e) => e.trim().isNotEmpty)
        .toList();

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
      'requirements': requirements,
    };

    final bool success;
    if (widget.job != null) {
      success = await ref.read(myJobsProvider.notifier).updateJob(widget.job!.id, data);
    } else {
      success = await ref.read(myJobsProvider.notifier).createJob(data);
    }
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        context.showSnackBar(widget.job != null ? 'Vakansiya tahrirlandi' : 'Vakansiya yaratildi');
        context.pop();
      } else {
        context.showSnackBar('Xatolik yuz berdi', isError: true);
      }
    }
  }

  Widget build(BuildContext context) {
    final companiesAsync = ref.watch(myCompaniesProvider);

    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.job == null) ...[
              Text(
                'Yangi vakansiya',
                style: AppTextStyles.h2.copyWith(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Barcha ma\'lumotlarni to\'ldiring',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
            ],
            _buildSectionTitle('Asosiy ma\'lumotlar'),
            const SizedBox(height: 16),
            
            // Company Select
            companiesAsync.when(
              data: (companies) => _buildDropdownField<int>(
                label: 'Kompaniya',
                value: _selectedCompanyId,
                items: [
                  DropdownMenuItem(
                    value: -1,
                    child: const Text('Shaxsiy (kompaniyasiz)'),
                  ),
                  ...companies.map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text(c.name),
                  )).toList(),
                ],
                onChanged: (val) => setState(() => _selectedCompanyId = val),
                hint: 'Kompaniyani tanlang',
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Kompaniyalarni yuklashda xatolik'),
            ),
            const SizedBox(height: 20),

            _buildTextField(
              label: 'Lavozim nomi',
              controller: _titleController,
              hint: 'Masalan: Flutter Developer',
              validator: (val) => val == null || val.isEmpty ? 'Majburiy maydon' : null,
            ),
            const SizedBox(height: 20),

            _buildDropdownField<String>(
              label: 'Ish turi',
              value: _selectedJobType,
              items: _jobTypes.map((t) => DropdownMenuItem(
                value: t['value'],
                child: Text(t['label']!),
              )).toList(),
              onChanged: (val) => setState(() => _selectedJobType = val!),
            ),
            const SizedBox(height: 20),

            _buildTextField(
              label: 'Joylashuv',
              controller: _locationController,
              hint: 'Masalan: Toshkent',
              validator: (val) => val == null || val.isEmpty ? 'Majburiy maydon' : null,
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: SwitchListTile(
                value: _isRemote,
                onChanged: (val) => setState(() => _isRemote = val),
                title: const Text('Masofaviy ish', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                subtitle: const Text('Xodim uydan ishlashi mumkin', style: const TextStyle(fontSize: 12)),
                activeColor: AppColors.primary,
                dense: true,
              ),
            ),

            const SizedBox(height: 32),
            _buildSectionTitle('Maosh va valyuta'),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    label: 'Minimum maosh',
                    controller: _salaryMinController,
                    keyboardType: TextInputType.number,
                    hint: '0',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    label: 'Maksimum maosh',
                    controller: _salaryMaxController,
                    keyboardType: TextInputType.number,
                    hint: '0',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildDropdownField<String>(
              label: 'Valyuta',
              value: _selectedCurrency,
              items: _currencies.map((c) => DropdownMenuItem(
                value: c,
                child: Text(c),
              )).toList(),
              onChanged: (val) => setState(() => _selectedCurrency = val!),
            ),

            const SizedBox(height: 32),
            _buildSectionTitle('Tafsilotlar'),
            const SizedBox(height: 16),

            _buildTextField(
              label: 'Tavsif',
              controller: _descriptionController,
              maxLines: 5,
              hint: 'Vakansiya haqida batafsil...',
              validator: (val) => val == null || val.isEmpty ? 'Majburiy maydon' : null,
            ),
            const SizedBox(height: 20),

            _buildTextField(
              label: 'Talablar',
              controller: _requirementsController,
              maxLines: 5,
              hint: 'Har qatorga bitta talab...',
            ),

            const SizedBox(height: 40),
            PrimaryButton(
              text: widget.job != null ? 'Saqlash' : 'E\'lon yaratish',
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
        color: Colors.white,
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Vakansiyani tahrirlash'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: content,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.h3.copyWith(color: AppColors.primary),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
          ),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textTertiary),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16),
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
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
          ),
        ),
      ],
    );
  }
}
