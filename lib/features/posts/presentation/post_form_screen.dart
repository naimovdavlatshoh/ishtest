import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linkedin_clone/core/theme/app_colors.dart';
import 'package:linkedin_clone/core/theme/app_text_styles.dart';
import 'package:linkedin_clone/core/utils/extensions.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../companies/providers/company_provider.dart';
import '../providers/my_posts_provider.dart';
import '../providers/posts_provider.dart';

class PostFormScreen extends ConsumerStatefulWidget {
  const PostFormScreen({super.key});

  @override
  ConsumerState<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends ConsumerState<PostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  int? _selectedCompanyId = -1; // -1 == 'Kompaniyasiz'
  Uint8List? _pickedImageBytes;
  String _pickedImageName = 'photo.jpg';
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
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
      _pickedImageBytes = bytes;
      _pickedImageName = file.name.trim().isEmpty ? 'photo.jpg' : file.name.trim();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final data = {
      'title': _titleController.text.trim(),
      'content': _contentController.text.trim(),
      'company_id': _selectedCompanyId == -1 ? null : _selectedCompanyId,
      'status': 'published',
    };

    final int? newPostId = await ref.read(myPostsProvider.notifier).createPost(data);
    if (!mounted) return;

    if (newPostId == null) {
      setState(() => _isLoading = false);
      context.showSnackBar('Xatolik yuz berdi', isError: true);
      return;
    }

    final Uint8List? imageBytes = _pickedImageBytes;
    if (imageBytes != null) {
      final String? imageUrl = await ref.read(myPostsProvider.notifier).uploadPostImage(
            newPostId,
            imageBytes,
            _pickedImageName,
          );
      if (!mounted) return;
      if (imageUrl == null) {
        setState(() => _isLoading = false);
        context.showSnackBar('Post yaratildi, lekin rasm yuklanmadi', isError: true);
        context.go('/posts/my-posts');
        return;
      }
    }

    await ref.read(postsProvider.notifier).loadPosts(isRefresh: true);
    if (!mounted) return;
    setState(() => _isLoading = false);
    context.showSnackBar('Post muvaffaqiyatli yaratildi');
    context.go('/posts/my-posts');
  }

  @override
  Widget build(BuildContext context) {
    final companiesAsync = ref.watch(myCompaniesProvider);

    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Post yaratish', style: AppTextStyles.h2.copyWith(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                "Yangilik yoki yangilanish ulashing",
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
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
                    _buildTextField(
                      label: 'Sarlavha',
                      controller: _titleController,
                      validator: (val) => val == null || val.isEmpty ? "Majburiy maydon" : null,
                    ),
                    const SizedBox(height: 20),

                    _buildTextField(
                      label: 'Matn',
                      controller: _contentController,
                      maxLines: 8,
                      hint: 'Nima haqida yozmoqchisiz?',
                      validator: (val) => val == null || val.isEmpty ? "Majburiy maydon" : null,
                    ),
                    const SizedBox(height: 20),

                    companiesAsync.when(
                      data: (companies) => Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(LucideIcons.building2, size: 16, color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildDropdownField<int>(
                              label: 'Kompaniya (ixtiyoriy)',
                              value: _selectedCompanyId,
                              items: [
                                const DropdownMenuItem(value: -1, child: Text('Kompaniyasiz')),
                                ...companies.map((c) => DropdownMenuItem(
                                      value: c.id,
                                      child: Text(c.name),
                                    )),
                              ],
                              onChanged: (val) => setState(() => _selectedCompanyId = val),
                            ),
                          ),
                        ],
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 20),

                    Text('Rasm', style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _pickedImageBytes != null
                        ? Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(
                                  _pickedImageBytes!,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              TextButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(LucideIcons.imagePlus, size: 16),
                                label: const Text("Rasmni almashtirish"),
                              ),
                            ],
                          )
                        : OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(LucideIcons.imagePlus, size: 16),
                            label: const Text("Rasm qo'shish"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              side: BorderSide(color: Colors.grey[300]!, style: BorderStyle.solid),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),

                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => context.pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: BorderSide(color: Colors.grey[300]!),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          ),
                          child: const Text('Bekor qilish'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          ),
                        ),
                      ],
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
        Text(label, style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
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
