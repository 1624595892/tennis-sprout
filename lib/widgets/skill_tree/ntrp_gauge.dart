import 'dart:math';
import 'package:flutter/material.dart';
import '../../config/theme.dart';

class NtrpGauge extends StatelessWidget {
  final double ntprLevel;

  const NtrpGauge({super.key, required this.ntprLevel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: TennisColors.cardGradient,
        borderRadius: BorderRadius.circular(TennisTheme.radiusLG),
        boxShadow: [
          BoxShadow(
            color: TennisColors.deepPurple.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'NTRP Rating',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: TennisColors.lavender,
            ),
          ),
          const SizedBox(height: 8),
          // Gauge
          SizedBox(
            height: 160,
            child: CustomPaint(
              painter: _NtrpGaugePainter(level: ntprLevel),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ntprLevel.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        color: TennisColors.voltGreen,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      'Estimated Level',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: TennisColors.lavender.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Scale labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final label = '${i + 1}.0';
              final isHighlight = (i + 1.0 - ntprLevel).abs() < 0.75;
              return Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
                  color: isHighlight
                      ? TennisColors.voltGreen
                      : TennisColors.lavender.withValues(alpha: 0.4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _NtrpGaugePainter extends CustomPainter {
  final double level;

  _NtrpGaugePainter({required this.level});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 20);
    final radius = min(size.width / 2, size.height) - 10;

    // Background arc
    final bgPaint = Paint()
      ..color = TennisColors.lavender.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      bgPaint,
    );

    // Level arc
    final levelFraction = (level - 1.0) / 6.0; // 1.0-7.0 → 0.0-1.0
    final levelPaint = Paint()
      ..shader = const LinearGradient(
        colors: [TennisColors.voltGreenDark, TennisColors.voltGreen],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi * levelFraction,
      false,
      levelPaint,
    );

    // Glow effect on the active arc
    final glowPaint = Paint()
      ..color = TennisColors.voltGreen.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 32
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi * levelFraction,
      false,
      glowPaint,
    );

    // Tick marks
    final tickPaint = Paint()
      ..color = TennisColors.lavender.withValues(alpha: 0.3)
      ..strokeWidth = 1.5;

    for (int i = 0; i <= 6; i++) {
      final angle = pi + (pi * i / 6);
      final innerRadius = radius - 28;
      final outerRadius = radius + 2;

      final start = Offset(
        center.dx + cos(angle) * innerRadius,
        center.dy + sin(angle) * innerRadius,
      );
      final end = Offset(
        center.dx + cos(angle) * outerRadius,
        center.dy + sin(angle) * outerRadius,
      );

      canvas.drawLine(start, end, tickPaint);
    }

    // Needle
    final needleAngle = pi + (pi * levelFraction);
    final needleLength = radius - 16;
    final needleEnd = Offset(
      center.dx + cos(needleAngle) * needleLength,
      center.dy + sin(needleAngle) * needleLength,
    );

    final needlePaint = Paint()
      ..color = TennisColors.voltGreen
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, needleEnd, needlePaint);

    // Needle tip glow
    final tipGlow = Paint()
      ..color = TennisColors.voltGreen.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(needleEnd, 6, tipGlow);

    // Center cap
    final capPaint = Paint()..color = TennisColors.deepPurple;
    canvas.drawCircle(center, 10, capPaint);
    final capBorder = Paint()
      ..color = TennisColors.voltGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, 10, capBorder);
  }

  @override
  bool shouldRepaint(covariant _NtrpGaugePainter oldDelegate) =>
      oldDelegate.level != level;
}
