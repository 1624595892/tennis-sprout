import 'package:flutter/material.dart';
import '../models/practice_log.dart';

class PracticeProvider extends ChangeNotifier {
  final List<PracticeLog> _logs = [];

  List<PracticeLog> get logs => List.unmodifiable(_logs);
  List<PracticeLog> get recentLogs =>
      _logs.take(10).toList();

  int get totalMinutes =>
      _logs.fold(0, (sum, log) => sum + log.durationMinutes);

  double get averageRating {
    if (_logs.isEmpty) return 0;
    return _logs.fold(0.0, (sum, log) => sum + log.selfRating) / _logs.length;
  }

  void addLog(PracticeLog log) {
    _logs.insert(0, log);
    notifyListeners();
  }

  void updateLog(String id, PracticeLog updated) {
    final idx = _logs.indexWhere((l) => l.id == id);
    if (idx >= 0) {
      _logs[idx] = updated;
      notifyListeners();
    }
  }

  void deleteLog(String id) {
    _logs.removeWhere((l) => l.id == id);
    notifyListeners();
  }

  void attachCoachFeedback(String logId, String feedbackId) {
    final idx = _logs.indexWhere((l) => l.id == logId);
    if (idx >= 0) {
      _logs[idx] = _logs[idx].copyWith(coachFeedbackId: feedbackId);
      notifyListeners();
    }
  }
}
