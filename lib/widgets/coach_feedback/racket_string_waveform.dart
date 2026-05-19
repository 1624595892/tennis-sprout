import 'dart:math';
import 'package:flutter/material.dart';
import '../../config/theme.dart';

class RacketStringWaveform extends StatefulWidget {
  final bool isPlaying;
  final double progress; // 0.0 - 1.0
  final Duration currentTime;
  final Duration totalDuration;
  final VoidCallback onPlayPause;
  final String? coachName;
  final String? transcriptText;
  final bool showTranscript;

  const RacketStringWaveform({
    super.key,
    required this.isPlaying,
    required this.progress,
    required this.currentTime,
    required this.totalDuration,
    required this.onPlayPause,
    this.coachName,
    this.transcriptText,
    this.showTranscript = false,
  });

  @override
  State<RacketStringWaveform> createState() => _RacketStringWaveformState();
}

class _RacketStringWaveformState extends State<RacketStringWaveform>
    with TickerProviderStateMixin {
  late AnimationController _ballController;
  late AnimationController _waveController;
  final List<double> _barHeights = [];
  static const int barCount = 28;

  @override
  void initState() {
    super.initState();
    _ballController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    final rand = Random(42);
    for (int i = 0; i < barCount; i++) {
      _barHeights.add(0.2 + rand.nextDouble() * 0.6);
    }

    if (widget.isPlaying) {
      _ballController.repeat();
    }
  }

  @override
  void didUpdateWidget(RacketStringWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _ballController.repeat();
      _waveController.repeat(reverse: true);
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _ballController.stop();
      _waveController.stop();
      _waveController.reset();
    }
  }

  @override
  void dispose() {
    _ballController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PurpleWaveformCard(
      coachName: widget.coachName,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Waveform visualization
          SizedBox(
            height: 80,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final barWidth =
                    (constraints.maxWidth - (barCount - 1) * 3) / barCount;
                return Stack(
                  children: [
                    // Bars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: List.generate(barCount, (i) {
                        return _WaveBar(
                          height: _barHeights[i] * 64,
                          width: max(barWidth, 3),
                          isActive: widget.progress > (i / barCount),
                          waveValue: _waveController,
                        );
                      }),
                    ),
                    // Rolling tennis ball
                    AnimatedBuilder(
                      animation: _ballController,
                      builder: (context, child) {
                        final ballX = widget.progress *
                            (constraints.maxWidth - 24);
                        final playHeadX =
                            widget.progress * constraints.maxWidth;
                        return Stack(
                          children: [
                            // Playhead line
                            Positioned(
                              left: playHeadX - 1,
                              top: 0,
                              bottom: 0,
                              child: Container(
                                width: 2,
                                color: TennisColors.voltGreen,
                              ),
                            ),
                            // Ball
                            Positioned(
                              left: ballX,
                              top: 28,
                              child: const _TennisBall(size: 24),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Controls & timestamp
          Row(
            children: [
              // Play/Pause
              GestureDetector(
                onTap: widget.onPlayPause,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isPlaying
                        ? TennisColors.voltGreen.withValues(alpha: 0.2)
                        : TennisColors.voltGreen,
                  ),
                  child: Icon(
                    widget.isPlaying ? Icons.pause : Icons.play_arrow_rounded,
                    color: widget.isPlaying
                        ? TennisColors.voltGreen
                        : TennisColors.deepPurple,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Time
              Text(
                '${_formatDuration(widget.currentTime)} / ${_formatDuration(widget.totalDuration)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: TennisColors.lavender.withValues(alpha: 0.7),
                ),
              ),
              const Spacer(),

              // Speed indicator
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: TennisColors.voltGreen.withValues(alpha: 0.15),
                  borderRadius:
                      BorderRadius.circular(TennisTheme.radiusFull),
                ),
                child: const Text(
                  '1×',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: TennisColors.voltGreen,
                  ),
                ),
              ),
            ],
          ),

          // Transcript (collapsible)
          if (widget.showTranscript && widget.transcriptText != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: TennisColors.deepPurple.withValues(alpha: 0.3),
                borderRadius:
                    BorderRadius.circular(TennisTheme.radiusSM),
              ),
              child: Text(
                widget.transcriptText!,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: TennisColors.lavenderLight,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class PurpleWaveformCard extends StatelessWidget {
  final String? coachName;
  final Widget child;

  const PurpleWaveformCard({super.key, this.coachName, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: TennisColors.cardGradient,
        borderRadius: BorderRadius.circular(TennisTheme.radiusMD),
        boxShadow: [
          BoxShadow(
            color: TennisColors.deepPurple.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: TennisColors.voltGreen.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (coachName != null) ...[
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: TennisColors.voltGradient,
                  ),
                  child: const Icon(Icons.person, size: 16, color: TennisColors.deepPurple),
                ),
                const SizedBox(width: 8),
                Text(
                  coachName!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: TennisColors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}

class _WaveBar extends StatelessWidget {
  final double height;
  final double width;
  final bool isActive;
  final AnimationController waveValue;

  const _WaveBar({
    required this.height,
    required this.width,
    required this.isActive,
    required this.waveValue,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: waveValue,
      builder: (context, child) {
        final animatedHeight = waveValue.isAnimating
            ? height * (0.5 + waveValue.value * 1.0)
            : height;
        return Container(
          width: max(width, 2.5),
          height: animatedHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(TennisTheme.radiusFull),
            color: isActive
                ? TennisColors.voltGreen
                : TennisColors.lavender.withValues(alpha: 0.3),
          ),
        );
      },
    );
  }
}

class _TennisBall extends StatelessWidget {
  final double size;
  const _TennisBall({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [TennisColors.voltGreenLight, TennisColors.voltGreen],
        ),
        boxShadow: [
          BoxShadow(
            color: TennisColors.voltGreen.withValues(alpha: 0.5),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.35,
          height: size * 0.35,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: TennisColors.deepPurple.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
