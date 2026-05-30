import 'dart:typed_data';

class FrameAnnotation {
  final Duration timestamp;
  final String label;
  final double x; // 0.0–1.0 relative position on frame
  final double y;

  const FrameAnnotation({
    required this.timestamp,
    required this.label,
    required this.x,
    required this.y,
  });

  Map<String, dynamic> toJson() => {
        'timestampMs': timestamp.inMilliseconds,
        'label': label,
        'x': x,
        'y': y,
      };

  factory FrameAnnotation.fromJson(Map<String, dynamic> json) => FrameAnnotation(
        timestamp: Duration(milliseconds: json['timestampMs']),
        label: json['label'],
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
      );
}

class PracticeLog {
  static DateTime _dateOnly(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  final String id;
  final String drillType;
  final int durationMinutes;
  final double selfRating; // 1-10 legacy
  final String notes;
  final String? videoPath;
  final String? imagePath;
  final Uint8List? videoBytes;
  final DateTime date; // date-only, stripped to day precision
  final DateTime createdAt;
  final String? coachFeedbackId;

  // ── New fields ──
  final List<String> subjectTags;
  final int starRating; // 1–5 tennis-ball stars
  final bool isReviewedByCoach;
  final String? coachName;
  final String? coachAvatar;
  final String? coachAudioPath;
  final List<FrameAnnotation> frameAnnotations;

  PracticeLog({
    required this.id,
    required this.drillType,
    required this.durationMinutes,
    required this.selfRating,
    required this.notes,
    this.videoPath,
    this.imagePath,
    this.videoBytes,
    DateTime? date,
    DateTime? createdAt,
    this.coachFeedbackId,
    this.subjectTags = const [],
    this.starRating = 3,
    this.isReviewedByCoach = false,
    this.coachName,
    this.coachAvatar,
    this.coachAudioPath,
    this.frameAnnotations = const [],
  }) : date = _dateOnly(date ?? DateTime.now()),
        createdAt = createdAt ?? DateTime.now();

  PracticeLog copyWith({
    String? id,
    String? drillType,
    int? durationMinutes,
    double? selfRating,
    String? notes,
    String? videoPath,
    String? imagePath,
    Uint8List? videoBytes,
    DateTime? date,
    DateTime? createdAt,
    String? coachFeedbackId,
    List<String>? subjectTags,
    int? starRating,
    bool? isReviewedByCoach,
    String? coachName,
    String? coachAvatar,
    String? coachAudioPath,
    List<FrameAnnotation>? frameAnnotations,
  }) {
    return PracticeLog(
      id: id ?? this.id,
      drillType: drillType ?? this.drillType,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      selfRating: selfRating ?? this.selfRating,
      notes: notes ?? this.notes,
      videoPath: videoPath ?? this.videoPath,
      imagePath: imagePath ?? this.imagePath,
      videoBytes: videoBytes ?? this.videoBytes,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      coachFeedbackId: coachFeedbackId ?? this.coachFeedbackId,
      subjectTags: subjectTags ?? this.subjectTags,
      starRating: starRating ?? this.starRating,
      isReviewedByCoach: isReviewedByCoach ?? this.isReviewedByCoach,
      coachName: coachName ?? this.coachName,
      coachAvatar: coachAvatar ?? this.coachAvatar,
      coachAudioPath: coachAudioPath ?? this.coachAudioPath,
      frameAnnotations: frameAnnotations ?? this.frameAnnotations,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'drillType': drillType,
        'durationMinutes': durationMinutes,
        'selfRating': selfRating,
        'notes': notes,
        'videoPath': videoPath,
        'imagePath': imagePath,
        'date': date.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'coachFeedbackId': coachFeedbackId,
        'subjectTags': subjectTags,
        'starRating': starRating,
        'isReviewedByCoach': isReviewedByCoach,
        'coachName': coachName,
        'coachAvatar': coachAvatar,
        'coachAudioPath': coachAudioPath,
        'frameAnnotations': frameAnnotations.map((a) => a.toJson()).toList(),
      };

  factory PracticeLog.fromJson(Map<String, dynamic> json) => PracticeLog(
        id: json['id'],
        drillType: json['drillType'],
        durationMinutes: json['durationMinutes'],
        selfRating: (json['selfRating'] as num).toDouble(),
        notes: json['notes'] ?? '',
        videoPath: json['videoPath'],
        imagePath: json['imagePath'],
        date: json['date'] != null ? DateTime.parse(json['date']) : null,
        createdAt: DateTime.parse(json['createdAt']),
        coachFeedbackId: json['coachFeedbackId'],
        subjectTags: (json['subjectTags'] as List<dynamic>?)?.cast<String>() ?? [],
        starRating: json['starRating'] ?? 3,
        isReviewedByCoach: json['isReviewedByCoach'] ?? false,
        coachName: json['coachName'],
        coachAvatar: json['coachAvatar'],
        coachAudioPath: json['coachAudioPath'],
        frameAnnotations: (json['frameAnnotations'] as List<dynamic>?)
                ?.map((a) => FrameAnnotation.fromJson(a))
                .toList() ??
            [],
      );
}
