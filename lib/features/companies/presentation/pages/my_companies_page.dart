import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    
    
    final companiesAsync = ref.watch(myCompaniesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.myCompaniesTitle),
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
              Text('${l10n.errorOccurred}: $err', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(myCompaniesProvider),
                child: Text(l10n.employeesRetry),
              ),
            ],
          ),
        ),
        data: (companies) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: PrimaryButton(
                text: l10n.myCompaniesAddBtn,
                icon: Icons.add,
                onPressed: () => context.push('/companies/add'),
              ),
            ),
            if (companies.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.business_outlined, size: 80, color: AppColors.textTertiary),
                      const SizedBox(height: 16),
                      Text(
                        l10n.myCompaniesEmpty,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
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
    final l10n = AppLocalizations.of(context)!;
    
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
              title: Text(l10n.jobActionEdit, style: const TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                context.pop();
                context.push('/companies/edit/${company.id}', extra: company);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              title: Text(l10n.jobActionDelete, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
              onTap: () async {
                context.pop();
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => ConfirmDialog(
                    title: l10n.myCompaniesDeleteTitle,
                    message: '${company.name} ${l10n.myCompaniesDeleteConfirm}',
                    confirmText: l10n.jobActionDelete,
                    cancelText: l10n.cancel,
                  ),
                );
                
                if (confirmed == true) {
                  final success = await ref.read(myCompaniesProvider.notifier).deleteCompany(company.id);
                  if (context.mounted) {
                    context.showSnackBar(
                      success ? 'Kompaniya o\'chirildi' : l10n.errorOccurred,
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

  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    
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
          Wrap(
            spacing: 16,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildSmallIconText(Icons.location_on_outlined, company.location),
              _buildSmallIconText(Icons.people_outline, l10n.myCompaniesEmployeesCount(company.size)),
              
              TextButton.icon(
                onPressed: () => context.go('/jobs/add', extra: {'companyId': company.id}),
                icon: const Icon(Icons.add_circle_outline, size: 18, color: AppColors.primary),
                label: Text(
                  l10n.myCompaniesAddJob,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
  Widget _buildSmallIconText(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
        ),
      ],
    );
  }
}
