import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MessageBubble extends StatelessWidget {
  final String content;
  final bool isMe;
  final DateTime timestamp;
  final bool isRead;
  final bool isDelivered;
  /// Whether this is the first bubble in a run of consecutive messages from
  /// the same sender — controls the rounded corner on the "start" side.
  final bool isFirstInGroup;
  /// Whether this is the last bubble in a run of consecutive messages from
  /// the same sender — controls the tail corner and whether the
  /// timestamp/read-receipt row is shown.
  final bool isLastInGroup;

  const MessageBubble({
    super.key,
    required this.content,
    required this.isMe,
    required this.timestamp,
    this.isRead = false,
    this.isDelivered = false,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
  });

  @override
  Widget build(BuildContext context) {
    const double roundCorner = 20;
    const double tightCorner = 6;

    return Padding(
      padding: EdgeInsets.only(
        left: isMe ? 64 : 16,
        right: isMe ? 16 : 64,
        top: isFirstInGroup ? 8 : 2,
        bottom: isLastInGroup ? 2 : 2,
      ),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                gradient: isMe
                    ? const LinearGradient(
                        colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isMe ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(!isMe && !isFirstInGroup ? tightCorner : roundCorner),
                  topRight: Radius.circular(isMe && !isFirstInGroup ? tightCorner : roundCorner),
                  bottomLeft: Radius.circular(!isMe && !isLastInGroup ? tightCorner : (isMe ? roundCorner : tightCorner + 2)),
                  bottomRight: Radius.circular(isMe && !isLastInGroup ? tightCorner : (isMe ? tightCorner + 2 : roundCorner)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isMe ? AppColors.primary : Colors.black).withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                content,
                style: TextStyle(
                  color: isMe ? Colors.white : const Color(0xFF101828),
                  fontSize: 14.5,
                  height: 1.45,
                ),
              ),
            ),
            if (isLastInGroup) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        isRead
                            ? LucideIcons.checkCheck
                            : isDelivered
                                ? LucideIcons.checkCheck
                                : LucideIcons.check,
                        size: 14,
                        color: isRead
                            ? AppColors.primary
                            : Colors.grey[400],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
