import 'package:flutter/material.dart';
import '../config/env.dart';

// String Extensions
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String toTitleCase() {
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  bool get isValidEmail {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(this);
  }

  bool get isValidPassword {
    return length >= 6;
  }

  String get fullImageUrl {
    if (isEmpty) return '';
    if (startsWith('http')) return this;
    // Remove leading slash if present to avoid double slashes
    final path = startsWith('/') ? substring(1) : this;
    if (path.isEmpty) return '';
    return '${Environment.apiBaseUrl}/uploads/$path';
  }
}

// DateTime Extensions
extension DateTimeExtension on DateTime {
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years${years == 1 ? ' year' : ' years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months${months == 1 ? ' month' : ' months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}${difference.inDays == 1 ? ' day' : ' days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}${difference.inHours == 1 ? ' hour' : ' hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}${difference.inMinutes == 1 ? ' minute' : ' minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  String get chatTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateTime = DateTime(year, month, day);
    final difference = now.difference(this);

    if (dateTime == today) {
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    } else if (dateTime == yesterday) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday - 1];
    } else {
      return '$day/${month.toString().padLeft(2, '0')}/$year';
    }
  }
}

// Number Extensions
extension IntExtension on int {
  String get compactFormat {
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    }
    return toString();
  }
}

// BuildContext Extensions
extension ContextExtension on BuildContext {
  // Theme
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // MediaQuery
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  // SnackBar
  void showSnackBar(String message, {bool isError = false}) {
    final bgColor = isError ? const Color(0xFFFFF1F1) : const Color(0xFFF1FFF8);
    final borderColor = isError ? const Color(0xFFFCA5A5) : const Color(0xFF86EFAC);
    final iconColor = isError ? const Color(0xFFDC2626) : const Color(0xFF16A34A);
    final textColor = isError ? const Color(0xFF991B1B) : const Color(0xFF065F46);

    final messenger = ScaffoldMessenger.of(this);
    messenger.clearSnackBars();
    
    final screenHeight = MediaQuery.of(this).size.height;
    final topPadding = MediaQuery.of(this).padding.top;
    
    // Position it slightly lower than before (was 160, now 220 from top)
    final bottomMargin = screenHeight - topPadding - 220;

    messenger.showSnackBar(
      SnackBar(
        content: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                color: iconColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: bottomMargin > 0 ? bottomMargin : 20,
          left: 16,
          right: 16,
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
