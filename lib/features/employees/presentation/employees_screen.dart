import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/employees_provider.dart';
import 'widgets/chat_invitation_dialog.dart';
import 'employee_profile_screen.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/utils/extensions.dart';

class EmployeesScreen extends ConsumerStatefulWidget {
  const EmployeesScreen({super.key});

  @override
  ConsumerState<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends ConsumerState<EmployeesScreen> {
  final TextEditingController _skillController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(employeesProvider.notifier).loadEmployees(skip: 0));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employeesProvider);
    final t = ref.watchTr;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.business_center, color: AppColors.primary, size: 36),
                  const SizedBox(width: 12),
                  Text(
                    t('employees'),
                    style: AppTextStyles.h2.copyWith(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                t('search_employees'),
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              
              // Filter Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.filter_list, size: 20, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          '${state.total} mutaxassis',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Row(
                      children: [
                        const Icon(Icons.code, size: 18, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          t('skills'),
                          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _skillController,
                            decoration: InputDecoration(
                              hintText: t('add_skill'),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            if (_skillController.text.isNotEmpty) {
                              ref.read(employeesProvider.notifier).addSkill(_skillController.text.trim());
                              _skillController.clear();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Qo\'shish', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                    if (state.selectedSkills.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: state.selectedSkills.map((skill) => Chip(
                          label: Text(skill),
                          onDeleted: () => ref.read(employeesProvider.notifier).removeSkill(skill),
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          labelStyle: const TextStyle(color: AppColors.primary, fontSize: 13),
                          deleteIconColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              if (state.isLoading)
                const Center(child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ))
              else if (state.employees.isEmpty)
                const Center(child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text('Mutaxassislar topilmadi'),
                ))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.employees.length,
                  itemBuilder: (context, index) {
                    final employee = state.employees[index];
                    return _EmployeeCard(employee: employee);
                  },
                ),
              
              // Pagination
              if (!state.isLoading && state.total > state.limit)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: state.skip > 0 
                          ? () => ref.read(employeesProvider.notifier).loadEmployees(skip: state.skip - state.limit)
                          : null,
                        icon: const Icon(Icons.arrow_back_ios, size: 18),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${(state.skip / state.limit).toInt() + 1} / ${(state.total / state.limit).ceil()}',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: state.skip + state.limit < state.total
                          ? () => ref.read(employeesProvider.notifier).loadEmployees(skip: state.skip + state.limit)
                          : null,
                        icon: const Icon(Icons.arrow_forward_ios, size: 18),
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
}

class _EmployeeCard extends StatelessWidget {
  final EmployeeModel employee;

  const _EmployeeCard({required this.employee});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: employee.avatar != null && employee.avatar!.isNotEmpty
                    ? NetworkImage(employee.avatar!.fullImageUrl)
                    : null,
                child: employee.avatar == null 
                  ? const Icon(Icons.person, color: AppColors.primary, size: 32)
                  : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.fullName,
                      style: AppTextStyles.h3.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9FFF2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Ishga ochiq',
                        style: TextStyle(color: Color(0xFF10B981), fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.email_outlined, size: 18, color: AppColors.textTertiary),
              const SizedBox(width: 10),
              Text(employee.email, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 18, color: AppColors.textTertiary),
              const SizedBox(width: 10),
              Text(employee.phone, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => ChatInvitationDialog(
                        userId: employee.id,
                        userName: employee.fullName,
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Xabar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF039855),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => EmployeeProfileScreen(
                        userId: employee.id,
                        userName: employee.fullName,
                      ),
                    ));
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                  child: const Text('Profil', style: TextStyle(color: AppColors.textPrimary)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
