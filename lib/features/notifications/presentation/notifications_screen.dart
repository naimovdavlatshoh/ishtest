import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linkedin_clone/core/theme/app_colors.dart';
import 'package:linkedin_clone/core/theme/app_text_styles.dart';
import 'package:linkedin_clone/core/widgets/loaders/app_loader.dart';
import 'package:linkedin_clone/core/widgets/empty_states/empty_state.dart';
import 'package:linkedin_clone/shared/models/notification_item_model.dart';
import '../providers/notifications_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(notificationsProvider.notifier).loadNotifications());
  }

  String _formatTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inDays == 0) {
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else if (diff.inDays == 1) {
        return 'Kecha';
      }
      return '${date.day}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          if (state.unreadCount > 0)
            TextButton(
              onPressed: () => ref.read(notificationsProvider.notifier).markAllRead(),
              child: const Text("Hammasini o'qish"),
            ),
        ],
      ),
      body: SafeArea(child: _buildBody(state)),
    );
  }

  Widget _buildBody(NotificationsState state) {
    if (state.isLoading && state.items.isEmpty) {
      return const AppLoader();
    }

    if (state.items.isEmpty) {
      return EmptyState(
        icon: LucideIcons.bell,
        title: "Bildirishnomalar yo'q",
        message: 'Yangi bildirishnomalar shu yerda ko\'rinadi',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(notificationsProvider.notifier).loadNotifications(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: state.items.length,
        itemBuilder: (context, index) {
          final NotificationItemModel item = state.items[index];
          return _buildRow(item);
        },
      ),
    );
  }

  Widget _buildRow(NotificationItemModel item) {
    final bool isUnread = !item.isRead;
    return GestureDetector(
      onTap: () {
        if (isUnread) ref.read(notificationsProvider.notifier).markRead(item.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnread ? const Color(0xFFF0F5FF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: isUnread ? Border.all(color: AppColors.primary.withOpacity(0.25), width: 1.5) : Border.all(color: Colors.transparent),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(LucideIcons.bell, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: AppTextStyles.bodyMedium.copyWith(fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500),
                        ),
                      ),
                      Text(_formatTime(item.createdAt), style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(item.body, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            if (isUnread)
              Container(
                margin: const EdgeInsets.only(left: 8, top: 4),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}
