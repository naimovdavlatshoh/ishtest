import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/config/env.dart';
import '../../../core/services/token_storage.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_me_provider.dart';
import '../providers/user_me_provider.dart';
import '../../../core/utils/extensions.dart';

final uzbCities = [
  'Toshkent shahri',
  'Toshkent viloyati',
  'Andijon',
  'Buxoro',
  'Farg\'ona',
  'Jizzax',
  'Xorazm',
  'Namangan',
  'Navoiy',
  'Qashqadaryo',
  'Qoraqalpog\'iston',
  'Samarqand',
  'Sirdaryo',
  'Surxondaryo',
];

final userMeFutureProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  const tokenStorage = TokenStorage();
  final token = await tokenStorage.getAccessToken();
  if (token == null || token.isEmpty) throw Exception('Token mavjud emas');

  final uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/users/me');
  final response = await http.get(
    uri,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode >= 200 && response.statusCode < 300) {
    return jsonDecode(response.body) as Map<String, dynamic>;
  } else {
    throw Exception('Error loading user data');
  }
});

class CreateProfileScreen extends ConsumerStatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  ConsumerState<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends ConsumerState<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  String? _selectedCity;
  
  bool _isLoading = false;
  bool _userDataLoaded = false;
  String? _localAvatarPath;
  bool _isUploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty && result.files.first.path != null) {
      final filePath = result.files.first.path!;
      setState(() {
        _isUploadingAvatar = true;
      });
      if (mounted) context.showSnackBar('uploading_image', isError: false);

      try {
        const tokenStorage = TokenStorage();
        final token = await tokenStorage.getAccessToken();
        if (token == null) throw Exception('No token');

        final uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/users/me/avatar');
        final request = http.MultipartRequest('POST', uri);
        request.headers['Authorization'] = 'Bearer $token';
        request.files.add(
          await http.MultipartFile.fromPath('file', filePath),
        );

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          setState(() {
            _localAvatarPath = filePath;
          });
          if (mounted) context.showSnackBar('image_uploaded_success');
        } else {
          throw Exception('Failed upload');
        }
      } catch (e) {
        if (mounted) context.showSnackBar('image_upload_error', isError: true);
      } finally {
        if (mounted) {
          setState(() {
            _isUploadingAvatar = false;
          });
        }
      }
    }
  }

  Future<void> _submit() async {

    if (!_formKey.currentState!.validate()) return;
    if (_selectedCity == null) {
      context.showSnackBar('select_city_required', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      const tokenStorage = TokenStorage();
      final token = await tokenStorage.getAccessToken();
      
      final uri = Uri.parse('${Environment.apiBaseUrl}/api/${Environment.apiVersion}/profiles');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'fullName': _nameController.text.trim(),
          'city': _selectedCity,
          'bio': _bioController.text.trim(),
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        ref.invalidate(profileMeProvider);
        ref.invalidate(userMeProvider);
        ref.read(authProvider.notifier).completeProfileCreation();
      } else {
        String msg = 'error_occurred';
        try {
          final errData = jsonDecode(response.body);
          msg = errData['message'] ?? errData['detail'] ?? msg;
        } catch (_) {}
        if (mounted) context.showSnackBar(msg, isError: true);
      }
    } catch (e) {
      if (mounted) context.showSnackBar('${'error'}: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userMeAsync = ref.watch(userMeFutureProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'ish',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'complete_profile_title',
                      style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'complete_profile_subtitle_long',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: userMeAsync.when(
                  loading: () => const Center(child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  )),
                  error: (err, stack) => Center(child: Text('${'error'}: $err')),
                  data: (userData) {
                    if (!_userDataLoaded) {
                      final firstName = userData['first_name'] ?? '';
                      final lastName = userData['last_name'] ?? '';
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _nameController.text = '$firstName $lastName'.trim();
                        setState(() { _userDataLoaded = true; });
                      });
                    }

                    return Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('profile_picture', style: AppTextStyles.h3),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.divider),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(40),
                                    child: _isUploadingAvatar
                                        ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                                        : _localAvatarPath != null
                                            ? Image.file(File(_localAvatarPath!), fit: BoxFit.cover)
                                            : const Icon(Icons.person_outline, size: 40, color: AppColors.textTertiary),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: _isUploadingAvatar ? null : _pickAndUploadAvatar,
                                      icon: const Icon(Icons.upload_file, size: 18, color: AppColors.textSecondary),
                                      label: Text('upload_picture', style: AppTextStyles.button.copyWith(color: AppColors.textSecondary)),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'upload_picture_desc',
                                      style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          Text('full_name', style: AppTextStyles.h3),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: 'full_name',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            validator: (v) => v == null || v.isEmpty ? 'enter_full_name' : null,
                          ),
                          const SizedBox(height: 24),
                          
                          Text('city', style: AppTextStyles.h3),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedCity,
                            decoration: InputDecoration(
                              hintText: 'select_city',
                              prefixIcon: const Icon(Icons.location_on_outlined),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            items: uzbCities.map((city) {
                              return DropdownMenuItem(
                                value: city.toLowerCase(),
                                child: Text(city),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedCity = val;
                              });
                            },
                            validator: (v) => v == null ? 'select_city_required' : null,
                          ),
                          const SizedBox(height: 24),
                          
                          Text('bio', style: AppTextStyles.h3),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _bioController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'bio_hint',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'bio_required';
                              if (v.length < 20) return 'bio_min_length';
                              return null;
                            },
                            onChanged: (val) {
                              setState(() {}); 
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '20 ${'min_characters'}',
                                style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                              ),
                              Text(
                                '${_bioController.text.length} ${'characters'}',
                                style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isLoading 
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('continue', style: AppTextStyles.button.copyWith(color: Colors.white, fontSize: 16)),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                                      ],
                                    ),
                            ),
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
      ),
    );
  }
}
