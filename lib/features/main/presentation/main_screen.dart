import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/providers/locale_provider.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/providers/profile_me_provider.dart';
import '../../../core/utils/extensions.dart';
import '../../chat/providers/global_chat_provider.dart';
import '../../chat/providers/invitations_provider.dart';
import '../../../core/providers/ui_chrome_provider.dart';
import '../../notifications/providers/notifications_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MainScreen extends ConsumerWidget {
  final Widget child;
  final int selectedIndex;
  final bool showBottomNav;

  const MainScreen({
    super.key,
    required this.child,
    this.selectedIndex = 0,
    this.showBottomNav = true,
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
    final displayTitle =
        profile?.title ?? currentUser?.headline ?? l10n.defaultExpert;

    final userInitial =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'I';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.lightStatusBar,
      child: Scaffold(
        backgroundColor: AppColors.background,
        // The nested screen (e.g. ChatRoomScreen) has its own Scaffold and
        // handles its own keyboard avoidance; letting this outer shell resize
        // too causes the classic nested-Scaffold double-adjustment where a
        // bottom-pinned input ends up hidden behind the keyboard.
        resizeToAvoidBottomInset: false,
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          backgroundImage: profile?.avatar != null &&
                                  profile!.avatar!.isNotEmpty
                              ? NetworkImage(profile.avatar!.fullImageUrl)
                              : null,
                          child: profile?.avatar == null ||
                                  profile!.avatar!.isEmpty
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
                                style: AppTextStyles.caption
                                    .copyWith(fontSize: 11),
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
                  LucideIcons.house,
                  l10n.drawerDashboard,
                  '/feed',
                  0,
                ),
                _buildDrawerItem(
                  context,
                  LucideIcons.user,
                  l10n.drawerMyProfile,
                  '/profile/me',
                  1,
                ),
                _buildDrawerItemWithBadge(
                  context,
                  LucideIcons.messageCircle,
                  l10n.mainNavMessages,
                  '/chat',
                  3,
                  totalUnread,
                ),
                _buildDrawerItemWithBadge(
                  context,
                  LucideIcons.bell,
                  l10n.drawerNotifications,
                  '/notifications',
                  11,
                  ref.watch(notificationsUnreadCountProvider),
                ),
                _buildDrawerItemWithBadge(
                  context,
                  LucideIcons.mail,
                  l10n.drawerInvitations,
                  '/invitations',
                  9,
                  ref.watch(pendingInvitationsCountProvider),
                ),
                _buildDrawerItem(
                  context,
                  LucideIcons.users,
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
                  LucideIcons.briefcase,
                  l10n.drawerViewVacancies,
                  '/jobs',
                  4,
                ),
                _buildDrawerItem(
                  context,
                  LucideIcons.bookmarkCheck,
                  l10n.drawerSaved,
                  '/jobs/saved',
                  6,
                ),
                _buildDrawerItem(
                  context,
                  LucideIcons.circlePlus,
                  l10n.drawerAddVacancy,
                  '/jobs/add',
                  8,
                ),
                _buildDrawerItem(
                  context,
                  LucideIcons.fileText,
                  l10n.drawerMyVacancies,
                  '/jobs/my-jobs',
                  7,
                ),

                const SizedBox(height: 16),

                // XIZMATLAR section
                Text(
                  l10n.drawerServicesGroup,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDrawerItem(
                  context,
                  LucideIcons.wrench,
                  l10n.drawerViewServices,
                  '/services',
                  12,
                ),
                _buildDrawerItem(
                  context,
                  LucideIcons.circlePlus,
                  l10n.drawerAddService,
                  '/services/add',
                  13,
                ),
                _buildDrawerItem(
                  context,
                  LucideIcons.fileText,
                  l10n.drawerMyServices,
                  '/services/my-services',
                  14,
                ),

                const SizedBox(height: 16),

                // POSTLAR section
                Text(
                  l10n.drawerPostsGroup,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                _buildDrawerItem(
                  context,
                  LucideIcons.newspaper,
                  l10n.drawerViewPosts,
                  '/posts',
                  15,
                ),
                _buildDrawerItem(
                  context,
                  LucideIcons.circlePlus,
                  l10n.drawerCreatePost,
                  '/posts/add',
                  16,
                ),
                _buildDrawerItem(
                  context,
                  LucideIcons.fileText,
                  l10n.drawerMyPosts,
                  '/posts/my-posts',
                  17,
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
                  LucideIcons.send,
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
                  LucideIcons.building2,
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
                    LucideIcons.settings,
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
                    LucideIcons.eye,
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
                    LucideIcons.fileText,
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
                    LucideIcons.logOut,
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
        appBar: _buildHeader(context, ref, l10n),
        body: child,
        bottomNavigationBar:
            (showBottomNav && !ref.watch(hideBottomNavProvider))
                ? _buildBottomNavBar(context, totalUnread, l10n)
                : null,
      ),
    );
  }

  PreferredSize _buildHeader(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final double topPad = MediaQuery.of(context).padding.top;
    const double logoSize = 48;
    const double contentTopGap = 6;
    const double contentBottomGap = 14;
    final double totalHeight =
        topPad + contentTopGap + logoSize + contentBottomGap;

    return PreferredSize(
      preferredSize: Size.fromHeight(totalHeight),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppTheme.lightStatusBar,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(22),
            bottomRight: Radius.circular(22),
          ),
          child: Container(
            height: totalHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  16, topPad + contentTopGap, 16, contentBottomGap),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.asset(
                      'assets/images/ishlogo.png',
                      width: logoSize,
                      height: logoSize,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: logoSize,
                          height: logoSize,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Center(
                            child: Text(
                              'ish',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _headerTitle(selectedIndex, l10n),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ish.uz',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _headerTextButton(
                    text: ref.watch(localeProvider).languageCode.toUpperCase(),
                    onPressed: () => _showLanguageModal(context, ref),
                  ),
                  const SizedBox(width: 8),
                  Builder(
                    builder: (context) => _headerIconButton(
                      icon: LucideIcons.menu,
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerIconButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return Material(
      color: Colors.white.withOpacity(0.92),
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.2),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 20, color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _headerTextButton(
      {required String text, required VoidCallback onPressed}) {
    return Material(
      color: Colors.white.withOpacity(0.92),
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.2),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _headerTitle(int index, AppLocalizations l10n) {
    switch (index) {
      case 0:
        return l10n.mainHeaderDashboard;
      case 1:
        return l10n.drawerMyProfile;
      case 2:
        return l10n.drawerEmployees;
      case 3:
        return l10n.mainNavMessages;
      case 4:
        return l10n.drawerViewVacancies;
      case 5:
        return l10n.drawerMyCompanies;
      case 6:
        return l10n.drawerSaved;
      case 7:
        return l10n.drawerMyVacancies;
      case 8:
        return l10n.drawerAddVacancy;
      case 9:
        return l10n.drawerInvitations;
      case 10:
        return l10n.drawerMyApplications;
      case 11:
        return l10n.drawerNotifications;
      case 12:
        return l10n.drawerViewServices;
      case 13:
        return l10n.drawerAddService;
      case 14:
        return l10n.drawerMyServices;
      case 15:
        return l10n.drawerViewPosts;
      case 16:
        return l10n.drawerCreatePost;
      case 17:
        return l10n.drawerMyPosts;
      default:
        return l10n.mainHeaderDashboard;
    }
  }

  Widget _buildBottomNavBar(
      BuildContext context, int totalUnread, AppLocalizations l10n) {
    return Container(
      margin: EdgeInsets.fromLTRB(
          16, 0, 16, MediaQuery.of(context).padding.bottom + 14),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(
              context, LucideIcons.house, l10n.drawerDashboard, 0, '/feed', 0),
          _buildNavItem(context, LucideIcons.messageCircle,
              l10n.mainNavMessages, 3, '/chat', totalUnread),
          _buildNavItem(context, LucideIcons.briefcase, l10n.mainNavVacancies,
              4, '/jobs', 0),
          _buildNavItem(context, LucideIcons.newspaper, l10n.mainNavPosts, 15,
              '/posts', 0),
          _buildNavItem(context, LucideIcons.circleUserRound,
              l10n.mainNavProfile, 1, '/profile/me', 0),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label,
      int itemIndex, String route, int badgeCount) {
    final isActive = selectedIndex == itemIndex;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.go(route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
              horizontal: isActive ? 14 : 11, vertical: 11),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    color: isActive ? AppColors.primary : Colors.white,
                    size: 22,
                  ),
                  if (badgeCount > 0)
                    Positioned(
                      top: -5,
                      right: -7,
                      child: Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isActive ? Colors.white : AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 15,
                          minHeight: 15,
                        ),
                        child: Center(
                          child: Text(
                            badgeCount > 99 ? '99+' : '$badgeCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (isActive) ...[
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ],
          ),
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
                  constraints:
                      const BoxConstraints(minWidth: 16, minHeight: 16),
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
                _buildLanguageItem(context, ref, '🇺🇿', "O'zbekcha", 'uz',
                    currentLocale.languageCode == 'uz'),
                _buildLanguageItem(context, ref, '🇷🇺', 'Русский', 'ru',
                    currentLocale.languageCode == 'ru'),
                _buildLanguageItem(context, ref, '🇺🇸', 'English', 'en',
                    currentLocale.languageCode == 'en'),
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
        color: isSelected
            ? AppColors.primary.withOpacity(0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppColors.primary.withOpacity(0.2)
              : Colors.transparent,
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
            ? const Icon(LucideIcons.circleCheck, color: AppColors.primary)
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
