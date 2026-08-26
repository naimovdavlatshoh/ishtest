import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The single toast design used across the whole app: a rounded card that
/// slides in right below the notch/status bar — green for success, red for
/// error. Deliberately top-anchored (via [Overlay], not [ScaffoldMessenger])
/// so its position is exact and consistent on every screen, instead of the
/// old bottom-SnackBar-pushed-up-by-a-margin approach, which landed at a
/// different height depending on each screen's content and could overlap it.
///
/// Used both from a widget's [BuildContext] (see the `showSnackBar` context
/// extension in core/utils/extensions.dart) and app-wide with no context on
/// hand (see `showGlobalSnackBar` in core/utils/app_messenger.dart).
OverlayEntry? _activeToastEntry;

void showAppToast(OverlayState overlay, String message, {bool isError = false}) {
  _activeToastEntry?.remove();
  _activeToastEntry = null;

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _AppToast(
      message: message,
      isError: isError,
      onFinished: () {
        if (identical(_activeToastEntry, entry)) {
          _activeToastEntry = null;
        }
        entry.remove();
      },
    ),
  );

  _activeToastEntry = entry;
  overlay.insert(entry);
}

class _AppToast extends StatefulWidget {
  const _AppToast({
    required this.message,
    required this.isError,
    required this.onFinished,
  });

  final String message;
  final bool isError;
  final VoidCallback onFinished;

  @override
  State<_AppToast> createState() => _AppToastState();
}

class _AppToastState extends State<_AppToast> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _autoDismissTimer = Timer(const Duration(seconds: 3), _dismiss);
  }

  Future<void> _dismiss() async {
    _autoDismissTimer?.cancel();
    if (!mounted) {
      widget.onFinished();
      return;
    }
    await _controller.reverse();
    widget.onFinished();
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = widget.isError ? const Color(0xFFFFF1F1) : const Color(0xFFF1FFF8);
    final Color borderColor = widget.isError ? const Color(0xFFFCA5A5) : const Color(0xFF86EFAC);
    final Color iconColor = widget.isError ? const Color(0xFFDC2626) : const Color(0xFF16A34A);
    final Color textColor = widget.isError ? const Color(0xFF991B1B) : const Color(0xFF065F46);
    final double topInset = MediaQuery.of(context).padding.top;

    final CurvedAnimation curved = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

    return Positioned(
      top: topInset + 8,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, -1.2), end: Offset.zero).animate(curved),
        child: FadeTransition(
          opacity: curved,
          child: Material(
            color: Colors.transparent,
            child: Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.up,
              onDismissed: (_) => widget.onFinished(),
              child: GestureDetector(
                onTap: _dismiss,
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(
                        widget.isError ? LucideIcons.circleAlert : LucideIcons.circleCheck,
                        color: iconColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.message,
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
