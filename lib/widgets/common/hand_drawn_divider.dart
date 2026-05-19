import 'dart:math';
import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// A hand-drawn style divider — looks like a double dashed line
/// or wavy tennis-string separator in a journal.
class HandDrawnDivider extends StatelessWidget {
  final double dashWidth;
  final double dashGap;
  final double lineHeight;
  final Color color;
  final bool wavy; // tennis-string wave

  const HandDrawnDivider({
    super.key,
    this.dashWidth = 6.0,
    this.dashGap = 4.0,
    this.lineHeight = 1.2,
    this.color = TennisColors.pistachioDark,
    this.wavy = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        height: wavy ? 28 : 16,
        child: CustomPaint(
          painter: wavy ? _WaveDividerPainter(color: color) : _DashDividerPainter(
            dashWidth: dashWidth,
            dashGap: dashGap,
            color: color,
            lineHeight: lineHeight,
          ),
        ),
      ),
    );
  }
}

class _DashDividerPainter extends CustomPainter {
  final double dashWidth;
  final double dashGap;
  final Color color;
  final double lineHeight;

  _DashDividerPainter({
    required this.dashWidth,
    required this.dashGap,
    required this.color,
    required this.lineHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..strokeWidth = lineHeight
      ..strokeCap = StrokeCap.round;

    final midY = size.height / 2;

    // Two parallel dashed lines
    for (final offsetY in [midY - 3, midY + 3]) {
      double x = 0;
      while (x < size.width) {
        canvas.drawLine(
          Offset(x, offsetY),
          Offset(min(x + dashWidth, size.width), offsetY),
          paint,
        );
        x += dashWidth + dashGap;
      }
    }

    // Small dots at each end (journal style)
    final dotPaint = Paint()..color = color.withValues(alpha: 0.3);
    canvas.drawCircle(Offset(6, midY), 2, dotPaint);
    canvas.drawCircle(Offset(size.width - 6, midY), 2, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// Tennis-string wave divider — looks like vibrating racket strings
class _WaveDividerPainter extends CustomPainter {
  final Color color;

  _WaveDividerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final midY = size.height / 2;

    // Draw 5 horizontal wavy "string" lines
    for (int s = -2; s <= 2; s++) {
      final path = Path();
      final yBase = midY + s * 5.5;

      path.moveTo(0, yBase);
      for (double x = 0; x < size.width; x += 2) {
        final wave = sin(x * 0.04 + s) * 2.5;
        path.lineTo(x, yBase + wave);
      }

      canvas.drawPath(path, paint);
    }

    // Small tennis ball dot in center
    final ballPaint = Paint()..color = color.withValues(alpha: 0.45);
    canvas.drawCircle(Offset(size.width / 2, midY), 3.5, ballPaint);

    // Tiny string dots at edges
    canvas.drawCircle(Offset(12, midY), 1.5, ballPaint);
    canvas.drawCircle(Offset(size.width - 12, midY), 1.5, ballPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
