import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import 'open_store.dart';

class OptionalUpdateDialog extends StatelessWidget {
  const OptionalUpdateDialog({super.key, required this.storeUrl});

  final String storeUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(
        l10n?.updateOptionalTitle ?? 'Update available',
        style: AppTextStyles.h3,
      ),
      content: Text(
        l10n?.updateOptionalMessage ??
            'A newer version of the app is available. Update to get the latest improvements.',
        style: AppTextStyles.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n?.updateLater ?? 'Later'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            openStoreListing(storeUrl);
          },
          child: Text(l10n?.updateNow ?? 'Update'),
        ),
      ],
    );
  }
}
