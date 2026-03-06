import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linkedin_clone/core/theme/app_colors.dart';
import 'package:linkedin_clone/core/theme/app_text_styles.dart';
import 'package:linkedin_clone/core/widgets/buttons/primary_button.dart';
import 'package:linkedin_clone/features/companies/providers/company_provider.dart';
import 'package:linkedin_clone/shared/models/company_model.dart';
import 'package:linkedin_clone/features/profile/providers/profile_me_provider.dart';
import 'package:linkedin_clone/core/utils/extensions.dart';


class CompanyFormPage extends ConsumerStatefulWidget {
  final CompanyModel? company;

  const CompanyFormPage({super.key, this.company});

  @override
  ConsumerState<CompanyFormPage> createState() => _CompanyFormPageState();
}

class _CompanyFormPageState extends ConsumerState<CompanyFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _websiteController;
  late TextEditingController _locationController;
  late TextEditingController _industryController;
  late TextEditingController _sizeController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.company?.name ?? '');
    _descriptionController = TextEditingController(text: widget.company?.description ?? '');
    _websiteController = TextEditingController(text: widget.company?.website ?? '');
    _locationController = TextEditingController(text: widget.company?.location ?? '');
    _industryController = TextEditingController(text: widget.company?.industry ?? '');
    _sizeController = TextEditingController(text: widget.company?.size ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    _locationController.dispose();
    _industryController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final profileAsync = ref.read(profileMeProvider);
    final userId = profileAsync.asData?.value.userId;

    final data = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'website': _websiteController.text,
      'location': _locationController.text,
      'industry': _industryController.text,
      'size': _sizeController.text,
      if (userId != null) 'owner_id': userId,
    };

    bool success;
    if (widget.company != null) {
      success = await ref.read(myCompaniesProvider.notifier).updateCompany(widget.company!.id, data);
    } else {
      success = await ref.read(myCompaniesProvider.notifier).createCompany(data);
    }

    if (context.mounted) {
      setState(() => _isLoading = false);
      if (success) {
        context.showSnackBar(
          widget.company != null ? 'Kompaniya ma\'lumotlari yangilandi' : 'Kompaniya muvaffaqiyatli yaratildi',
        );
        context.pop();
      } else {
        context.showSnackBar('Xatolik yuz berdi', isError: true);
      }
    }
  }

  Widget build(BuildContext context) {
    final isEditing = widget.company != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Kompaniyani tahrirlash' : 'Yangi kompaniya'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Kompaniya haqida'),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Nomi *',
                controller: _nameController,
                validator: (v) => v!.isEmpty ? 'Maydonni to\'ldirish shart' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Tavsif *',
                controller: _descriptionController,
                maxLines: 4,
                validator: (v) => v!.isEmpty ? 'Maydonni to\'ldirish shart' : null,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Tafsilotlar'),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Veb-sayt *',
                controller: _websiteController,
                hint: 'https://example.com',
                validator: (v) => v!.isEmpty ? 'Maydonni to\'ldirish shart' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Manzil *',
                controller: _locationController,
                validator: (v) => v!.isEmpty ? 'Maydonni to\'ldirish shart' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Soha *',
                controller: _industryController,
                hint: 'masalan: IT, Moliya, Tibbiyot',
                validator: (v) => v!.isEmpty ? 'Maydonni to\'ldirish shart' : null,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: 'Kompaniya hajmi *',
                value: _sizeController.text.isEmpty ? null : _sizeController.text,
                items: const ['1-10', '11-50', '51-200', '200-500', '500+'],
                onChanged: (v) => setState(() => _sizeController.text = v ?? ''),
                validator: (v) => v == null || v.isEmpty ? 'Iltimos tanlang' : null,
              ),
              const SizedBox(height: 40),
              PrimaryButton(
                text: isEditing ? 'Saqlash' : 'Yaratish',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: Text('Bekor qilish', style: const TextStyle(color: AppColors.textSecondary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          validator: validator,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
