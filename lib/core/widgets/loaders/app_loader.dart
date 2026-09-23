import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AppLoader extends StatelessWidget {
  final double size;
  final Color? color;

  const AppLoader({
    super.key,
    this.size = 40,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class FullScreenLoader extends StatelessWidget {
  const FullScreenLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AppLoader(),
    );
  }
}
