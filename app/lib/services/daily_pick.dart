/// Deterministic "lesson / quote of the day" pick.
class DailyPick {
  DailyPick._();

  /// Returns the index of the day-of-N (modulo items.length).
  static int dayIndex(int total, {DateTime? at}) {
    final start = DateTime(2024, 1, 1);
    final now = at ?? DateTime.now();
    final day = DateTime.utc(now.year, now.month, now.day)
        .difference(start)
        .inDays;
    return day % total;
  }
}
