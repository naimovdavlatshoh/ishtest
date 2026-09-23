import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../providers/real_chat_provider.dart';
import '../providers/global_chat_provider.dart';
import '../../profile/providers/user_me_provider.dart';
import '../../../shared/models/user_me_model.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(conversationListProvider.notifier).load();
      ref.read(globalChatProvider.notifier); // ensure global ws is alive
    });
  }

  @override
  Widget build(BuildContext context) {
    final ConversationListState state = ref.watch(conversationListProvider);
    final UserMe? userMe = ref.watch(userMeProvider).valueOrNull;
    final int myId = userMe?.id ?? 0;
    final GlobalChatState globalState = ref.watch(globalChatProvider);
    final l10n = AppLocalizations.of(context)!;

    ref.listen(globalChatProvider, (prev, next) {
      if (prev?.unreadByConversation != next.unreadByConversation) {
        ref.read(conversationListProvider.notifier).load();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            Expanded(
              child: state.isLoading && state.conversations.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : state.conversations.isEmpty
                      ? _buildEmpty(l10n)
                      : RefreshIndicator(
                          onRefresh: () => ref.read(conversationListProvider.notifier).load(),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ListView.separated(
                                itemCount: state.conversations.length,
                                separatorBuilder: (context, index) => Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Colors.grey[100],
                                ),
                                itemBuilder: (context, index) {
                                  final conv = state.conversations[index];
                                  final other = conv.otherParticipant(myId);
                                  // Merge live unread count from global WS state
                                  final liveUnread = globalState.unreadByConversation[conv.id] ?? conv.unreadCount;
                                  return _ConvCard(
                                    conversation: conv,
                                    other: other,
                                    myId: myId,
                                    liveUnread: liveUnread,
                                    l10n: l10n,
                                    onTap: () {
                                      // Clear badge immediately on tap
                                      ref.read(globalChatProvider.notifier).markConversationRead(conv.id);
                                      context.push('/chat/${conv.id}');
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary.withOpacity(0.14), AppColors.primary.withOpacity(0.04)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 6)),
                  ],
                ),
                child: const Icon(LucideIcons.messageCircle, size: 32, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(l10n.messagesNoMessagesYet, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF101828))),
          const SizedBox(height: 8),
          Text(
            l10n.messagesStartChat,
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ConvCard extends ConsumerStatefulWidget {
  final AppLocalizations l10n;
  final ConversationModel conversation;
  final ParticipantModel? other;
  final int myId;
  final int liveUnread;
  final VoidCallback onTap;

  const _ConvCard({
    required this.conversation,
    required this.other,
    required this.myId,
    required this.liveUnread,
    required this.onTap,
    required this.l10n,
  });

  @override
  ConsumerState<_ConvCard> createState() => _ConvCardState();
}

class _ConvCardState extends ConsumerState<_ConvCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  int _prevUnread = 0;

  @override
  void initState() {
    super.initState();
    _prevUnread = widget.liveUnread;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.04)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_pulseController);
  }

  @override
  void didUpdateWidget(_ConvCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // New message arrived for this conversation — pulse animation
    if (widget.liveUnread > _prevUnread) {
      _pulseController.forward().then((_) => _pulseController.reverse());
    }
    _prevUnread = widget.liveUnread;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.other?.fullName ?? 'Foydalanuvchi';
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : '?';
    final avatarUrl = widget.other?.avatar?.fullImageUrl;
    final lastMsg = widget.conversation.lastMessage;
    final isUnread = widget.liveUnread > 0;

    return ScaleTransition(
      scale: _pulseAnim,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Avatar with status dot
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.primary.withOpacity(0.12),
                      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                      child: avatarUrl == null
                          ? Text(
                              initials,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 13,
                        height: 13,
                        decoration: BoxDecoration(
                          color: isUnread ? const Color(0xFF10B981) : Colors.grey[400],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.5,
                          color: Color(0xFF101828),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        lastMsg?.content ?? widget.l10n.messagesConversationStarted,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: isUnread ? AppColors.textSecondary : Colors.grey[500],
                          fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (lastMsg != null)
                      Text(
                        _formatTime(lastMsg.createdAt, widget.l10n),
                        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                      ),
                    if (isUnread) ...[
                      const SizedBox(height: 6),
                      Container(
                        constraints: const BoxConstraints(minWidth: 22),
                        height: 22,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          borderRadius: BorderRadius.all(Radius.circular(11)),
                        ),
                        child: Center(
                          child: Text(
                            widget.liveUnread > 99 ? '99+' : '${widget.liveUnread}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time, AppLocalizations l10n) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays == 0) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return l10n.messagesYesterday;
    }
    return '${time.day}/${time.month}';
  }
}
