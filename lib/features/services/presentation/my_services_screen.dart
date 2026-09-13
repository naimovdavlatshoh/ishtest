import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linkedin_clone/core/theme/app_colors.dart';
import 'package:linkedin_clone/core/theme/app_text_styles.dart';
import 'package:linkedin_clone/core/utils/extensions.dart';
import 'package:linkedin_clone/shared/models/service_model.dart';
import '../providers/my_services_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MyServicesScreen extends ConsumerStatefulWidget {
  const MyServicesScreen({super.key});

  @override
  ConsumerState<MyServicesScreen> createState() => _MyServicesScreenState();
}

class _MyServicesScreenState extends ConsumerState<MyServicesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(myServicesProvider.notifier).loadMyServices());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myServicesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.errorMessage != null
                ? Center(child: Text(state.errorMessage!))
                : RefreshIndicator(
                    onRefresh: () => ref.read(myServicesProvider.notifier).loadMyServices(),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () => context.push('/services/add'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(LucideIcons.circlePlus, color: Colors.white, size: 22),
                                const SizedBox(width: 8),
                                Text('Xizmat qo\'shish', style: AppTextStyles.button.copyWith(color: Colors.white, fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        if (state.services.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Center(
                              child: Text("Hozircha xizmatlaringiz yo'q", style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary)),
                            ),
                          )
                        else
                          ...state.services.map((s) => _buildServiceCard(s)),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildServiceCard(ServiceModel service) {
    final bool isClosed = service.status == 'closed';
    final bool isDraft = service.status == 'draft';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    service.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.h3.copyWith(fontSize: 18, color: AppColors.textPrimary),
                  ),
                ),
                GestureDetector(
                  onTap: () => _showActions(service),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(LucideIcons.ellipsisVertical, color: AppColors.textTertiary, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildSmallIconText(LucideIcons.mapPin, service.location),
                _buildSmallIconText(LucideIcons.wrench, serviceCategoryLabels[service.category] ?? service.category),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (isDraft)
                  _buildBadge(icon: LucideIcons.squarePen, label: 'Qoralama', color: const Color(0xFF6B7280), bgColor: const Color(0xFFF3F4F6))
                else if (isClosed)
                  _buildBadge(icon: LucideIcons.circleX, label: 'Yopilgan', color: const Color(0xFFEF4444), bgColor: const Color(0xFFFEE2E2))
                else
                  _buildBadge(icon: LucideIcons.circleCheck, label: 'Faol', color: const Color(0xFF10B981), bgColor: const Color(0xFFECFDF5)),

                if (!isClosed)
                  _buildBadge(
                    icon: LucideIcons.ban,
                    label: 'Yopish',
                    color: Colors.white,
                    bgColor: const Color(0xFFF59E0B),
                    onTap: () => _updateStatus(service.id, 'closed'),
                  )
                else
                  _buildBadge(
                    icon: LucideIcons.circleCheck,
                    label: 'Faollashtirish',
                    color: Colors.white,
                    bgColor: const Color(0xFF10B981),
                    onTap: () => _updateStatus(service.id, 'active'),
                  ),

                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.eye, size: 18, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text('${service.viewsCount}', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showActions(ServiceModel service) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.trash2, color: Colors.red),
              title: const Text("O'chirish", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(service.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _updateStatus(int serviceId, String status) async {
    final success = await ref.read(myServicesProvider.notifier).updateServiceStatus(serviceId, status);
    if (context.mounted) {
      context.showSnackBar(success ? 'Holat yangilandi' : 'Xatolik yuz berdi', isError: !success);
    }
  }

  void _showDeleteConfirmation(int serviceId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("O'chirish"),
        content: const Text('Ushbu xizmatni o\'chirmoqchimisiz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bekor qilish')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(myServicesProvider.notifier).deleteService(serviceId);
              if (context.mounted) {
                context.showSnackBar(success ? "O'chirildi" : 'Xatolik yuz berdi', isError: !success);
              }
            },
            child: const Text("O'chirish", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({required IconData icon, required String label, required Color color, required Color bgColor, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(text, style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF6B7280))),
      ],
    );
  }
}
