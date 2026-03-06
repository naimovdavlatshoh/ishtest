import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/dashboard_stats_provider.dart';
import '../../../shared/models/dashboard_stats_model.dart';
import '../../../shared/models/user_model.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserModel? currentUser = ref.watch(authProvider).user;
    final String name = currentUser?.name ?? 'Foydalanuvchi';
    final AsyncValue<DashboardStats> statsAsync = ref.watch(dashboardStatsProvider);
    final DashboardStats stats = statsAsync.maybeWhen(
      data: (DashboardStats value) => value,
      orElse: () => DashboardStats.empty,
    );

    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${'Xush kelibsiz'}, $name! 👋',
              style: AppTextStyles.h2.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 8),
            Text(
              'Profilingiz statistikasi va yangiliklarni kuzatib boring',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            _ProfileProgressCard(),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Profilni ko\'rishlar',
                    value: stats.profileViews.toString(),
                    icon: Icons.remove_red_eye_outlined,
                    color: const Color(0xFFEAF3FF),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Arizalar',
                    value: stats.jobsApplied.toString(),
                    icon: Icons.assignment_outlined,
                    color: const Color(0xFFE9FFF2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Aloqalar',
                    value: stats.connections.toString(),
                    icon: Icons.people_outline,
                    color: const Color(0xFFF5EEFF),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Bildirishnomalar',
                    value: stats.notifications.toString(),
                    icon: Icons.notifications_outlined,
                    color: const Color(0xFFFFF3E5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Text('Oxirgi faoliyat', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            _ActivityCard(
              title: 'Profilni ko\'rishlar',
              timeLabel: '2 ${'soat oldin'}',
              icon: Icons.remove_red_eye_outlined,
            ),
            const SizedBox(height: 8),
            _ActivityCard(
              title: 'Senior Developer ${'arizangiz ko\'rib chiqildi'}',
              timeLabel: '1 ${'kun oldin'}',
              icon: Icons.work_outline,
            ),
            const SizedBox(height: 8),
            _ActivityCard(
              title: 'Profil darajasi oshdi',
              timeLabel: '3 ${'kun oldin'}',
              icon: Icons.trending_up,
            ),
            const SizedBox(height: 24),

            Text('Tezkor amallar', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            _QuickActionTile(icon: Icons.work_outline, title: 'Vakansiyalarni ko\'rish'),
            const SizedBox(height: 8),
            _QuickActionTile(icon: Icons.people_outline, title: 'Mutaxassis qidirish'),
            const SizedBox(height: 8),
            _QuickActionTile(icon: Icons.check_circle_outline, title: 'Profilni yangilash'),
            const SizedBox(height: 24),

            _OpenToWorkCard(),
          ],
        ),
      ),
    );
  }
}

class _ProfileProgressCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF5B7BFE), Color(0xFF7B5BFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profilingizni yakunlang', style: AppTextStyles.h3.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          Text(
            'To\'liq profil ish beruvchilar e\'tiborini 2 barobar ko\'proq tortadi.',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withOpacity(0.9)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Jarayon', style: AppTextStyles.bodySmall.copyWith(color: Colors.white)),
              Text('55%', style: AppTextStyles.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: 0.55,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                textStyle: AppTextStyles.buttonSmall.copyWith(color: AppColors.primary),
              ),
              onPressed: () {},
              child: Text('Hozir yakunlash'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 22, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.caption),
                const SizedBox(height: 4),
                Text(value, style: AppTextStyles.h3.copyWith(fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String title;
  final String timeLabel;
  final IconData icon;

  const _ActivityCard({required this.title, required this.timeLabel, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyMedium),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(timeLabel, style: AppTextStyles.caption),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;

  const _QuickActionTile({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: AppTextStyles.bodyMedium)),
          const Icon(Icons.chevron_right, color: AppColors.iconSecondary),
        ],
      ),
    );
  }
}

class _OpenToWorkCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ishga tayyorlik',
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      "Mutaxassislar sahifasida ko'rsatish",
                      style: AppTextStyles.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Faol emas',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text("Ko'rinishni boshqarish", style: AppTextStyles.link),
        ],
      ),
    );
  }
}
