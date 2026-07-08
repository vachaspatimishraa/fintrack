import '../entities/calendar_analytics_data.dart';

class ActivityStreakService {
  const ActivityStreakService._();

  static ActivityStreak calculate(List<CalendarDayData> days) {
    if (days.isEmpty) return ActivityStreak.empty();

    final sorted = List<CalendarDayData>.from(days)
      ..sort((a, b) => a.date.compareTo(b.date));

    var currentActivity = 0;
    var longestActivity = 0;
    var runningActivity = 0;
    var currentSavings = 0;
    var longestSavings = 0;
    var runningSavings = 0;

    for (final day in sorted) {
      if (day.hasActivity) {
        runningActivity++;
      } else {
        runningActivity = 0;
      }
      if (day.savings > 0) {
        runningSavings++;
      } else {
        runningSavings = 0;
      }

      if (runningActivity > longestActivity) longestActivity = runningActivity;
      if (runningSavings > longestSavings) longestSavings = runningSavings;
    }

    for (final day in sorted.reversed) {
      if (day.hasActivity) {
        currentActivity++;
      } else {
        break;
      }
    }

    for (final day in sorted.reversed) {
      if (day.savings > 0) {
        currentSavings++;
      } else {
        break;
      }
    }

    return ActivityStreak(
      currentActivityStreak: currentActivity,
      currentSavingsStreak: currentSavings,
      longestActivityStreak: longestActivity,
      longestSavingsStreak: longestSavings,
    );
  }
}
