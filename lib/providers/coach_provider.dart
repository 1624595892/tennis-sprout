import 'package:flutter/material.dart';
import '../models/coach_feedback.dart';

class CoachProvider extends ChangeNotifier {
  CoachBinding? _binding;
  final List<CoachFeedback> _feedbacks = [];

  CoachBinding? get binding => _binding;
  List<CoachFeedback> get feedbacks => _feedbacks;
  bool get isBound => _binding != null;

  void bindCoach(String inviteCode) {
    // Mock: always bind successfully
    _binding = CoachBinding(
      coachId: 'coach_001',
      coachName: 'Coach Emily',
    );
    notifyListeners();
  }

  void unbindCoach() {
    _binding = null;
    _feedbacks.clear();
    notifyListeners();
  }

  void addFeedback(CoachFeedback feedback) {
    _feedbacks.insert(0, feedback);
    notifyListeners();
  }

  List<CoachFeedback> getFeedbacksForLog(String logId) {
    return _feedbacks.where((f) => f.relatedLogId == logId).toList();
  }
}
