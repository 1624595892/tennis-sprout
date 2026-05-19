import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/vocabulary.dart';
import 'pronunciation_button.dart';

class VocabFlipCard extends StatefulWidget {
  final TennisVocabulary vocab;
  final bool isZh;
  final bool isFavorited;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onPlayPronunciation;

  const VocabFlipCard({
    super.key,
    required this.vocab,
    required this.isZh,
    required this.isFavorited,
    required this.onFavoriteToggle,
    required this.onPlayPronunciation,
  });

  @override
  State<VocabFlipCard> createState() => _VocabFlipCardState();
}

class _VocabFlipCardState extends State<VocabFlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => _isFront = !_isFront);
  }

  @override
  Widget build(BuildContext context) {
    final isZh = widget.isZh;
    final v = widget.vocab;

    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * math.pi;
          final showFront = _animation.value < 0.5;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002)
              ..rotateY(angle),
            child: showFront
                ? _buildFront(isZh, v)
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _buildBack(isZh, v),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildFront(bool isZh, TennisVocabulary v) {
    return Container(
      height: 360,
      decoration: BoxDecoration(
        gradient: TennisColors.cardGradient,
        borderRadius: BorderRadius.circular(TennisTheme.radiusLG),
        boxShadow: [
          BoxShadow(
            color: TennisColors.deepPurple.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: TennisColors.voltGreen.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: TennisColors.lavender.withValues(alpha: 0.2),
                    border: Border.all(
                      color: TennisColors.voltGreen.withValues(alpha: 0.4),
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    _categoryIcon(v.category),
                    size: 60,
                    color: TennisColors.voltGreen,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  v.wordEn,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: TennisColors.voltGreen,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  v.wordZh,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: TennisColors.lavenderLight,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                isZh ? '点击翻转卡片 👆' : 'Tap to flip 👆',
                style: TextStyle(
                  fontSize: 11,
                  color: TennisColors.lavender.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBack(bool isZh, TennisVocabulary v) {
    return Container(
      height: 360,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: TennisColors.cardGradient,
        borderRadius: BorderRadius.circular(TennisTheme.radiusLG),
        boxShadow: [
          BoxShadow(
            color: TennisColors.deepPurple.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: TennisColors.voltGreen.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        v.wordZh,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: TennisColors.voltGreen,
                        ),
                      ),
                      Text(
                        v.wordEn,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: TennisColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    PronunciationButton(
                      onTap: widget.onPlayPronunciation,
                    ),
                    const SizedBox(width: 8),
                    _FavoriteStar(
                      isFavorited: widget.isFavorited,
                      onTap: widget.onFavoriteToggle,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionTitle(
              label: isZh ? '技术原理' : 'How It Works',
              icon: Icons.lightbulb_outline,
            ),
            const SizedBox(height: 6),
            Text(
              v.principle(isZh),
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: TennisColors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 16),
            _SectionTitle(
              label: isZh ? '趣味小知识' : 'Trivia',
              icon: Icons.emoji_events_outlined,
            ),
            const SizedBox(height: 6),
            Text(
              v.trivia(isZh),
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: TennisColors.voltGreenLight.withValues(alpha: 0.95),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                isZh ? '再次点击翻回 👆' : 'Tap to flip back 👆',
                style: TextStyle(
                  fontSize: 11,
                  color: TennisColors.lavender.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(VocabCategory cat) {
    return switch (cat) {
      VocabCategory.technique => Icons.sports_tennis,
      VocabCategory.tactics => Icons.psychology,
      VocabCategory.rules => Icons.gavel,
      VocabCategory.equipment => Icons.build,
      VocabCategory.culture => Icons.public,
    };
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SectionTitle({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: TennisColors.voltGreen),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: TennisColors.voltGreen,
          ),
        ),
      ],
    );
  }
}

class _FavoriteStar extends StatelessWidget {
  final bool isFavorited;
  final VoidCallback onTap;

  const _FavoriteStar({required this.isFavorited, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: Icon(
          isFavorited ? Icons.star : Icons.star_border,
          color: isFavorited
              ? const Color(0xFFFFD700)
              : TennisColors.lavender.withValues(alpha: 0.6),
          size: 32,
        ),
      ),
    );
  }
}
