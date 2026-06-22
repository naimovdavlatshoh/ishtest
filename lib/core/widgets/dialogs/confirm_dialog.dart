import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final displayConfirm = confirmText ?? (l10n != null ? l10n.save : 'Confirm');
    final displayCancel = cancelText ?? (l10n != null ? l10n.cancel : 'Cancel');

    return AlertDialog(
      title: Text(title, style: AppTextStyles.h3),
      content: Text(message, style: AppTextStyles.bodyMedium),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(displayCancel),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm?.call();
          },
          child: Text(displayConfirm),
        ),
      ],
    );
  }

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
      ),
    );
  }
}

class ErrorDialog extends StatelessWidget {
  final String? title;
  final String message;

  const ErrorDialog({
    super.key,
    this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final displayTitle = title ?? (l10n != null ? l10n.errorOccurred : 'Error');

    return AlertDialog(
      title: Text(displayTitle, style: AppTextStyles.h3.copyWith(color: AppColors.error)),
      content: Text(message, style: AppTextStyles.bodyMedium),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }

  static void show(BuildContext context, {String? title, required String message}) {
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(title: title, message: message),
    );
  }
}
