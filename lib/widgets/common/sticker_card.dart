import 'dart:math';
import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// A card that looks like a hand-placed sticker in a journal —
/// slightly irregular borders, soft shadow, optional rotation.
class StickerCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double? rotation; // radians, e.g. 0.03 for slight tilt
  final Color? backgroundColor;
  final bool tornEdge;

  const StickerCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.rotation,
    this.backgroundColor,
    this.tornEdge = false,
  });

  @override
  Widget build(BuildContext context) {
    final rng = Random(hashCode);
    // Default to 0° — feature cards must stay horizontal.
    // Only the Daily Status Polaroid may receive an explicit micro-tilt.
    final tilt = rotation ?? 0.0;

    Widget card = Transform.rotate(
      angle: tilt,
      child: Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor ?? TennisColors.white,
          borderRadius: _irregularBorder(),
          boxShadow: [
            // Main soft shadow
            BoxShadow(
              color: TennisColors.taroDeep.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(2, 3),
            ),
            // Tiny crisp shadow for sticker edge
            BoxShadow(
              color: TennisColors.taroDeep.withValues(alpha: 0.04),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: child,
      ),
    );

    if (tornEdge) {
      card = ClipPath(
        clipper: _TornEdgeClipper(rng: rng),
        child: card,
      );
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }

  BorderRadius _irregularBorder() {
    // Slightly different radii per corner for a hand-drawn feel
    return const BorderRadius.only(
      topLeft: Radius.circular(22),
      topRight: Radius.circular(18),
      bottomLeft: Radius.circular(16),
      bottomRight: Radius.circular(24),
    );
  }
}

/// Simple torn-paper-edge clipper
class _TornEdgeClipper extends CustomClipper<Path> {
  final Random rng;

  _TornEdgeClipper({required this.rng});

  @override
  Path getClip(Size size) {
    final path = Path();
    final tearSegments = 12;
    final tearAmplitude = 4.0;

    // Top edge
    path.moveTo(_tear(0, 0, tearAmplitude, rng), 0);
    for (int i = 1; i <= tearSegments; i++) {
      final x = size.width * i / tearSegments;
      path.lineTo(x, _tear(x, 0, tearAmplitude, rng));
    }

    // Right edge
    for (int i = 1; i <= tearSegments; i++) {
      final y = size.height * i / tearSegments;
      path.lineTo(
        size.width + _tear(size.width, y, tearAmplitude, rng),
        y,
      );
    }

    // Bottom edge
    for (int i = tearSegments; i >= 0; i--) {
      final x = size.width * i / tearSegments;
      path.lineTo(
        x,
        size.height + _tear(x, size.height, tearAmplitude, rng),
      );
    }

    // Left edge
    for (int i = tearSegments; i >= 0; i--) {
      final y = size.height * i / tearSegments;
      path.lineTo(
        _tear(0, y, tearAmplitude, rng),
        y,
      );
    }

    path.close();
    return path;
  }

  double _tear(double x, double y, double amp, Random rng) {
    // Deterministic but looks random
    return (sin(x * 2.7 + y * 1.3) * amp + cos(x * 1.1 - y * 3.7) * amp * 0.6);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> old) => false;
}
