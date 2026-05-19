import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/coach_feedback.dart';
import '../../providers/coach_provider.dart';
import '../common/volt_button.dart';
import 'racket_string_waveform.dart';

class CoachFeedbackWidget extends StatefulWidget {
  final CoachProvider coachProvider;
  final String? logId; // Practice log or match record ID
  final VoidCallback? onSendToCoach;

  const CoachFeedbackWidget({
    super.key,
    required this.coachProvider,
    this.logId,
    this.onSendToCoach,
  });

  @override
  State<CoachFeedbackWidget> createState() => _CoachFeedbackWidgetState();
}

class _CoachFeedbackWidgetState extends State<CoachFeedbackWidget> {
  bool _showTranscript = false;
  bool _isPlaying = false;
  double _playbackProgress = 0.0;

  List<CoachFeedback> get _relevantFeedbacks {
    if (widget.logId == null) return widget.coachProvider.feedbacks;
    return widget.coachProvider.getFeedbacksForLog(widget.logId!);
  }

  @override
  Widget build(BuildContext context) {
    final isBound = widget.coachProvider.isBound;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section header
        Row(
          children: [
            const Icon(Icons.headset_mic, size: 20, color: TennisColors.voltGreen),
            const SizedBox(width: 8),
            const Text(
              'Coach Feedback',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: TennisColors.white,
              ),
            ),
            const Spacer(),
            if (isBound && widget.onSendToCoach != null)
              VoltButton(
                label: 'Send to Coach',
                onPressed: widget.onSendToCoach,
                icon: Icons.send_rounded,
                compact: true,
              ),
          ],
        ),
        const SizedBox(height: 12),

        if (!isBound)
          _buildNotBound(context)
        else if (_relevantFeedbacks.isEmpty)
          _buildWaitingFeedback()
        else
          ..._relevantFeedbacks.map(_buildFeedbackItem),
      ],
    );
  }

  Widget _buildNotBound(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: TennisColors.deepPurple.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(TennisTheme.radiusMD),
        border: Border.all(
          color: TennisColors.lavender.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.link_off,
            size: 40,
            color: TennisColors.lavender.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No coach bound yet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: TennisColors.lavender.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          VoltButton(
            label: 'Bind Coach',
            onPressed: () {
              Navigator.pushNamed(context, '/coach-binding');
            },
            compact: true,
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingFeedback() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TennisColors.lavender.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(TennisTheme.radiusMD),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: TennisColors.voltGreen,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Waiting for coach feedback...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: TennisColors.lavender.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackItem(CoachFeedback feedback) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RacketStringWaveform(
        isPlaying: _isPlaying,
        progress: _playbackProgress,
        currentTime: Duration(
          milliseconds:
              (feedback.audioDuration!.inMilliseconds * _playbackProgress)
                  .round(),
        ),
        totalDuration: feedback.audioDuration ?? const Duration(seconds: 30),
        onPlayPause: () {
          setState(() => _isPlaying = !_isPlaying);
          if (_isPlaying) {
            // Mock playback simulation
          }
        },
        coachName: feedback.coachName,
        transcriptText: feedback.transcriptText,
        showTranscript: _showTranscript,
      ),
    );
  }
}
