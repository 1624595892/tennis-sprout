import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/practice_log.dart';
import '../utils/time_lock_helper.dart';

class PracticeProvider extends ChangeNotifier {
  static const _kLogIdsKey = 'practice_log_ids';

  final List<PracticeLog> _logs = [];
  final Map<String, List<String>> _dateIndex = {};
  bool _loaded = false;

  // ── Accessors ──

  List<PracticeLog> get logs => List.unmodifiable(_logs);
  List<PracticeLog> get recentLogs => _logs.take(10).toList();

  int get totalMinutes =>
      _logs.fold(0, (sum, log) => sum + log.durationMinutes);

  double get averageRating {
    if (_logs.isEmpty) return 0;
    return _logs.fold(0.0, (sum, log) => sum + log.selfRating) / _logs.length;
  }

  Set<String> get loggedDates => Set.unmodifiable(_dateIndex.keys);

  bool hasLogOnDate(DateTime date) {
    return _dateIndex.containsKey(TimeLockHelper.dateKey(date));
  }

  // ── Persistence ──

  /// Load all logs from shared_preferences. Call once at app start.
  Future<void> loadFromDisk() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_kLogIdsKey) ?? [];

    for (final id in ids) {
      final raw = prefs.getString('practice_log_$id');
      if (raw == null) continue;
      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        final log = PracticeLog.fromJson(json);
        _logs.add(log);
        final key = TimeLockHelper.dateKey(log.date);
        _dateIndex.putIfAbsent(key, () => []).add(log.id);
      } catch (_) {
        // Skip corrupted entries
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = _logs.map((l) => l.id).toList();
    await prefs.setStringList(_kLogIdsKey, ids);
    for (final log in _logs) {
      await prefs.setString('practice_log_${log.id}', jsonEncode(log.toJson()));
    }
  }

  Future<void> _removeFromDisk(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('practice_log_$id');
    final ids = _logs.map((l) => l.id).toList();
    await prefs.setStringList(_kLogIdsKey, ids);
  }

  // ── Date-keyed API ──

  List<PracticeLog> getLogsForDate(DateTime date) {
    final key = TimeLockHelper.dateKey(date);
    final ids = _dateIndex[key];
    if (ids == null || ids.isEmpty) return [];
    return _logs.where((l) => ids.contains(l.id)).toList();
  }

  PracticeLog? getLogByDate(DateTime date) {
    final logs = getLogsForDate(date);
    return logs.isEmpty ? null : logs.first;
  }

  bool saveLogForDate(PracticeLog log) {
    if (!TimeLockHelper.isEditable(log.date)) return false;

    final key = TimeLockHelper.dateKey(log.date);
    final existingIdx = _logs.indexWhere((l) => l.id == log.id);
    if (existingIdx >= 0) {
      _logs[existingIdx] = log;
    } else {
      _logs.insert(0, log);
      _dateIndex.putIfAbsent(key, () => []).add(log.id);
    }
    notifyListeners();
    _persist();
    return true;
  }

  bool deleteLogForDate(String logId) {
    final idx = _logs.indexWhere((l) => l.id == logId);
    if (idx < 0) return false;

    final log = _logs[idx];
    if (!TimeLockHelper.isEditable(log.date)) return false;

    final key = TimeLockHelper.dateKey(log.date);
    _dateIndex[key]?.remove(log.id);
    if (_dateIndex[key]?.isEmpty == true) _dateIndex.remove(key);

    _logs.removeAt(idx);
    notifyListeners();
    _removeFromDisk(logId);
    return true;
  }

  // ── Legacy API ──

  void addLog(PracticeLog log) {
    _logs.insert(0, log);
    final key = TimeLockHelper.dateKey(log.date);
    _dateIndex.putIfAbsent(key, () => []).add(log.id);
    notifyListeners();
    _persist();
  }

  void updateLog(String id, PracticeLog updated) {
    final idx = _logs.indexWhere((l) => l.id == id);
    if (idx >= 0) {
      _logs[idx] = updated;
      notifyListeners();
      _persist();
    }
  }

  void deleteLog(String id) {
    final idx = _logs.indexWhere((l) => l.id == id);
    if (idx >= 0) {
      final key = TimeLockHelper.dateKey(_logs[idx].date);
      _dateIndex[key]?.remove(id);
      if (_dateIndex[key]?.isEmpty == true) _dateIndex.remove(key);
      _logs.removeAt(idx);
      notifyListeners();
      _removeFromDisk(id);
    }
  }

  void attachCoachFeedback(String logId, String feedbackId) {
    final idx = _logs.indexWhere((l) => l.id == logId);
    if (idx >= 0) {
      _logs[idx] = _logs[idx].copyWith(coachFeedbackId: feedbackId);
      notifyListeners();
      _persist();
    }
  }
}
