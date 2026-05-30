/// Global time-lock utility for Practice Log editability.
///
/// Once a day ticks over (midnight), that day's log is permanently sealed
/// and can no longer be modified — only viewed.
class TimeLockHelper {
  TimeLockHelper._();

  /// Strip the time component from [dt], returning a date-only DateTime.
  static DateTime dateOnly(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  /// Returns the current date (no time component).
  static DateTime get today => dateOnly(DateTime.now());

  /// Returns `true` when [logDate] is today → the log can be edited.
  ///
  /// [logDate] must be a date-only DateTime (or it will be stripped).
  static bool isEditable(DateTime logDate) {
    final d = dateOnly(logDate);
    return d == today;
  }

  /// Returns `true` when the log is sealed (past date).
  static bool isLocked(DateTime logDate) => !isEditable(logDate);

  /// Format a DateTime as a `yyyy-MM-dd` key for Map storage.
  static String dateKey(DateTime dt) {
    final d = dateOnly(dt);
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  /// Parse a `yyyy-MM-dd` key back to a date-only DateTime.
  static DateTime parseDateKey(String key) {
    final parts = key.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }
}
