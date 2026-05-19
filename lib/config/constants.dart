class AppConstants {
  AppConstants._();

  static const String appName = 'TennisSprout';
  static const String appNameCN = '网球发芽了';

  // NTRP range
  static const double ntprMin = 1.0;
  static const double ntprMax = 7.0;
  static const double ntprDefault = 3.0;

  // Skill levels
  static const double skillMin = 1.0;
  static const double skillMax = 10.0;

  // Daily status
  static const int maxStreakMilestone = 365;

  // Skill tree branches
  static const List<String> skillBranches = [
    'baseline',
    'net_play',
    'serve_return',
  ];

  // Match stats
  static const List<String> statTypes = ['winner', 'unforced_error', 'double_fault'];

  // Court surfaces
  static const List<String> courtSurfaces = ['grass', 'clay', 'hard'];

  // Audio
  static const double waveformBarCount = 32;
  static const double playbackSpeedMin = 0.5;
  static const double playbackSpeedMax = 2.0;
}
