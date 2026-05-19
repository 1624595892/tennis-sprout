import 'package:flutter/material.dart';
import '../../config/theme.dart';

class StatTapper extends StatelessWidget {
  final int winners;
  final int unforcedErrors;
  final int doubleFaults;
  final ValueChanged<String> onIncrement; // 'winner', 'ue', 'df'
  final ValueChanged<String> onDecrement;

  const StatTapper({
    super.key,
    required this.winners,
    required this.unforcedErrors,
    required this.doubleFaults,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatButton(
            label: 'WINNER',
            emoji: '🎾',
            count: winners,
            color: TennisColors.mintGreen,
            onTap: () => onIncrement('winner'),
            onLongPress: () => onDecrement('winner'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatButton(
            label: 'UE',
            emoji: '❌',
            count: unforcedErrors,
            color: TennisColors.amber,
            onTap: () => onIncrement('ue'),
            onLongPress: () => onDecrement('ue'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatButton(
            label: 'DF',
            emoji: '💔',
            count: doubleFaults,
            color: TennisColors.coralRed,
            onTap: () => onIncrement('df'),
            onLongPress: () => onDecrement('df'),
          ),
        ),
      ],
    );
  }
}

class _StatButton extends StatefulWidget {
  final String label;
  final String emoji;
  final int count;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _StatButton({
    required this.label,
    required this.emoji,
    required this.count,
    required this.color,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<_StatButton> createState() => _StatButtonState();
}

class _StatButtonState extends State<_StatButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleController.addListener(() {
      setState(() => _scale = _scaleController.value);
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _scaleController.forward().then((_) => _scaleController.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onLongPress: widget.onLongPress,
      child: Transform.scale(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.color.withValues(alpha: 0.2),
                widget.color.withValues(alpha: 0.05),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(TennisTheme.radiusMD),
            border: Border.all(
              color: widget.color.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 6),
              Text(
                '${widget.count}',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: widget.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: widget.color.withValues(alpha: 0.7),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
