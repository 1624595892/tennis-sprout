import 'dart:math';
import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Full-screen paper-texture background with faint tennis-string grid pattern.
class PaperBackground extends StatelessWidget {
  final Widget child;
  final Color? overlayColor;

  const PaperBackground({super.key, required this.child, this.overlayColor});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PaperGridPainter(overlayColor: overlayColor),
      child: child,
    );
  }
}

class _PaperGridPainter extends CustomPainter {
  final _rng = Random(7);
  final Color? overlayColor;

  _PaperGridPainter({this.overlayColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Base cream paper fill
    final paperPaint = Paint()..color = AppColors.wisteriaLight;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paperPaint);

    // Faint paper fiber texture — scattered micro dots
    final fiberPaint = Paint()
      ..color = AppColors.ultraViolet.withValues(alpha: 0.015);

    for (int i = 0; i < (size.width * size.height / 400).round(); i++) {
      final x = _rng.nextDouble() * size.width;
      final y = _rng.nextDouble() * size.height;
      final r = 0.5 + _rng.nextDouble() * 1.0;
      canvas.drawCircle(Offset(x, y), r, fiberPaint);
    }

    // Tennis-string grid — very faint
    const gridSpacing = 24.0;
    final gridPaint = Paint()
      ..color = AppColors.ultraViolet.withValues(alpha: 0.08)
      ..strokeWidth = 0.5;

    // Vertical lines (mains)
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Horizontal lines (crosses)
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Slightly darker knot points at intersections (like string knots)
    final knotPaint = Paint()
      ..color = AppColors.ultraViolet.withValues(alpha: 0.04);

    for (double x = 0; x < size.width; x += gridSpacing) {
      for (double y = gridSpacing; y < size.height; y += gridSpacing) {
        canvas.drawCircle(Offset(x, y), 2.5, knotPaint);
      }
    }

    // Subtle vignette effect at edges
    final vignetteGradient = RadialGradient(
      center: Alignment.center,
      radius: 0.85,
      colors: [
        Colors.transparent,
        AppColors.ultraViolet.withValues(alpha: 0.025),
      ],
    );
    final vignettePaint = Paint()
      ..shader = vignetteGradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      vignettePaint,
    );

    // Optional wisteria tint overlay
    if (overlayColor != null) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = overlayColor!,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PaperGridPainter old) =>
      overlayColor != old.overlayColor;
}
