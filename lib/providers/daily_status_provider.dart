import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../models/daily_status.dart';

class DailyStatusProvider extends ChangeNotifier {
  final List<DailyStatus> _history = [];
  StreakData _streak = StreakData();

  List<DailyStatus> get history => _history;
  StreakData get streak => _streak;

  DailyStatus? get todayStatus {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    try {
      return _history.firstWhere(
        (s) =>
            s.date.year == today.year &&
            s.date.month == today.month &&
            s.date.day == today.day,
      );
    } catch (_) {
      return null;
    }
  }

  bool get hasCheckedInToday => todayStatus?.checkedIn ?? false;

  void checkIn({String? photoPath, Uint8List? imageBytes, bool isLivePhoto = false, Mood mood = Mood.good}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final existingIdx = _history.indexWhere(
      (s) =>
          s.date.year == today.year &&
          s.date.month == today.month &&
          s.date.day == today.day,
    );

    final status = DailyStatus(
      date: today,
      photoPath: photoPath,
      imageBytes: imageBytes,
      isLivePhoto: isLivePhoto,
      mood: mood,
      checkedIn: true,
    );

    if (existingIdx >= 0) {
      _history[existingIdx] = status;
    } else {
      _history.add(status);
    }

    _updateStreak();
    notifyListeners();
  }

  void _updateStreak() {
    // Simple streak calculation
    int streak = 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (int i = 0; i < 365; i++) {
      final checkDate = today.subtract(Duration(days: i));
      final hasCheckIn = _history.any(
        (s) =>
            s.date.year == checkDate.year &&
            s.date.month == checkDate.month &&
            s.date.day == checkDate.day &&
            s.checkedIn,
      );
      if (hasCheckIn) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }

    _streak = StreakData(
      currentStreak: streak,
      longestStreak: streak > _streak.longestStreak ? streak : _streak.longestStreak,
      lastCheckIn: today,
    );
  }
}
