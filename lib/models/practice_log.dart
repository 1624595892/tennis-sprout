class PracticeLog {
  final String id;
  final String drillType;
  final int durationMinutes;
  final double selfRating; // 1-10
  final String notes;
  final String? videoPath;
  final DateTime createdAt;
  final String? coachFeedbackId;

  PracticeLog({
    required this.id,
    required this.drillType,
    required this.durationMinutes,
    required this.selfRating,
    required this.notes,
    this.videoPath,
    DateTime? createdAt,
    this.coachFeedbackId,
  }) : createdAt = createdAt ?? DateTime.now();

  PracticeLog copyWith({
    String? id,
    String? drillType,
    int? durationMinutes,
    double? selfRating,
    String? notes,
    String? videoPath,
    DateTime? createdAt,
    String? coachFeedbackId,
  }) {
    return PracticeLog(
      id: id ?? this.id,
      drillType: drillType ?? this.drillType,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      selfRating: selfRating ?? this.selfRating,
      notes: notes ?? this.notes,
      videoPath: videoPath ?? this.videoPath,
      createdAt: createdAt ?? this.createdAt,
      coachFeedbackId: coachFeedbackId ?? this.coachFeedbackId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'drillType': drillType,
    'durationMinutes': durationMinutes,
    'selfRating': selfRating,
    'notes': notes,
    'videoPath': videoPath,
    'createdAt': createdAt.toIso8601String(),
    'coachFeedbackId': coachFeedbackId,
  };

  factory PracticeLog.fromJson(Map<String, dynamic> json) => PracticeLog(
    id: json['id'],
    drillType: json['drillType'],
    durationMinutes: json['durationMinutes'],
    selfRating: (json['selfRating'] as num).toDouble(),
    notes: json['notes'] ?? '',
    videoPath: json['videoPath'],
    createdAt: DateTime.parse(json['createdAt']),
    coachFeedbackId: json['coachFeedbackId'],
  );
}
