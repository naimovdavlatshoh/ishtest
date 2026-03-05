import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/extensions.dart';
import '../providers/real_chat_provider.dart';
import '../providers/global_chat_provider.dart';
import '../../profile/providers/user_me_provider.dart';
import '../../../shared/models/user_me_model.dart';
import '../../../core/localization/language_provider.dart';

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
    final String Function(String) t = ref.watchTr;

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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                t('messages'),
                style: AppTextStyles.h2.copyWith(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: state.isLoading && state.conversations.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : state.conversations.isEmpty
                      ? _buildEmpty()
                      : RefreshIndicator(
                          onRefresh: () => ref.read(conversationListProvider.notifier).load(),
                          child: ListView.builder(
                            itemCount: state.conversations.length,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
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
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded, size: 44, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          const Text('Hali xabarlar yo\'q', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Mutaxassislar sahifasidan suhbat boshlang',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ConvCard extends ConsumerStatefulWidget {
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
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isUnread ? const Color(0xFFF0F5FF) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: isUnread
                ? Border.all(color: AppColors.primary.withOpacity(0.25), width: 1.5)
                : Border.all(color: Colors.transparent),
            boxShadow: [
              BoxShadow(
                color: isUnread
                    ? AppColors.primary.withOpacity(0.08)
                    : Colors.black.withOpacity(0.04),
                blurRadius: isUnread ? 12 : 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar with notification dot
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl == null
                        ? Text(
                            initials,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          )
                        : null,
                  ),
                  if (isUnread)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (lastMsg != null)
                          Text(
                            _formatTime(lastMsg.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: isUnread ? AppColors.primary : Colors.grey[400],
                              fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lastMsg?.content ?? 'Suhbat boshlandi',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: isUnread ? const Color(0xFF101828) : Colors.grey[500],
                              fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            constraints: const BoxConstraints(minWidth: 22),
                            height: 22,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
                              ),
                              borderRadius: BorderRadius.circular(11),
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
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays == 0) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Kecha';
    }
    return '${time.day}/${time.month}';
  }
}
