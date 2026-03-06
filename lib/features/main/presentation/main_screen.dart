import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/providers/profile_me_provider.dart';
import '../../../core/utils/extensions.dart';
import '../../chat/providers/global_chat_provider.dart';

class MainScreen extends ConsumerWidget {
  final Widget child;
  final int selectedIndex;

  const MainScreen({
    super.key,
    required this.child,
    this.selectedIndex = 0,
  });


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider).user;
    final profileAsync = ref.watch(profileMeProvider);
    final profile = profileAsync.asData?.value;
    // Initialize and watch global chat for unread badge
    final totalUnread = ref.watch(totalUnreadProvider);
    final displayName =
        profile?.fullName ?? currentUser?.name ?? 'Foydalanuvchi';
    final displayTitle = profile?.title ?? currentUser?.headline ?? 'Mutaxassis';

    final userInitial = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : 'I';

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              // Profile card
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  context.go('/profile/me');
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        backgroundImage: profile?.avatar != null && profile!.avatar!.isNotEmpty
                            ? NetworkImage(profile.avatar!.fullImageUrl)
                            : null,
                        child: profile?.avatar == null || profile!.avatar!.isEmpty
                            ? Text(
                                userInitial,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              displayTitle,
                              style: AppTextStyles.caption.copyWith(fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ASOSIY section
              Text(
                'Yangiliklar'.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              _buildDrawerItem(
                context,
                Icons.space_dashboard_rounded,
                'Boshqaruv paneli',
                '/feed',
                0,
              ),
              _buildDrawerItem(
                context,
                Icons.account_circle_outlined,
                'Mening profilim',
                '/profile/me',
                1,
              ),
              _buildDrawerItemWithBadge(
                context,
                Icons.chat_bubble_outline_rounded,
                'Xabarlar',
                '/chat',
                3,
                totalUnread,
              ),
              _buildDrawerItem(
                context,
                Icons.mark_email_read_outlined,
                'Taklifnomalar',
                '/invitations',
                9,
              ),
              _buildDrawerItem(
                context,
                Icons.badge_outlined,
                'Xodimlar',
                '/employees',
                2,
              ),

              const SizedBox(height: 16),

              // ISHLAR section
              Text(
                'Vakansiyalar'.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              _buildDrawerItem(
                context,
                Icons.work_outline_rounded,
                'Vakansiyalar',
                '/jobs',
                4,
              ),
              _buildDrawerItem(
                context,
                Icons.bookmark_border,
                'Saqlanganlar',
                '/jobs/saved',
                6,
              ),
              _buildDrawerItem(
                context,
                Icons.add_box_outlined,
                'Vakansiya qo\'shish',
                '/jobs/add',
                8,
              ),
              _buildDrawerItem(
                context,
                Icons.article_outlined,
                'Mening vakansiyalarim',
                '/jobs/my-jobs',
                7,
              ),

              const SizedBox(height: 16),

              // ARIZALAR section
              Text(
                'Mening arizalarim'.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              _buildDrawerItem(
                context,
                Icons.send_outlined,
                'Mening arizalarim',
                '/my-applications',
                10,
              ),

              const SizedBox(height: 16),

              // KOMPANIYALAR section
              Text(
                'Kompaniyalar'.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              _buildDrawerItem(
                context,
                Icons.apartment_outlined,
                'Mening kompaniyalarim',
                '/companies',
                5,
              ),

              const SizedBox(height: 16),

              // SOZLAMALAR section
              Text(
                'Sozlamalar'.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                dense: true,
                horizontalTitleGap: 8,
                leading: const Icon(
                  Icons.settings_outlined,
                  color: AppColors.iconPrimary,
                  size: 20,
                ),
                title: Text(
                  'Profil sozlamalari',
                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/profile/edit', extra: 'Asosiy');
                },
              ),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                dense: true,
                horizontalTitleGap: 8,
                leading: const Icon(
                  Icons.remove_red_eye_outlined,
                  color: AppColors.iconPrimary,
                  size: 20,
                ),
                title: Text(
                  'Ko\'rinish',
                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/profile/edit', extra: "Ko'rinish");
                },
              ),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                dense: true,
                horizontalTitleGap: 8,
                leading: const Icon(
                  Icons.description_outlined,
                  color: AppColors.iconPrimary,
                  size: 20,
                ),
                title: Text(
                  'Mening rezyumem',
                  style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/profile/edit', extra: 'Rezyume');
                },
              ),

              const SizedBox(height: 16),
              const Divider(),

              // Logout
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                dense: true,
                horizontalTitleGap: 8,
                leading: const Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                ),
                title: Text(
                  'Chiqish',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.black),
        titleSpacing: 16,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/ishlogo.png',
                height: 28,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ish',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          // Globe — language picker
          // Chat badge button
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 22, color: AppColors.iconPrimary),
                onPressed: () => context.go('/chat'),
              ),
              if (totalUnread > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        totalUnread > 9 ? '9+' : '$totalUnread',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          Builder(
            builder: (context) => IconButton(
              icon: const Icon(
                Icons.menu,
                size: 22,
                color: AppColors.iconPrimary,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: child,
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    String route,
    int index,
  ) {
    return _buildDrawerItemWithBadge(context, icon, title, route, index, 0);
  }

  Widget _buildDrawerItemWithBadge(
    BuildContext context,
    IconData icon,
    String title,
    String route,
    int index,
    int badgeCount,
  ) {
    final isActive = selectedIndex == index;
    return Container(
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        dense: true,
        horizontalTitleGap: 8,
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : AppColors.iconPrimary,
              size: 20,
            ),
            if (badgeCount > 0)
              Positioned(
                top: -6,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : const Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      badgeCount > 99 ? '99+' : '$badgeCount',
                      style: TextStyle(
                        color: isActive ? AppColors.primary : Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive ? Colors.white : AppColors.textPrimary,
                  fontSize: 13,
                ),
              ),
            ),
            if (badgeCount > 0 && !isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeCount > 99 ? '99+' : '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: () {
          Navigator.of(context).pop();
          context.go(route);
        },
      ),
    );
  }
}
