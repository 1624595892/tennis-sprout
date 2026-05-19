class MatchRecord {
  final String id;
  final String opponentName;
  final String scoreDisplay;
  final int gamesWon;
  final int gamesLost;
  final CourtSurface surface;
  final int winners;
  final int unforcedErrors;
  final int doubleFaults;
  final DateTime playedAt;
  final bool isWin;
  final String? coachFeedbackId;

  MatchRecord({
    required this.id,
    required this.opponentName,
    required this.scoreDisplay,
    required this.gamesWon,
    required this.gamesLost,
    required this.surface,
    this.winners = 0,
    this.unforcedErrors = 0,
    this.doubleFaults = 0,
    DateTime? playedAt,
    this.coachFeedbackId,
  })  : isWin = gamesWon > gamesLost,
        playedAt = playedAt ?? DateTime.now();

  MatchRecord copyWith({
    String? id,
    String? opponentName,
    String? scoreDisplay,
    int? gamesWon,
    int? gamesLost,
    CourtSurface? surface,
    int? winners,
    int? unforcedErrors,
    int? doubleFaults,
    DateTime? playedAt,
    String? coachFeedbackId,
  }) {
    return MatchRecord(
      id: id ?? this.id,
      opponentName: opponentName ?? this.opponentName,
      scoreDisplay: scoreDisplay ?? this.scoreDisplay,
      gamesWon: gamesWon ?? this.gamesWon,
      gamesLost: gamesLost ?? this.gamesLost,
      surface: surface ?? this.surface,
      winners: winners ?? this.winners,
      unforcedErrors: unforcedErrors ?? this.unforcedErrors,
      doubleFaults: doubleFaults ?? this.doubleFaults,
      playedAt: playedAt ?? this.playedAt,
      coachFeedbackId: coachFeedbackId ?? this.coachFeedbackId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'opponentName': opponentName,
    'scoreDisplay': scoreDisplay,
    'gamesWon': gamesWon,
    'gamesLost': gamesLost,
    'surface': surface.name,
    'winners': winners,
    'unforcedErrors': unforcedErrors,
    'doubleFaults': doubleFaults,
    'playedAt': playedAt.toIso8601String(),
    'coachFeedbackId': coachFeedbackId,
  };

  factory MatchRecord.fromJson(Map<String, dynamic> json) => MatchRecord(
    id: json['id'],
    opponentName: json['opponentName'],
    scoreDisplay: json['scoreDisplay'],
    gamesWon: json['gamesWon'],
    gamesLost: json['gamesLost'],
    surface: CourtSurface.values.firstWhere((s) => s.name == json['surface']),
    winners: json['winners'] ?? 0,
    unforcedErrors: json['unforcedErrors'] ?? 0,
    doubleFaults: json['doubleFaults'] ?? 0,
    playedAt: DateTime.parse(json['playedAt']),
    coachFeedbackId: json['coachFeedbackId'],
  );
}

enum CourtSurface {
  grass,
  clay,
  hard;

  String get displayKey => switch (this) {
    grass => 'grass',
    clay => 'clay',
    hard => 'hard',
  };

  String get emoji => switch (this) {
    grass => '🌿',
    clay => '🧱',
    hard => '💙',
  };
}
