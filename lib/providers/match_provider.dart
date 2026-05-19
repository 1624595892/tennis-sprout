import 'package:flutter/material.dart';
import '../models/match_record.dart';

class MatchProvider extends ChangeNotifier {
  final List<MatchRecord> _records = [];

  List<MatchRecord> get records => List.unmodifiable(_records);

  int get totalMatches => _records.length;
  int get wins => _records.where((r) => r.isWin).length;
  int get losses => _records.where((r) => !r.isWin).length;

  double get winRate {
    if (_records.isEmpty) return 0;
    return wins / _records.length * 100;
  }

  int get totalWinners =>
      _records.fold(0, (sum, r) => sum + r.winners);
  int get totalUE =>
      _records.fold(0, (sum, r) => sum + r.unforcedErrors);
  int get totalDF =>
      _records.fold(0, (sum, r) => sum + r.doubleFaults);

  void addRecord(MatchRecord record) {
    _records.insert(0, record);
    notifyListeners();
  }

  void updateRecord(String id, MatchRecord updated) {
    final idx = _records.indexWhere((r) => r.id == id);
    if (idx >= 0) {
      _records[idx] = updated;
      notifyListeners();
    }
  }

  void deleteRecord(String id) {
    _records.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  void attachCoachFeedback(String recordId, String feedbackId) {
    final idx = _records.indexWhere((r) => r.id == recordId);
    if (idx >= 0) {
      _records[idx] = _records[idx].copyWith(coachFeedbackId: feedbackId);
      notifyListeners();
    }
  }
}
