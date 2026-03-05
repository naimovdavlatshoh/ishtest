import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linkedin_clone/core/theme/app_colors.dart';
import 'package:linkedin_clone/core/theme/app_text_styles.dart';
import 'package:linkedin_clone/core/widgets/buttons/primary_button.dart';
import 'package:linkedin_clone/core/widgets/dialogs/confirm_dialog.dart';
import 'package:linkedin_clone/features/companies/providers/company_provider.dart';
import 'package:linkedin_clone/shared/models/company_model.dart';
import 'package:linkedin_clone/core/utils/extensions.dart';

class MyCompaniesPage extends ConsumerWidget {
  const MyCompaniesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companiesAsync = ref.watch(myCompaniesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mening kompaniyalarim'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: companiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Xatolik yuz berdi: $err', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(myCompaniesProvider),
                child: const Text('Qayta urinish'),
              ),
            ],
          ),
        ),
        data: (companies) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: PrimaryButton(
                text: 'Kompaniya qo\'shish',
                icon: Icons.add,
                onPressed: () => context.push('/companies/add'),
              ),
            ),
            if (companies.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.business_outlined, size: 80, color: AppColors.textTertiary),
                      SizedBox(height: 16),
                      Text(
                        'Hali kompaniya qo\'shilmagan',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: companies.length,
                  itemBuilder: (context, index) {
                    final company = companies[index];
                    return _CompanyCard(company: company);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CompanyCard extends ConsumerWidget {
  final CompanyModel company;

  const _CompanyCard({required this.company});

  void _showActionSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: AppColors.primary),
              title: const Text('O\'zgartirish', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                context.pop();
                context.push('/companies/edit/${company.id}', extra: company);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              title: const Text('O\'chirish', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
              onTap: () async {
                context.pop();
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => ConfirmDialog(
                    title: 'Kompaniyani o\'chirish',
                    message: '${company.name} kompaniyasini o\'chirib tashlamoqchimisiz?',
                    confirmText: 'O\'chirish',
                    cancelText: 'Bekor qilish',
                  ),
                );
                
                if (confirmed == true) {
                  final success = await ref.read(myCompaniesProvider.notifier).deleteCompany(company.id);
                  if (context.mounted) {
                    context.showSnackBar(
                      success ? 'Kompaniya o\'chirildi' : 'Xatolik yuz berdi',
                      isError: !success,
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.business, color: AppColors.primary, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.name,
                      style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
                    ),
                    Text(
                      company.industry,
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (company.isVerified)
                const Icon(Icons.verified, color: AppColors.primary, size: 20),
              IconButton(
                icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                onPressed: () => _showActionSheet(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            company.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textTertiary),
                  const SizedBox(width: 4),
                  Text(
                    company.location,
                    style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.people_outline, size: 14, color: AppColors.textTertiary),
                  const SizedBox(width: 4),
                  Text(
                    '${company.size} xodim',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () => context.go('/jobs/add', extra: {'companyId': company.id}),
                icon: const Icon(Icons.add_circle_outline, size: 18, color: AppColors.primary),
                label: const Text(
                  'Ish qo\'shish',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  backgroundColor: AppColors.primary.withOpacity(0.08),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
