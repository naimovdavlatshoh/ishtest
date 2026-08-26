import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Flat brand-blue banner with rounded bottom corners, used at the top of
/// the auth screens and the splash screen in place of the old ikat/atlas
/// pattern. Optionally lays a [child] (e.g. an [AppLogoBadge]) on top.
class AppHeaderBand extends StatelessWidget {
  const AppHeaderBand({
    super.key,
    required this.height,
    this.borderRadius = 32,
    this.child,
  });

  final double height;
  final double borderRadius;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(borderRadius),
        bottomRight: Radius.circular(borderRadius),
      ),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
        ),
        child: child,
      ),
    );
  }
}

/// A plain rounded-square white badge with a soft shadow, for laying a
/// logo/icon on top of [AppHeaderBand] instead of a flat unstyled image.
class AppLogoBadge extends StatelessWidget {
  const AppLogoBadge({super.key, this.size = 84, this.child});

  final double size;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
