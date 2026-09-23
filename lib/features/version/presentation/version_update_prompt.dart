import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/app_messenger.dart';
import '../../../core/version/app_version.dart';
import '../../../core/version/version_check_provider.dart';
import 'optional_update_dialog.dart';

/// Shows the optional-update dialog once per launch, after the splash gate
/// has released the user into the app. A required update is a route, not a dialog.
class VersionUpdatePrompt extends ConsumerStatefulWidget {
  const VersionUpdatePrompt({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<VersionUpdatePrompt> createState() => _VersionUpdatePromptState();
}

class _VersionUpdatePromptState extends ConsumerState<VersionUpdatePrompt> {
  GoRouter? _router;
  bool _shown = false;
  bool _scheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _attachRouter());
  }

  @override
  void dispose() {
    _router?.routerDelegate.removeListener(_scheduleShow);
    super.dispose();
  }

  void _attachRouter() {
    if (!mounted || _router != null) return;
    final BuildContext? navContext = rootNavigatorKey.currentContext;
    if (navContext == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _attachRouter());
      return;
    }
    _router = GoRouter.of(navContext);
    _router!.routerDelegate.addListener(_scheduleShow);
    _scheduleShow();
  }

  void _scheduleShow() {
    if (_shown || _scheduled) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      _showIfNeeded();
    });
  }

  void _showIfNeeded() {
    if (!mounted || _shown) return;
    final VersionCheckState state = ref.read(versionCheckProvider);
    if (state.isChecking || state.decision != VersionUpdateDecision.optional) return;

    final String? storeUrl = state.storeUrl;
    if (storeUrl == null || storeUrl.isEmpty) return;

    final BuildContext? navContext = rootNavigatorKey.currentContext;
    if (navContext == null) return;

    final String path = GoRouter.of(navContext).routerDelegate.currentConfiguration.uri.path;
    if (path == '/splash' || path == '/force-update') return;

    _shown = true;
    showDialog<void>(
      context: navContext,
      barrierDismissible: true,
      builder: (BuildContext context) => OptionalUpdateDialog(storeUrl: storeUrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(versionCheckProvider, (VersionCheckState? previous, VersionCheckState next) {
      _scheduleShow();
    });
    return widget.child;
  }
}
