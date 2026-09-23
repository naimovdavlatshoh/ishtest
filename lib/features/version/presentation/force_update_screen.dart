import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/version/version_check_provider.dart';
import '../../../core/widgets/app_header/app_header.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../l10n/app_localizations.dart';
import 'open_store.dart';

/// Full-screen gate. There is no way past it until the installed version
/// is at least `minimum_version`.
class ForceUpdateScreen extends ConsumerWidget {
  const ForceUpdateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final String storeUrl = ref.watch(versionCheckProvider).storeUrl ?? '';

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
            child: Column(
              children: [
                const Spacer(),
                AppLogoBadge(
                  size: 96,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/ishlogo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  l10n?.updateRequiredTitle ?? 'Update required',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h2,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n?.updateRequiredMessage ??
                      'This version of the app is no longer supported. Please update to continue.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                ),
                const Spacer(),
                PrimaryButton(
                  text: l10n?.updateNow ?? 'Update',
                  onPressed: storeUrl.isEmpty ? null : () => openStoreListing(storeUrl),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
