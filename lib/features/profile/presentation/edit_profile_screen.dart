import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../providers/profile_me_provider.dart';
import '../providers/user_me_provider.dart';
import '../../../shared/models/profile_me_model.dart';
import '../../../core/utils/extensions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final String? initialSection;
  const EditProfileScreen({super.key, this.initialSection});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // ScrollController for auto-scroll
  final _scrollController = ScrollController();
  
  // Section GlobalKeys for scroll targeting
  final _keyAsosiy     = GlobalKey();
  final _keyKorinish   = GlobalKey();
  final _keyRezyume    = GlobalKey();
  
  // Controllers for Asosiy section
  late TextEditingController _nameController;
  late TextEditingController _cityController;
  late TextEditingController _titleController;
  late TextEditingController _bioController;
  
  // Skill controller
  final _skillController = TextEditingController();
  List<String> _skills = [];
  
  // Visibility state
  bool _isPublic = false;
  
  // Account state
  final _telegramCodeController = TextEditingController();
  
  // Accordion state
  String? _activeSection;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileMeProvider).asData?.value;
    
    _nameController = TextEditingController(text: profile?.fullName ?? '');
    _cityController = TextEditingController(text: profile?.city ?? '');
    _titleController = TextEditingController(text: profile?.title ?? '');
    _bioController = TextEditingController(text: profile?.bio ?? '');
    _skills = List.from(profile?.skills ?? []);
    _experiences = List.from(profile?.experience ?? []);
    _educations = List.from(profile?.education ?? []);
    _isPublic = profile?.openToJobSeeker ?? false;
    // Open a specific accordion if provided
    if (widget.initialSection != null) {
      _activeSection = widget.initialSection;
      // Delay scroll to ensure async data has rendered
      Future.delayed(const Duration(milliseconds: 450), () {
        if (mounted) _scrollToSection(widget.initialSection!);
      });
    }
  }

  void _scrollToSection(String section) {
    GlobalKey? key;
    switch (section) {
      case 'Asosiy':
        key = _keyAsosiy;
        break;
      case "Ko'rinish":
        key = _keyKorinish;
        break;
      case 'Rezyume':
        key = _keyRezyume;
        break;
      default:
        return;
    }
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
        alignment: 0.0,
      );
    }
  }

  Future<String?> _selectDate(BuildContext context, String? initialValue) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialValue != null && initialValue.isNotEmpty 
          ? DateFormat('yyyy-MM').parse(initialValue) 
          : DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      return DateFormat('yyyy-MM').format(picked);
    }
    return initialValue;
  }

  late List<Experience> _experiences;
  late List<Education> _educations;

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _titleController.dispose();
    _bioController.dispose();
    _skillController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileMeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Profil sozlamalari',
          style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Xatolik: $err')),
        data: (profile) => SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Profil ma'lumotlari va ko'rinishini boshqarish",
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              _buildUserPreview(profile),
              const SizedBox(height: 20),
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: Column(
                  children: [
                    _buildAsosiySection(),
                    const SizedBox(height: 12),
                    _buildSkillsSection(),
                    const SizedBox(height: 12),
                    _buildTajribaSection(profile),
                    const SizedBox(height: 12),
                    _buildTalimSection(profile),
                    const SizedBox(height: 12),
                    SizedBox(key: _keyRezyume, child: _buildRezyumeSection(profile)),
                    const SizedBox(height: 12),
                    SizedBox(key: _keyKorinish, child: _buildKorinishSection()),
                    const SizedBox(height: 12),
                    _buildAkkauntSection(),
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

  Widget _buildUserPreview(ProfileMe profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(40),
            ),
            child: profile.avatar != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.network(profile.avatar!.fullImageUrl, fit: BoxFit.cover),
                  )
                : const Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(profile.fullName, style: AppTextStyles.h3),
          Text(profile.city ?? 'Joylashuv kiritilmagan', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          Text(profile.title, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline, size: 14, color: Colors.green),
                const SizedBox(width: 4),
                Text(
                  'To\'liq',
                  style: AppTextStyles.caption.copyWith(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAsosiySection() {
    return _buildExpansionCard(
      title: 'Asosiy',
      icon: Icons.person_outline,
      children: [
        _buildTextField(label: 'To\'liq ism *', controller: _nameController),
        const SizedBox(height: 16),
        _buildTextField(label: 'Shahar *', controller: _cityController),
        const SizedBox(height: 16),
        _buildTextField(label: 'Lavozim', controller: _titleController),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'O\'zingiz haqida',
          controller: _bioController,
          maxLines: 4,
          hint: 'Python/Js Software Engineer',
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '${_bioController.text.length} belgi',
            style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
          ),
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          text: 'Saqlash',
          onPressed: () async {
            final success = await ref.read(profileMeProvider.notifier).updateProfile({
              'fullName': _nameController.text,
              'city': _cityController.text,
              'title': _titleController.text,
              'bio': _bioController.text,
            });
            if (context.mounted) {
              context.showSnackBar(
                success ? 'Ma\'lumotlar saqlandi' : 'Xatolik yuz berdi',
                isError: !success,
              );
            }
          },
          prefixIcon: const Icon(Icons.save_outlined, size: 18, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildSkillsSection() {
    return _buildExpansionCard(
      title: 'Ko\'nikmalar',
      icon: Icons.work_outline,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _buildTextField(
                label: 'Ko\'nikma qo\'shish',
                controller: _skillController,
                hint: 'React',
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  if (_skillController.text.isNotEmpty) {
                    setState(() {
                      _skills.add(_skillController.text);
                      _skillController.clear();
                    });
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Ko\'nikmalaringiz (${_skills.length})',
            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _skills.map((skill) => _buildSkillChip(skill)).toList(),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          text: 'Ko\'nikmalarni saqlash',
          onPressed: () async {
            final success = await ref.read(profileMeProvider.notifier).updateProfile({
              'skills': _skills,
            });
            if (context.mounted) {
              context.showSnackBar(
                success ? 'Ko\'nikmalar saqlandi' : 'Xatolik yuz berdi',
                isError: !success,
              );
            }
          },
          prefixIcon: const Icon(Icons.save_outlined, size: 18, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(skill, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _skills.remove(skill);
              });
            },
            child: const Icon(Icons.close, size: 16, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildTajribaSection(ProfileMe profile) {
    return _buildExpansionCard(
      title: 'Tajriba',
      icon: Icons.business_center_outlined,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Ish tajribasi', style: AppTextStyles.h4),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          text: 'Tajriba qo\'shish',
          onPressed: () {
            setState(() {
              _experiences.add(Experience(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: '',
                company: '',
                startDate: '',
              ));
            });
          },
          prefixIcon: const Icon(Icons.add, size: 18, color: Colors.white),
        ),
        const SizedBox(height: 24),
        ..._experiences.asMap().entries.map((entry) {
          final index = entry.key;
          final exp = entry.value;
          return _buildExperienceEditItem(exp, index);
        }),
        const SizedBox(height: 12),
        PrimaryButton(
          text: 'Tajribani saqlash',
          onPressed: () async {
            final success = await ref.read(profileMeProvider.notifier).updateProfile({
              'experience': _experiences.map((e) => e.toJson()).toList(),
            });
            if (context.mounted) {
              context.showSnackBar(
                success ? 'Tajriba saqlandi' : 'Xatolik yuz berdi',
                isError: !success,
              );
            }
          },
          prefixIcon: const Icon(Icons.save_outlined, size: 18, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildExperienceEditItem(Experience exp, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            label: 'Lavozim *',
            initialValue: exp.title,
            onChanged: (v) {
              setState(() {
                _experiences[index] = Experience(
                  id: exp.id,
                  title: v,
                  company: exp.company,
                  startDate: exp.startDate,
                  endDate: exp.endDate,
                  location: exp.location,
                  description: exp.description,
                );
              });
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Kompaniya *',
            initialValue: exp.company,
            onChanged: (v) {
              setState(() {
                _experiences[index] = Experience(
                  id: exp.id,
                  title: exp.title,
                  company: v,
                  startDate: exp.startDate,
                  endDate: exp.endDate,
                  location: exp.location,
                  description: exp.description,
                );
              });
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Manzil',
            initialValue: exp.location ?? '',
            onChanged: (v) {
              setState(() {
                _experiences[index] = Experience(
                  id: exp.id,
                  title: exp.title,
                  company: exp.company,
                  startDate: exp.startDate,
                  endDate: exp.endDate,
                  location: v,
                  description: exp.description,
                  current: exp.current,
                );
              });
            },
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () async {
              final date = await _selectDate(context, exp.startDate);
              if (date != null) {
                setState(() {
                  _experiences[index] = Experience(
                    id: exp.id,
                    title: exp.title,
                    company: exp.company,
                    startDate: date,
                    endDate: exp.endDate,
                    location: exp.location,
                    description: exp.description,
                    current: exp.current,
                  );
                });
              }
            },
            child: AbsorbPointer(
              child: _buildTextField(
                label: 'Boshlanish *',
                initialValue: exp.startDate,
                suffixIcon: const Icon(Icons.calendar_today, size: 18),
              ),
            ),
          ),
          if (!exp.current) ...[
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final date = await _selectDate(context, exp.endDate);
                if (date != null) {
                  setState(() {
                    _experiences[index] = Experience(
                      id: exp.id,
                      title: exp.title,
                      company: exp.company,
                      startDate: exp.startDate,
                      endDate: date,
                      location: exp.location,
                      description: exp.description,
                      current: exp.current,
                    );
                  });
                }
              },
              child: AbsorbPointer(
                child: _buildTextField(
                  label: 'Tugash',
                  initialValue: exp.endDate ?? '',
                  suffixIcon: const Icon(Icons.calendar_today, size: 18),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: exp.current,
                onChanged: (v) {
                  setState(() {
                    _experiences[index] = Experience(
                      id: exp.id,
                      title: exp.title,
                      company: exp.company,
                      startDate: exp.startDate,
                      endDate: v == true ? null : exp.endDate,
                      location: exp.location,
                      description: exp.description,
                      current: v ?? false,
                    );
                  });
                },
              ),
              const Text('Hozir shu yerda ishlayman'),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Tavsif',
            initialValue: exp.description ?? '',
            maxLines: 3,
            onChanged: (v) {
              setState(() {
                _experiences[index] = Experience(
                  id: exp.id,
                  title: exp.title,
                  company: exp.company,
                  startDate: exp.startDate,
                  endDate: exp.endDate,
                  location: exp.location,
                  description: v,
                  current: exp.current,
                );
              });
            },
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _experiences.removeAt(index);
                });
              },
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
              label: const Text('O\'chirish', style: TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTalimSection(ProfileMe profile) {
    return _buildExpansionCard(
      title: 'Ta\'lim',
      icon: Icons.school_outlined,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Ta\'lim', style: AppTextStyles.h4),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          text: 'Ta\'lim qo\'shish',
          onPressed: () {
            setState(() {
              _educations.add(Education(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                school: '',
                degree: '',
                field: '',
                startDate: '',
                current: false,
              ));
            });
          },
          prefixIcon: const Icon(Icons.add, size: 18, color: Colors.white),
        ),
        const SizedBox(height: 24),
        ..._educations.asMap().entries.map((entry) {
          final index = entry.key;
          final edu = entry.value;
          return _buildEducationEditItem(edu, index);
        }),
        const SizedBox(height: 12),
        PrimaryButton(
          text: 'Ta\'limni saqlash',
          onPressed: () async {
            final success = await ref.read(profileMeProvider.notifier).updateProfile({
              'education': _educations.map((e) => e.toJson()).toList(),
            });
            if (context.mounted) {
              context.showSnackBar(
                success ? 'Ta\'lim saqlandi' : 'Xatolik yuz berdi',
                isError: !success,
              );
            }
          },
          prefixIcon: const Icon(Icons.save_outlined, size: 18, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildEducationEditItem(Education edu, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            label: 'Maktab/O\'liy o\'quv yurti *',
            initialValue: edu.school,
            onChanged: (v) {
              setState(() {
                _educations[index] = Education(
                  id: edu.id,
                  school: v,
                  degree: edu.degree,
                  field: edu.field,
                  startDate: edu.startDate,
                  endDate: edu.endDate,
                  current: edu.current,
                );
              });
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Daraja *',
            initialValue: edu.degree,
            onChanged: (v) {
              setState(() {
                _educations[index] = Education(
                  id: edu.id,
                  school: edu.school,
                  degree: v,
                  field: edu.field,
                  startDate: edu.startDate,
                  endDate: edu.endDate,
                  current: edu.current,
                );
              });
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Mutaxassislik',
            initialValue: edu.field,
            onChanged: (v) {
              setState(() {
                _educations[index] = Education(
                  id: edu.id,
                  school: edu.school,
                  degree: edu.degree,
                  field: v,
                  startDate: edu.startDate,
                  endDate: edu.endDate,
                  current: edu.current,
                );
              });
            },
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () async {
              final date = await _selectDate(context, edu.startDate);
              if (date != null) {
                setState(() {
                  _educations[index] = Education(
                    id: edu.id,
                    school: edu.school,
                    degree: edu.degree,
                    field: edu.field,
                    startDate: date,
                    endDate: edu.endDate,
                    current: edu.current,
                  );
                });
              }
            },
            child: AbsorbPointer(
              child: _buildTextField(
                label: 'Boshlanish *',
                initialValue: edu.startDate,
                suffixIcon: const Icon(Icons.calendar_today, size: 18),
              ),
            ),
          ),
          if (!edu.current) ...[
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final date = await _selectDate(context, edu.endDate);
                if (date != null) {
                  setState(() {
                    _educations[index] = Education(
                      id: edu.id,
                      school: edu.school,
                      degree: edu.degree,
                      field: edu.field,
                      startDate: edu.startDate,
                      endDate: date,
                      current: edu.current,
                    );
                  });
                }
              },
              child: AbsorbPointer(
                child: _buildTextField(
                  label: 'Tugash',
                  initialValue: edu.endDate ?? '',
                  suffixIcon: const Icon(Icons.calendar_today, size: 18),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: edu.current,
                onChanged: (v) {
                  setState(() {
                    _educations[index] = Education(
                      id: edu.id,
                      school: edu.school,
                      degree: edu.degree,
                      field: edu.field,
                      startDate: edu.startDate,
                      endDate: v == true ? null : edu.endDate,
                      current: v ?? false,
                    );
                  });
                },
              ),
              const Text('Hozir shu yerda o\'qiyman'),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _educations.removeAt(index);
                });
              },
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
              label: const Text('O\'chirish', style: TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKorinishSection() {
    return _buildExpansionCard(
      title: 'Ko\'rinish',
      icon: Icons.visibility_outlined,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Profil ko\'rinishi', style: AppTextStyles.h4),
        ),
        const SizedBox(height: 16),
        _buildVisibilityToggle(
          title: 'Ishga ochiq (Xodim)',
          description: 'Profilingizni Xodimlar sahifasida ko\'rsating — ish beruvchilar sizni topishi uchun.',
          value: _isPublic,
          onChanged: (v) async {
            setState(() => _isPublic = v);
            final success = await ref.read(profileMeProvider.notifier).updateProfile({
              'openToJobSeeker': v,
              'openToEmployer': v, // Sync both for now or as needed
            });
            if (context.mounted) {
              context.showSnackBar(
                success ? 'Ko\'rinish yangilandi' : 'Xatolik yuz berdi',
                isError: !success,
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildVisibilityToggle({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => onChanged(!value),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: value ? AppColors.primary : AppColors.divider,
                      width: 2,
                    ),
                    color: value ? AppColors.primary : Colors.transparent,
                  ),
                  child: value
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Ushbu sahifada ko\'rsatish',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAkkauntSection() {
    final userMeAsync = ref.watch(userMeProvider);

    return _buildExpansionCard(
      title: 'Akkaunt',
      icon: Icons.link,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Telegram', style: AppTextStyles.h4),
        ),
        const SizedBox(height: 16),
        userMeAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Text('Xatolik: $e'),
          data: (user) {
            final isLinked = user.telegramId != null;

            if (isLinked) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Telegramga ulangan',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'ID: ${user.telegramId}',
                            style: AppTextStyles.caption.copyWith(color: Colors.green.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Telegramni ulang — bot orqali kod bilan kiring (parolsiz).',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final url = Uri.parse('https://t.me/ishjobs_bot?start=link');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                        children: [
                          const TextSpan(text: '1. '),
                          TextSpan(
                            text: 'Telegram botini oching',
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                          ),
                          const TextSpan(text: ' va «Link kodi»ni bosing.'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('2. Kodni quyida kiriting.', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: '',
                    controller: _telegramCodeController,
                    hint: '123456',
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    text: 'Ulash',
                    onPressed: () async {
                      final code = _telegramCodeController.text.trim();
                      if (code.isEmpty) {
                        context.showSnackBar('Kodni kiriting', isError: true);
                        return;
                      }

                      final success = await ref.read(profileMeProvider.notifier).linkTelegram(code);
                      if (context.mounted) {
                        context.showSnackBar(
                          success ? 'Telegram muvaffaqiyatli ulandi' : 'Xatolik: kod noto\'g\'ri bo\'lishi mumkin',
                          isError: !success,
                        );
                        if (success) {
                          _telegramCodeController.clear();
                          // Refresh user data to show "Connected" status
                          ref.refresh(userMeProvider);
                        }
                      }
                    },
                    backgroundColor: AppColors.primary.withOpacity(0.5),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRezyumeSection(ProfileMe profile) {
    return _buildExpansionCard(
      title: 'Rezyume',
      icon: Icons.description_outlined,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('Rezyumeni yuklash', style: AppTextStyles.h4),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider, style: BorderStyle.solid),
          ),
          child: Column(
            children: [
              const Icon(Icons.cloud_upload_outlined, size: 48, color: AppColors.textTertiary),
              const SizedBox(height: 12),
              const Text('Rezyumeni yuklang (PDF, DOC, DOCX)', style: AppTextStyles.bodyMedium),
              const Text('Maks. hajmi: 5MB', style: AppTextStyles.caption),
              const SizedBox(height: 16),
              SizedBox(
                width: 200,
                child: PrimaryButton(
                  text: 'Fayl tanlash',
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf', 'doc', 'docx'],
                    );

                    if (result != null && result.files.single.path != null) {
                      final success = await ref
                          .read(profileMeProvider.notifier)
                          .uploadFile(result.files.single.path!);
                      
                      if (context.mounted) {
                        context.showSnackBar(
                          success ? 'Fayl muvaffaqiyatli yuklandi' : 'Yuklashda xatolik',
                          isError: !success,
                        );
                      }
                    }
                  },
                  prefixIcon: const Icon(Icons.file_upload_outlined, size: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (profile.cvFile != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.description_outlined, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Rezyume yuklandi', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      Text(profile.cvFile!.split('/').last, style: AppTextStyles.caption.copyWith(color: Colors.green)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () async {
                    final success = await ref.read(profileMeProvider.notifier).updateProfile({
                      'cvFile': null,
                    });
                    if (context.mounted) {
                      context.showSnackBar(
                        success ? 'Fayl o\'chirildi' : 'Xatolik yuz berdi',
                        isError: !success,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildExpansionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final bool isExpanded = _activeSection == title;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          dividerColor: Colors.transparent,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: ExpansionTile(
            key: Key('${title}_$isExpanded'),
            initiallyExpanded: isExpanded,
            expansionAnimationStyle: AnimationStyle(
              curve: Curves.easeInOutQuart,
              duration: const Duration(milliseconds: 400),
            ),
            onExpansionChanged: (expanded) {
              if (expanded) {
                setState(() {
                  _activeSection = title;
                });
              } else {
                if (_activeSection == title) {
                  setState(() {
                    _activeSection = null;
                  });
                }
              }
            },
            backgroundColor: Colors.white,
            collapsedBackgroundColor: Colors.white,
            leading: Icon(icon, color: AppColors.primary),
            title: Text(title, style: AppTextStyles.h4),
            childrenPadding: const EdgeInsets.all(20),
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    TextEditingController? controller,
    String? initialValue,
    String? hint,
    int maxLines = 1,
    Widget? suffixIcon,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: initialValue != null ? Key('$label-$initialValue') : null,
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
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
