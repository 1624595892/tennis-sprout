import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../widgets/common/paper_background.dart';
import '../widgets/common/hand_drawn_divider.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

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
            _SproutIcon(),
            SizedBox(width: 8),
            Text(
              '社群交流',
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
              const Text('💬', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              const HandDrawnDivider(wavy: true),
              const SizedBox(height: 12),
              Text(
                '社群交流',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ultraViolet.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '球友们在这里相遇 🎾',
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

class _SproutIcon extends StatelessWidget {
  const _SproutIcon();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(painter: _SproutPainter()),
    );
  }
}

class _SproutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final baseY = h * 0.85;
    final stemPaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(cx, baseY)
        ..quadraticBezierTo(cx + w * 0.3, baseY - h * 0.5, cx - w * 0.05, baseY - h * 0.85),
      stemPaint,
    );
    final leafPaint = Paint()
      ..color = AppColors.yellowGreen
      ..style = PaintingStyle.fill;
    canvas.drawPath(
      Path()
        ..moveTo(cx - w * 0.15, baseY - h * 0.55)
        ..quadraticBezierTo(cx - w * 0.55, baseY - h * 0.65, cx - w * 0.5, baseY - h * 0.78)
        ..quadraticBezierTo(cx - w * 0.15, baseY - h * 0.7, cx - w * 0.15, baseY - h * 0.55),
      leafPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx + w * 0.1, baseY - h * 0.42)
        ..quadraticBezierTo(cx + w * 0.55, baseY - h * 0.48, cx + w * 0.45, baseY - h * 0.62)
        ..quadraticBezierTo(cx + w * 0.1, baseY - h * 0.55, cx + w * 0.1, baseY - h * 0.42),
      leafPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
