import 'package:flutter/material.dart';
import '../../config/theme.dart';

class PurpleCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final VoidCallback? onTap;
  final BorderRadiusGeometry? borderRadius;

  const PurpleCard({
    super.key,
    required this.child,
    this.padding,
    this.elevation,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: TennisColors.cardGradient,
        borderRadius:
            borderRadius ?? BorderRadius.circular(TennisTheme.radiusLG),
        boxShadow: [
          BoxShadow(
            color: TennisColors.deepPurple.withValues(alpha: 0.3),
            blurRadius: elevation ?? TennisTheme.shadowMedium,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }
    return card;
  }
}
