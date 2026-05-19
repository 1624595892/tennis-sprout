import 'package:flutter/material.dart';
import '../../config/theme.dart';

class VoltButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  final IconData? icon;
  final double? width;
  final bool compact;

  const VoltButton({
    super.key,
    required this.label,
    this.onPressed,
    this.outlined = false,
    this.icon,
    this.width,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: compact ? 14 : 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );

    if (outlined) {
      return SizedBox(
        width: width,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: TennisColors.voltGreen,
            side: const BorderSide(color: TennisColors.voltGreen, width: 2),
            padding: compact
                ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
                : const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(TennisTheme.radiusFull),
            ),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: TennisColors.voltGreen,
          foregroundColor: TennisColors.deepPurple,
          elevation: TennisTheme.shadowMedium,
          shadowColor: TennisColors.voltGreen.withValues(alpha: 0.4),
          padding: compact
              ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
              : const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TennisTheme.radiusFull),
          ),
        ),
        child: child,
      ),
    );
  }
}
