class CoachFeedback {
  final String id;
  final String coachId;
  final String coachName;
  final String? audioPath;
  final String? transcriptText;
  final Duration? audioDuration;
  final List<TimedComment> timedComments;
  final DateTime createdAt;
  final FeedbackType type;
  final String? relatedLogId; // links to PracticeLog or MatchRecord

  CoachFeedback({
    required this.id,
    required this.coachId,
    required this.coachName,
    this.audioPath,
    this.transcriptText,
    this.audioDuration,
    this.timedComments = const [],
    DateTime? createdAt,
    this.type = FeedbackType.general,
    this.relatedLogId,
  }) : createdAt = createdAt ?? DateTime.now();
}

class TimedComment {
  final Duration videoTimestamp;
  final String audioPath;
  final String? transcriptText;
  final Duration audioDuration;

  TimedComment({
    required this.videoTimestamp,
    required this.audioPath,
    this.transcriptText,
    required this.audioDuration,
  });
}

class CoachBinding {
  final String coachId;
  final String coachName;
  final String? coachAvatarUrl;

  CoachBinding({
    required this.coachId,
    required this.coachName,
    this.coachAvatarUrl,
  });
}

enum FeedbackType {
  general,
  technique, // for practice logs
  tactics, // for match records
  mental,
}
