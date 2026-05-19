import 'package:flutter/material.dart';
import '../../config/theme.dart';

class PronunciationButton extends StatefulWidget {
  final VoidCallback onTap;

  const PronunciationButton({super.key, required this.onTap});

  @override
  State<PronunciationButton> createState() => _PronunciationButtonState();
}

class _PronunciationButtonState extends State<PronunciationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _rippleController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() => _isPlaying = true);
    _rippleController.repeat(reverse: true);
    widget.onTap();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() => _isPlaying = false);
        _rippleController.stop();
        _rippleController.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _rippleController,
        builder: (context, child) {
          return Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isPlaying
                  ? TennisColors.voltGreen.withValues(alpha: 0.2)
                  : TennisColors.lavender.withValues(alpha: 0.15),
              border: Border.all(
                color: _isPlaying
                    ? TennisColors.voltGreen
                    : TennisColors.lavender.withValues(alpha: 0.4),
                width: 2,
              ),
              boxShadow: _isPlaying
                  ? [
                      BoxShadow(
                        color: TennisColors.voltGreen.withValues(alpha: 
                          0.2 + _rippleController.value * 0.3,
                        ),
                        blurRadius: 8 + _rippleController.value * 12,
                        spreadRadius: _rippleController.value * 4,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              Icons.volume_up_rounded,
              size: 22,
              color: _isPlaying
                  ? TennisColors.voltGreen
                  : TennisColors.lavender.withValues(alpha: 0.7),
            ),
          );
        },
      ),
    );
  }
}
