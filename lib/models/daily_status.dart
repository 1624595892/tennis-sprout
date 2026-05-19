import 'dart:typed_data';

class DailyStatus {
  final DateTime date;
  final String? photoPath;
  final Uint8List? imageBytes;
  final bool isLivePhoto;
  final Mood mood;
  final bool checkedIn;

  DailyStatus({
    required this.date,
    this.photoPath,
    this.imageBytes,
    this.isLivePhoto = false,
    this.mood = Mood.good,
    this.checkedIn = false,
  });

  DailyStatus copyWith({
    DateTime? date,
    String? photoPath,
    Uint8List? imageBytes,
    bool? isLivePhoto,
    Mood? mood,
    bool? checkedIn,
  }) {
    return DailyStatus(
      date: date ?? this.date,
      photoPath: photoPath ?? this.photoPath,
      imageBytes: imageBytes ?? this.imageBytes,
      isLivePhoto: isLivePhoto ?? this.isLivePhoto,
      mood: mood ?? this.mood,
      checkedIn: checkedIn ?? this.checkedIn,
    );
  }
}

class StreakData {
  final int currentStreak;
  final int longestStreak;
  final DateTime lastCheckIn;

  StreakData({
    this.currentStreak = 0,
    this.longestStreak = 0,
    DateTime? lastCheckIn,
  }) : lastCheckIn = lastCheckIn ?? DateTime(2000);
}

enum Mood {
  happy,
  good,
  ok,
  tired;

  String get emoji => switch (this) {
    happy => '🤩',
    good => '😊',
    ok => '😐',
    tired => '😮‍💨',
  };

  String get key => switch (this) {
    happy => 'mood_happy',
    good => 'mood_good',
    ok => 'mood_ok',
    tired => 'mood_tired',
  };
}
