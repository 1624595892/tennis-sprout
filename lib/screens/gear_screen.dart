import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../widgets/common/paper_background.dart';
import '../widgets/common/hand_drawn_divider.dart';

class GearScreen extends StatelessWidget {
  const GearScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.ultraViolet,
        foregroundColor: AppColors.white,
        elevation: 2,
        centerTitle: true,
        shadowColor: AppColors.ultraViolet.withValues(alpha: 0.3),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RacketIcon(),
            SizedBox(width: 8),
            Text(
              '装备页',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
      body: PaperBackground(
        overlayColor: AppColors.wisteria.withValues(alpha: 0.30),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎾', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              const HandDrawnDivider(wavy: true),
              const SizedBox(height: 12),
              Text(
                '装备页',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ultraViolet.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '你的网球装备库即将开放',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ultraViolet.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RacketIcon extends StatelessWidget {
  const _RacketIcon();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(painter: _RacketPainter()),
    );
  }
}

class _RacketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.45;
    final cy = h * 0.35;
    final headR = w * 0.32;

    // Handle
    final handlePaint = Paint()
      ..color = AppColors.amber
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + headR + h * 0.22), width: w * 0.16, height: h * 0.32),
        const Radius.circular(3),
      ),
      handlePaint,
    );

    // Head
    final headPaint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: headR * 2.4, height: headR * 2.8),
      headPaint,
    );

    // Strings
    final stringPaint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (var i = -2; i <= 2; i++) {
      final dx = cx + i * headR * 0.38;
      canvas.drawLine(
        Offset(dx, cy - headR * 1.05),
        Offset(dx, cy + headR * 1.05),
        stringPaint,
      );
    }
    for (var i = -2; i <= 2; i++) {
      final dy = cy + i * headR * 0.38;
      canvas.drawLine(
        Offset(cx - headR * 0.88, dy),
        Offset(cx + headR * 0.88, dy),
        stringPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
