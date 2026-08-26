import 'package:flutter/material.dart';
import '../../../core/widgets/atlas/atlas_pattern.dart';

/// Shown briefly while the stored session is being checked at cold start
/// (see authProvider._init and the '/splash' gate in app_router.dart) —
/// the bold, full-bleed take on the atlas/ikat pattern.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          buildAtlasPatternLayer(),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.15),
                radius: 0.9,
                colors: [Color(0x0D000000), Color(0x47000000)],
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AtlasMedallion(
                size: 132,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    'assets/images/ishlogo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const ColoredBox(
                      color: Color(0xFF2563EB),
                      child: Center(
                        child: Text(
                          'ish',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'ish.uz',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.2),
              ),
              const SizedBox(height: 8),
              Text(
                'Ish topish endi oson',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.88)),
              ),
            ],
          ),
          Positioned(
            bottom: 56,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.85)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
