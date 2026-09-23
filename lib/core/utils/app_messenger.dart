import 'package:flutter/material.dart';
import '../widgets/app_snackbar.dart';

/// Attached to [GoRouter]'s `navigatorKey` (see app/app_router.dart) so
/// app-level services outside the widget tree (e.g. [ApiClient] reacting
/// to an expired session) can reach the app's [OverlayState] and show a
/// toast without needing a [BuildContext] of their own.
///
/// [NavigatorState.overlay] is used rather than a [BuildContext] plucked
/// from this key because `Overlay.of(context)` only ever looks *up* the
/// tree for an ancestor — a context sitting above the Navigator (as
/// `MaterialApp.scaffoldMessengerKey`'s context does) can never find the
/// Overlay the Navigator creates below it.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Same toast design as [ContextExtension.showSnackBar]
/// (see core/widgets/app_snackbar.dart) — used when there's no
/// [BuildContext] on hand, e.g. reacting to an expired session from
/// outside the widget tree.
void showGlobalSnackBar(String message, {bool isError = false}) {
  final OverlayState? overlay = rootNavigatorKey.currentState?.overlay;
  if (overlay == null) return;
  showAppToast(overlay, message, isError: isError);
}
