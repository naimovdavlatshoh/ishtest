import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/extensions.dart';
import '../providers/real_chat_provider.dart';
import '../providers/global_chat_provider.dart';
import '../../profile/providers/user_me_provider.dart';
import '../../../shared/models/user_me_model.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';

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

  @override
  void initState() {
    super.initState();
    _conversationId = int.tryParse(widget.chatId) ?? 0;
    Future.microtask(() {
      ref.read(chatRoomProvider(_conversationId).notifier).initialize();
      // Clear unread badge for this conversation globally
      ref.read(globalChatProvider.notifier).markConversationRead(_conversationId);
    });
  }

  @override
  void dispose() {
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
        elevation: 0,
        backgroundColor: Colors.white,
        leadingWidth: 40,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF101828)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
              onBackgroundImageError: avatarUrl != null ? (_, __) {} : null,
              child: avatarUrl == null
                  ? Text(initials, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 15))
                  : null,
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
                        state.isConnected ? 'online' : 'loading',
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
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[300], indent: 20)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Bugun',
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
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
                      ? _buildEmptyChat()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(bottom: 8, top: 4),
                          itemCount: state.messages.length,
                          itemBuilder: (context, index) {
                            final message = state.messages[index];
                            final isMe = message.senderId == myId;
                            return MessageBubble(
                              content: message.content,
                              isMe: isMe,
                              timestamp: message.createdAt,
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

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline_rounded, size: 38, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text('no_messages_yet', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('send_first_message', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
        ],
      ),
    );
  }
}
