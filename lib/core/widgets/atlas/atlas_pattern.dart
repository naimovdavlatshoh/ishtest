import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// The reference Central Asian majolica-tile artwork the user supplied,
/// used as the fill for the atlas band/splash pattern in place of the
/// procedural [IkatPatternPainter] below (kept intact so this can be
/// reverted with a one-line swap back to `CustomPaint(painter:
/// IkatPatternPainter(...))` if the image version doesn't stick).
const String _tileImagePath = 'assets/images/tile_pattern.png';

Widget buildAtlasPatternLayer({double opacity = 1.0}) {
  final Widget image = SizedBox.expand(
    child: Image.asset(_tileImagePath, fit: BoxFit.cover),
  );
  return opacity >= 1.0 ? image : Opacity(opacity: opacity, child: image);
}

/// Paints a richer take on the traditional Uzbek atlas/ikat medallion —
/// a glowing red/gold center diamond with a nested inner core, teal
/// corner jewels, gold edge accents, small paisley-like petals between
/// them, and a scatter of fine embroidery-dot texture. Soft dye-bleed
/// blur sits under crisp gold stitch outlines, tiled seamlessly to fill
/// whatever size the canvas is given.
class IkatPatternPainter extends CustomPainter {
  const IkatPatternPainter({
    this.opacity = 1.0,
    this.tileSize = 130,
    this.blurSigma = 5,
  });

  final double opacity;
  final double tileSize;
  final double blurSigma;

  static const Color _cream = Color(0xFFFBF3E7);
  static const Color _goldCore = Color(0xFFFFD98C);
  static const Color _redA = Color(0xFFE2672A);
  static const Color _redB = Color(0xFF9E1B2E);
  static const Color _goldA = Color(0xFFF7C25C);
  static const Color _goldB = Color(0xFFD9531E);
  static const Color _tealA = Color(0xFF4FA6B8);
  static const Color _tealB = Color(0xFF1B4C8C);
  static const Color _stitch = Color(0xFFFFE9BE);
  static const Color _petal = Color(0xFF2E7A8C);

  @override
  void paint(Canvas canvas, Size size) {
    final int cols = (size.width / tileSize).ceil() + 1;
    final int rows = (size.height / tileSize).ceil() + 1;

    for (int row = -1; row < rows; row++) {
      for (int col = -1; col < cols; col++) {
        _paintTile(canvas, Offset(col * tileSize, row * tileSize));
      }
    }
  }

  void _paintTile(Canvas canvas, Offset o) {
    final double t = tileSize;
    final Rect tileRect = Rect.fromLTWH(o.dx, o.dy, t, t);

    canvas.save();
    canvas.clipRect(tileRect);
    canvas.drawRect(tileRect, Paint()..color = _cream.withOpacity(opacity));

    final ui.MaskFilter softBlur = ui.MaskFilter.blur(BlurStyle.normal, blurSigma);
    final ui.MaskFilter lightBlur = ui.MaskFilter.blur(BlurStyle.normal, blurSigma * 0.5);

    Path diamondPath(Offset c, double r) {
      return Path()
        ..moveTo(c.dx, c.dy - r)
        ..lineTo(c.dx + r, c.dy)
        ..lineTo(c.dx, c.dy + r)
        ..lineTo(c.dx - r, c.dy)
        ..close();
    }

    void glowDiamond(Offset c, double r, Color a, Color b, {ui.MaskFilter? blur, bool stitch = true}) {
      final Path path = diamondPath(c, r);
      final Paint fill = Paint()
        ..shader = ui.Gradient.radial(
          c,
          r * 1.05,
          [a.withOpacity(opacity), b.withOpacity(opacity)],
          [0.0, 1.0],
        );
      if (blur != null) fill.maskFilter = blur;
      canvas.drawPath(path, fill);
      if (stitch) {
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(1.0, r * 0.045)
            ..color = _stitch.withOpacity(opacity * 0.75),
        );
      }
    }

    void leaf(Offset tip, Offset base, double width, Color color) {
      final double dx = tip.dx - base.dx;
      final double dy = tip.dy - base.dy;
      final double len = math.sqrt(dx * dx + dy * dy);
      if (len == 0) return;
      final double nx = -dy / len * width;
      final double ny = dx / len * width;
      final Offset mid1 = Offset((tip.dx + base.dx) / 2 + nx, (tip.dy + base.dy) / 2 + ny);
      final Offset mid2 = Offset((tip.dx + base.dx) / 2 - nx, (tip.dy + base.dy) / 2 - ny);
      final Path path = Path()
        ..moveTo(tip.dx, tip.dy)
        ..quadraticBezierTo(mid1.dx, mid1.dy, base.dx, base.dy)
        ..quadraticBezierTo(mid2.dx, mid2.dy, tip.dx, tip.dy)
        ..close();
      final Paint fill = Paint()
        ..color = color.withOpacity(opacity * 0.8)
        ..maskFilter = lightBlur;
      canvas.drawPath(path, fill);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9
          ..color = _stitch.withOpacity(opacity * 0.55),
      );
    }

    final Offset center = Offset(o.dx + t / 2, o.dy + t / 2);
    final double rBig = t * 0.30;
    final double rCore = t * 0.14;
    final double rCorner = t * 0.165;
    final double rEdge = t * 0.135;
    final double rPetalTip = t * 0.40;

    // Center medallion: outer glow diamond + nested inner core + jewel dot.
    glowDiamond(center, rBig, _goldA, _redB, blur: softBlur);
    glowDiamond(center, rCore, _goldCore, _redA, blur: lightBlur);
    canvas.drawCircle(center, math.max(1.5, rCore * 0.18), Paint()..color = _stitch.withOpacity(opacity * 0.9));

    // Paisley-like petals reaching from the center toward each corner.
    for (final Offset corner in [
      Offset(o.dx, o.dy),
      Offset(o.dx + t, o.dy),
      Offset(o.dx, o.dy + t),
      Offset(o.dx + t, o.dy + t),
    ]) {
      final double ux = (corner.dx - center.dx);
      final double uy = (corner.dy - center.dy);
      final double ulen = math.sqrt(ux * ux + uy * uy);
      final Offset tip = Offset(center.dx + ux / ulen * rPetalTip, center.dy + uy / ulen * rPetalTip);
      final Offset base = Offset(center.dx + ux / ulen * (rBig * 0.7), center.dy + uy / ulen * (rBig * 0.7));
      leaf(tip, base, t * 0.05, _petal);
    }

    // Corner jewels.
    for (final Offset corner in [
      Offset(o.dx, o.dy),
      Offset(o.dx + t, o.dy),
      Offset(o.dx, o.dy + t),
      Offset(o.dx + t, o.dy + t),
    ]) {
      glowDiamond(corner, rCorner, _tealA, _tealB, blur: softBlur);
      glowDiamond(corner, rCorner * 0.42, _cream, _tealA, blur: lightBlur, stitch: false);
    }

    // Edge-midpoint gold accents.
    for (final Offset mid in [
      Offset(o.dx + t / 2, o.dy),
      Offset(o.dx + t / 2, o.dy + t),
      Offset(o.dx, o.dy + t / 2),
      Offset(o.dx + t, o.dy + t / 2),
    ]) {
      glowDiamond(mid, rEdge, _goldA, _goldB, blur: softBlur);
    }

    // Fine embroidery-dot texture scattered around the medallion.
    final Paint dotPaint = Paint()..color = _stitch.withOpacity(opacity * 0.6);
    for (double angle = 0; angle < math.pi * 2; angle += math.pi / 6) {
      final double dr = rBig * 1.55;
      final Offset p = Offset(center.dx + math.cos(angle) * dr, center.dy + math.sin(angle) * dr);
      if (tileRect.contains(p)) {
        canvas.drawCircle(p, math.max(1.0, t * 0.008), dotPaint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant IkatPatternPainter oldDelegate) {
    return oldDelegate.opacity != opacity ||
        oldDelegate.tileSize != tileSize ||
        oldDelegate.blurSigma != blurSigma;
  }
}

/// Builds the repeating pointed-arch silhouette (echoing the scalloped
/// iwan/gateway arcades of Uzbek madrasah architecture) used as both the
/// clip boundary and the decorative trim line for [AtlasBand].
Path buildArchPath(Size size, {required double archDepth, required int archCount}) {
  final double w = size.width;
  final double base = size.height - archDepth;
  final double unit = w / archCount;

  final Path path = Path()..moveTo(0, base);
  for (int i = 0; i < archCount; i++) {
    final double x0 = i * unit;
    path
      ..quadraticBezierTo(x0 + unit * 0.24, base + archDepth * 1.35, x0 + unit * 0.5, base + archDepth)
      ..quadraticBezierTo(x0 + unit * 0.76, base + archDepth * 1.35, x0 + unit, base);
  }
  return path;
}

/// Clips the bottom edge of a band into a repeating pointed-arch
/// silhouette instead of a plain rectangle or a single soft wave.
class AtlasArchClipper extends CustomClipper<Path> {
  const AtlasArchClipper({this.archDepth = 18, this.archCount = 4});

  final double archDepth;
  final int archCount;

  @override
  Path getClip(Size size) {
    final double w = size.width;
    final double base = size.height - archDepth;
    final double unit = w / archCount;

    final Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, base);

    for (int i = archCount - 1; i >= 0; i--) {
      final double x0 = i * unit;
      path
        ..quadraticBezierTo(x0 + unit * 0.76, base + archDepth * 1.35, x0 + unit * 0.5, base + archDepth)
        ..quadraticBezierTo(x0 + unit * 0.24, base + archDepth * 1.35, x0, base);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant AtlasArchClipper oldClipper) =>
      oldClipper.archDepth != archDepth || oldClipper.archCount != archCount;
}

/// Strokes a thin gold trim line along the same arch silhouette
/// [AtlasArchClipper] cuts — the "piping" that makes the band read as
/// woven trim rather than a clipped photo.
class _ArchTrimPainter extends CustomPainter {
  const _ArchTrimPainter({required this.archDepth, required this.archCount});

  final double archDepth;
  final int archCount;

  @override
  void paint(Canvas canvas, Size size) {
    final Path arches = buildArchPath(size, archDepth: archDepth, archCount: archCount);
    canvas.drawPath(
      arches,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..color = const Color(0xFFFFE9BE).withOpacity(0.9)
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ArchTrimPainter oldDelegate) =>
      oldDelegate.archDepth != archDepth || oldDelegate.archCount != archCount;
}

/// A decorative medallion badge — concentric gold rings with small
/// diamond studs, for laying a logo mark on top of the atlas band
/// instead of a plain flat chip.
class AtlasMedallion extends StatelessWidget {
  const AtlasMedallion({super.key, this.size = 84, this.child});

  final double size;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final double badge = size * 0.6;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: Size.square(size), painter: const _MedallionRingPainter()),
          Container(
            width: badge,
            height: badge,
            padding: EdgeInsets.all(badge * 0.11),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(badge * 0.26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _MedallionRingPainter extends CustomPainter {
  const _MedallionRingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = Offset(size.width / 2, size.height / 2);
    final double rOuter = size.width * 0.48;
    final double rInner = size.width * 0.40;

    canvas.drawCircle(
      c,
      rOuter,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = const Color(0xFFFFE9BE).withOpacity(0.95),
    );
    canvas.drawCircle(
      c,
      rInner,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withOpacity(0.85),
    );

    for (int i = 0; i < 4; i++) {
      final double angle = i * math.pi / 2 - math.pi / 2;
      final Offset p = Offset(c.dx + math.cos(angle) * rOuter, c.dy + math.sin(angle) * rOuter);
      final double r = size.width * 0.045;
      final Path diamond = Path()
        ..moveTo(p.dx, p.dy - r)
        ..lineTo(p.dx + r, p.dy)
        ..lineTo(p.dx, p.dy + r)
        ..lineTo(p.dx - r, p.dy)
        ..close();
      canvas.drawPath(diamond, Paint()..color = const Color(0xFFF7C25C));
    }
    for (int i = 0; i < 4; i++) {
      final double angle = i * math.pi / 2 - math.pi / 4;
      final Offset p = Offset(c.dx + math.cos(angle) * rOuter, c.dy + math.sin(angle) * rOuter);
      canvas.drawCircle(p, size.width * 0.018, Paint()..color = Colors.white.withOpacity(0.9));
    }
  }

  @override
  bool shouldRepaint(covariant _MedallionRingPainter oldDelegate) => false;
}

/// A ready-to-drop-in decorative ikat band: an arch-bottomed shape filled
/// with [IkatPatternPainter] plus a gold trim line, with an optional
/// [child] laid on top (e.g. an [AtlasMedallion]). Used at the top of the
/// auth screens and the splash screen; the shared app shell (see
/// MainScreen) paints the same pattern directly into its AppBar's
/// flexibleSpace instead, since that needs to coexist with the AppBar's
/// own title/actions layout.
class AtlasBand extends StatelessWidget {
  const AtlasBand({
    super.key,
    required this.height,
    this.archDepth = 18,
    this.archCount = 4,
    this.tileSize = 130,
    this.opacity = 1.0,
    this.blurSigma = 5,
    this.child,
  });

  final double height;
  final double archDepth;
  final int archCount;
  final double tileSize;
  final double opacity;
  final double blurSigma;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipPath(
            clipper: AtlasArchClipper(archDepth: archDepth, archCount: archCount),
            child: buildAtlasPatternLayer(opacity: opacity),
          ),
          CustomPaint(painter: _ArchTrimPainter(archDepth: archDepth, archCount: archCount)),
          if (child != null) child!,
        ],
      ),
    );
  }
}
