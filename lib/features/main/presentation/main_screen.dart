import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/providers/locale_provider.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final displayName =
        profile?.fullName ?? currentUser?.name ?? l10n.defaultUser;
    final displayTitle = profile?.title ?? currentUser?.headline ?? l10n.defaultExpert;

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
                l10n.drawerNews,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              _buildDrawerItem(
                context,
                Icons.space_dashboard_rounded,
                l10n.drawerDashboard,
                '/feed',
                0,
              ),
              _buildDrawerItem(
                context,
                Icons.account_circle_outlined,
                l10n.drawerMyProfile,
                '/profile/me',
                1,
              ),
              _buildDrawerItemWithBadge(
                context,
                Icons.chat_bubble_outline_rounded,
                l10n.mainNavMessages,
                '/chat',
                3,
                totalUnread,
              ),
              _buildDrawerItem(
                context,
                Icons.mark_email_read_outlined,
                l10n.drawerInvitations,
                '/invitations',
                9,
              ),
              _buildDrawerItem(
                context,
                Icons.badge_outlined,
                l10n.drawerEmployees,
                '/employees',
                2,
              ),

              const SizedBox(height: 16),

              // ISHLAR section
              Text(
                l10n.drawerVacanciesGroup,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              _buildDrawerItem(
                context,
                Icons.work_outline_rounded,
                l10n.mainNavVacancies,
                '/jobs',
                4,
              ),
              _buildDrawerItem(
                context,
                Icons.bookmark_border,
                l10n.drawerSaved,
                '/jobs/saved',
                6,
              ),
              _buildDrawerItem(
                context,
                Icons.add_box_outlined,
                l10n.drawerAddVacancy,
                '/jobs/add',
                8,
              ),
              _buildDrawerItem(
                context,
                Icons.article_outlined,
                l10n.drawerMyVacancies,
                '/jobs/my-jobs',
                7,
              ),

              const SizedBox(height: 16),

              // ARIZALAR section
              Text(
                l10n.drawerMyApplicationsGroup,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              _buildDrawerItem(
                context,
                Icons.send_outlined,
                l10n.drawerMyApplications,
                '/my-applications',
                10,
              ),

              const SizedBox(height: 16),

              // KOMPANIYALAR section
              Text(
                l10n.drawerCompaniesGroup,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              _buildDrawerItem(
                context,
                Icons.apartment_outlined,
                l10n.drawerMyCompanies,
                '/companies',
                5,
              ),

              const SizedBox(height: 16),

              // SOZLAMALAR section
              Text(
                l10n.drawerSettingsGroup,
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
                  l10n.drawerProfileSettings,
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
                  l10n.drawerAppearance,
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
                  l10n.drawerMyResume,
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
                  l10n.drawerLogout,
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
          IconButton(
            icon: const Icon(Icons.language, color: AppColors.iconPrimary, size: 22),
            onPressed: () => _showLanguageModal(context, ref),
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
      bottomNavigationBar: _buildBottomNavBar(context, totalUnread, l10n),
    );
  }

  Widget _buildBottomNavBar(BuildContext context, int totalUnread, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
           _buildNavItem(context, Icons.space_dashboard_rounded, l10n.mainNavHome, 0, '/feed', 0),
           _buildNavItem(context, Icons.chat_bubble_outline_rounded, l10n.mainNavMessages, 3, '/chat', totalUnread),
           _buildNavItem(context, Icons.work_outline_rounded, l10n.mainNavVacancies, 4, '/jobs', 0),
           _buildNavItem(context, Icons.account_circle_outlined, l10n.mainNavProfile, 1, '/profile/me', 0),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int itemIndex, String route, int badgeCount) {
    final isActive = selectedIndex == itemIndex;
    return Expanded(
      child: InkWell(
        onTap: () => context.go(route),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isActive ? AppColors.primary : AppColors.iconPrimary,
                  size: 24,
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Center(
                        child: Text(
                          badgeCount > 99 ? '99+' : '$badgeCount',
                          style: const TextStyle(
                            color: Colors.white,
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
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? AppColors.primary : AppColors.iconPrimary,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
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

  void _showLanguageModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final currentLocale = ref.watch(localeProvider);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.selectLanguage,
                  style: AppTextStyles.h3.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 16),
                _buildLanguageItem(context, ref, '🇺🇿', "O'zbekcha", 'uz', currentLocale.languageCode == 'uz'),
                _buildLanguageItem(context, ref, '🇷🇺', 'Русский', 'ru', currentLocale.languageCode == 'ru'),
                _buildLanguageItem(context, ref, '🇺🇸', 'English', 'en', currentLocale.languageCode == 'en'),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageItem(
    BuildContext context,
    WidgetRef ref,
    String flag,
    String label,
    String code,
    bool isSelected,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
        ),
      ),
      child: ListTile(
        leading: Text(flag, style: const TextStyle(fontSize: 24)),
        title: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
            : null,
        onTap: () {
          ref.read(localeProvider.notifier).setLocale(Locale(code));
          Navigator.pop(context);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
