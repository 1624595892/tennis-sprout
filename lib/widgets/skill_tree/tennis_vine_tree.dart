import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/skill_tree.dart';
import '../../providers/skill_tree_provider.dart';

class TennisVineTree extends StatelessWidget {
  final SkillTreeProvider provider;
  final Set<String> favoriteVocabIds;

  const TennisVineTree({
    super.key,
    required this.provider,
    this.favoriteVocabIds = const {},
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...provider.branches.map(
          (branch) => _BranchSection(
            branch: branch,
            provider: provider,
            favoriteCount: favoriteVocabIds.length,
          ),
        ),
      ],
    );
  }
}

class _BranchSection extends StatefulWidget {
  final SkillBranch branch;
  final SkillTreeProvider provider;
  final int favoriteCount;

  const _BranchSection({
    required this.branch,
    required this.provider,
    required this.favoriteCount,
  });

  @override
  State<_BranchSection> createState() => _BranchSectionState();
}

class _BranchSectionState extends State<_BranchSection>
    with TickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final branch = widget.branch;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: TennisColors.cardGradient,
          borderRadius: BorderRadius.circular(TennisTheme.radiusMD),
          border: Border.all(
            color: TennisColors.voltGreen.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Branch header
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: TennisColors.voltGradient,
                  ),
                  child: Icon(
                    _branchIcon(branch.id),
                    size: 18,
                    color: TennisColors.deepPurple,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  branch.nameKey,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: TennisColors.voltGreen,
                  ),
                ),
                const Spacer(),
                Text(
                  '${branch.average.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: TennisColors.lavender.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Leaves
            ...branch.leaves.map((leaf) => _LeafSlider(
                  leaf: leaf,
                  branchId: branch.id,
                  provider: widget.provider,
                  onChanged: () {
                    _glowController.forward().then((_) {
                      _glowController.reverse();
                    });
                  },
                )),

            // Vine connector with fruits
            if (widget.favoriteCount > 0) _FruitVine(count: widget.favoriteCount),
          ],
        ),
      ),
    );
  }

  IconData _branchIcon(String id) {
    return switch (id) {
      'baseline' => Icons.swap_horiz_rounded,
      'net_play' => Icons.height_rounded,
      'serve_return' => Icons.sports_tennis,
      _ => Icons.circle,
    };
  }
}

class _LeafSlider extends StatefulWidget {
  final SkillLeaf leaf;
  final String branchId;
  final SkillTreeProvider provider;
  final VoidCallback onChanged;

  const _LeafSlider({
    required this.leaf,
    required this.branchId,
    required this.provider,
    required this.onChanged,
  });

  @override
  State<_LeafSlider> createState() => _LeafSliderState();
}

class _LeafSliderState extends State<_LeafSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _leafController;

  @override
  void initState() {
    super.initState();
    _leafController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _leafController.value = (widget.leaf.level - 1) / 9;
  }

  @override
  void didUpdateWidget(_LeafSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.leaf.level != widget.leaf.level) {
      _leafController.animateTo(
        (widget.leaf.level - 1) / 9,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
      );
    }
  }

  @override
  void dispose() {
    _leafController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leaf = widget.leaf;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              leaf.nameKey,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: TennisColors.lavenderLight.withValues(alpha: 0.85),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                // Track
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: TennisColors.lavender.withValues(alpha: 0.15),
                    borderRadius:
                        BorderRadius.circular(TennisTheme.radiusFull),
                  ),
                ),
                // Filled track
                AnimatedBuilder(
                  animation: _leafController,
                  builder: (context, child) {
                    return FractionallySizedBox(
                      widthFactor: _leafController.value,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              TennisColors.voltGreen,
                              TennisColors.voltGreenDark,
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(TennisTheme.radiusFull),
                          boxShadow: [
                            BoxShadow(
                              color: TennisColors.voltGreen.withValues(alpha: 
                                0.3 + _leafController.value * 0.4,
                              ),
                              blurRadius: 6 + _leafController.value * 8,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                // Slider
                Positioned.fill(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 6,
                      thumbShape: _LeafThumbShape(
                        controller: _leafController,
                      ),
                      overlayShape: SliderComponentShape.noOverlay,
                      activeTrackColor: Colors.transparent,
                      inactiveTrackColor: Colors.transparent,
                      thumbColor: Colors.transparent,
                    ),
                    child: Slider(
                      value: leaf.level,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      onChanged: (v) {
                        widget.provider.setLeafLevel(
                            widget.branchId, leaf.id, v);
                        widget.onChanged();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 28,
            child: Text(
              '${leaf.level.toInt()}',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: TennisColors.voltGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeafThumbShape extends SliderComponentShape {
  final AnimationController controller;

  const _LeafThumbShape({required this.controller});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size(22, 22);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    // Outer glow
    final glowPaint = Paint()
      ..color = TennisColors.voltGreen.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(center, 11, glowPaint);

    // Leaf shape (simplified as circle with tint)
    final leafPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          TennisColors.voltGreenLight,
          TennisColors.voltGreen,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 9));
    canvas.drawCircle(center, 9, leafPaint);

    // Inner dot
    final dotPaint = Paint()..color = TennisColors.deepPurple.withValues(alpha: 0.4);
    canvas.drawCircle(center, 3, dotPaint);
  }
}

class _FruitVine extends StatelessWidget {
  final int count;

  const _FruitVine({required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(Icons.eco, size: 14, color: TennisColors.voltGreen.withValues(alpha: 0.5)),
          const SizedBox(width: 6),
          ...List.generate(
            count.clamp(0, 8),
            (i) => Padding(
              padding: const EdgeInsets.only(right: 4),
              child: const Text('⭐', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$count vocab fruits',
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: TennisColors.lavender.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
