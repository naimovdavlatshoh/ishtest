import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/providers/ui_chrome_provider.dart';
import '../providers/real_chat_provider.dart';
import '../providers/global_chat_provider.dart';
import '../../profile/providers/user_me_provider.dart';
import '../../../shared/models/user_me_model.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  final String chatId;

  const ChatRoomScreen({super.key, required this.chatId});

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late final int _conversationId;
  // Captured up front: `ref` throws immediately if touched from dispose()
  // (ConsumerStatefulElement invalidates it before calling State.dispose()),
  // so the notifier reference must be grabbed while it's still safe to do so.
  late final StateController<bool> _hideBottomNavController;

  @override
  void initState() {
    super.initState();
    _conversationId = int.tryParse(widget.chatId) ?? 0;
    _hideBottomNavController = ref.read(hideBottomNavProvider.notifier);
    // Riverpod forbids modifying a provider while the widget tree is still
    // building (which initState/dispose both run during) — defer the actual
    // mutation to after the frame finishes, via the binding directly rather
    // than `ref`/microtask, so it's safe from both call sites.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hideBottomNavController.state = true;
    });
    Future.microtask(() {
      ref.read(chatRoomProvider(_conversationId).notifier).initialize();
      // Clear unread badge for this conversation globally
      ref.read(globalChatProvider.notifier).markConversationRead(_conversationId);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hideBottomNavController.state = false;
    });
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ChatRoomState state = ref.watch(chatRoomProvider(_conversationId));
    final UserMe? userMe = ref.watch(userMeProvider).valueOrNull;
    final int myId = userMe?.id ?? 0;
    final ParticipantModel? other = state.conversation?.otherParticipant(myId);
    final l10n = AppLocalizations.of(context)!;

    // Scroll to bottom when messages arrive
    if (state.messages.isNotEmpty) _scrollToBottom();

    final avatarUrl = other?.avatar?.fullImageUrl;
    final name = other?.fullName ?? 'conversation';
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        elevation: 0.5,
        shadowColor: Colors.black.withOpacity(0.06),
        backgroundColor: Colors.white,
        leadingWidth: 40,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            icon: const Icon(LucideIcons.chevronLeft, size: 20, color: Color(0xFF101828)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Row(
          children: [
            // Avatar with an online-glow ring
            Container(
              padding: EdgeInsets.all(state.isConnected ? 2 : 0),
              decoration: state.isConnected
                  ? const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF34D399)],
                      ),
                    )
                  : null,
              child: CircleAvatar(
                radius: 19,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: state.isConnected ? 17 : 19,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  onBackgroundImageError: avatarUrl != null ? (_, __) {} : null,
                  child: avatarUrl == null
                      ? Text(initials, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 15))
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF101828)),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        margin: const EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(
                          color: state.isConnected ? const Color(0xFF10B981) : Colors.grey[400],
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(
                        state.isConnected ? l10n.messagesOnline : l10n.messagesLoading,
                        style: TextStyle(
                          fontSize: 12,
                          color: state.isConnected ? const Color(0xFF10B981) : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        titleSpacing: 0,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Date divider
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[300], indent: 20)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            l10n.messagesToday,
                            style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[300], endIndent: 20)),
                    ],
                  ),
                ),

                // Messages
                Expanded(
                  child: state.messages.isEmpty
                      ? _buildEmptyChat(l10n)
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(bottom: 8, top: 4),
                          itemCount: state.messages.length,
                          itemBuilder: (context, index) {
                            final message = state.messages[index];
                            final isMe = message.senderId == myId;
                            final prevMsg = index > 0 ? state.messages[index - 1] : null;
                            final nextMsg = index < state.messages.length - 1 ? state.messages[index + 1] : null;
                            final isFirstInGroup = prevMsg == null || prevMsg.senderId != message.senderId;
                            final isLastInGroup = nextMsg == null || nextMsg.senderId != message.senderId;
                            return MessageBubble(
                              content: message.content,
                              isMe: isMe,
                              timestamp: message.createdAt,
                              isFirstInGroup: isFirstInGroup,
                              isLastInGroup: isLastInGroup,
                              isRead: message.status == 'read',
                              isDelivered: message.status == 'delivered',
                            );
                          },
                        ),
                ),

                // Input
                ChatInput(
                  onSend: (content) {
                    ref.read(chatRoomProvider(_conversationId).notifier).sendMessage(content);
                  },
                  isEnabled: state.isConnected,
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyChat(l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
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
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(0.12), blurRadius: 14, offset: const Offset(0, 5)),
                  ],
                ),
                child: const Icon(LucideIcons.messageCircle, size: 28, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.messagesNoMessagesYetRoom, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(l10n.messagesSendFirstMessage, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
        ],
      ),
    );
  }
}
