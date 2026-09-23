import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linkedin_clone/core/theme/app_colors.dart';
import 'package:linkedin_clone/core/theme/app_text_styles.dart';
import 'package:linkedin_clone/core/utils/extensions.dart';
import 'package:linkedin_clone/shared/models/service_model.dart';
import '../providers/my_services_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ServiceFormScreen extends ConsumerStatefulWidget {
  const ServiceFormScreen({super.key});

  @override
  ConsumerState<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends ConsumerState<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceMinController = TextEditingController();
  final _priceMaxController = TextEditingController();

  String _selectedCategory = 'other';
  String _selectedPriceType = 'negotiable';
  String? _pickedImagePath;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _priceMinController.dispose();
    _priceMaxController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty && result.files.first.path != null) {
      setState(() => _pickedImagePath = result.files.first.path);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final data = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'location': _locationController.text.trim(),
      'category': _selectedCategory,
      'price_min': int.tryParse(_priceMinController.text),
      'price_max': int.tryParse(_priceMaxController.text),
      'price_type': _selectedPriceType,
    };

    final int? newServiceId = await ref.read(myServicesProvider.notifier).createService(data);
    final bool success = newServiceId != null;
    if (success && _pickedImagePath != null) {
      await ref.read(myServicesProvider.notifier).uploadServiceImage(newServiceId, _pickedImagePath!);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        context.showSnackBar("Xizmat muvaffaqiyatli qo'shildi");
        context.go('/services/my-services');
      } else {
        context.showSnackBar('Xatolik yuz berdi', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.wrench, color: AppColors.primary, size: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Xizmat e'lon qilish",
                      style: AppTextStyles.h2.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Container(
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
                    _buildImagePicker(),
                    const SizedBox(height: 20),

                    _buildTextField(
                      label: 'Sarlavha',
                      controller: _titleController,
                      hint: 'Masalan: Santexnik xizmatlari',
                      validator: (val) => val == null || val.isEmpty ? "Majburiy maydon" : null,
                    ),
                    const SizedBox(height: 20),

                    _buildTextField(
                      label: 'Tavsif',
                      controller: _descriptionController,
                      maxLines: 5,
                      hint: 'Xizmatingiz haqida batafsil yozing',
                      validator: (val) => val == null || val.isEmpty ? "Majburiy maydon" : null,
                    ),
                    const SizedBox(height: 20),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildDropdownField<String>(
                            label: 'Kategoriya',
                            value: _selectedCategory,
                            items: serviceCategoryLabels.entries
                                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                                .toList(),
                            onChanged: (val) => setState(() => _selectedCategory = val!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            label: 'Joylashuv',
                            controller: _locationController,
                            hint: 'masalan, Toshkent',
                            validator: (val) => val == null || val.isEmpty ? "Majburiy maydon" : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _buildDropdownField<String>(
                      label: "Narx turi",
                      value: _selectedPriceType,
                      items: servicePriceTypeLabels.entries
                          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedPriceType = val!),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: "Min narx",
                            controller: _priceMinController,
                            keyboardType: TextInputType.number,
                            hint: '150.000',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            label: "Max narx",
                            controller: _priceMaxController,
                            keyboardType: TextInputType.number,
                            hint: '500.000',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _submit,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(LucideIcons.save, size: 16, color: Colors.white),
                        label: const Text("E'lon qilish"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rasm (ixtiyoriy)', style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                image: _pickedImagePath != null
                    ? DecorationImage(image: FileImage(File(_pickedImagePath!)), fit: BoxFit.cover)
                    : null,
              ),
              child: _pickedImagePath == null
                  ? const Icon(LucideIcons.wrench, color: AppColors.textTertiary)
                  : null,
            ),
            const SizedBox(width: 12),
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(LucideIcons.imagePlus, size: 16),
              label: const Text('Rasm tanlash'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                backgroundColor: AppColors.primary.withOpacity(0.08),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
      ],
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
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
          icon: const Icon(LucideIcons.chevronDown, color: AppColors.textTertiary),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16),
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          ),
        ),
      ],
    );
  }
}
