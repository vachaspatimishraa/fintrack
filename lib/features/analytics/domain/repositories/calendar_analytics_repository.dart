import '../entities/calendar_analytics_data.dart';

abstract class CalendarAnalyticsRepository {
  Future<CalendarAnalyticsReport> getCalendarData(
    DateTime visibleMonth, {
    bool includeIncome = true,
    bool includeExpense = true,
  });

  Future<CalendarDayData> getDaySummary(DateTime date);

  Future<CalendarPeriodSummary> getWeekSummary(DateTime date);

  Future<CalendarPeriodSummary> getMonthSummary(DateTime month);

  Future<CalendarPeriodSummary> getYearSummary(int year);

  Future<List<CalendarDayData>> getHeatmap(DateTime visibleMonth);

  Future<List<CalendarTransactionItem>> getDailyTransactions(DateTime date);

  Future<ActivityStreak> getActivityStreak(DateTime visibleMonth);

  Stream<CalendarAnalyticsReport> watchCalendarAnalytics(
    DateTime visibleMonth, {
    bool includeIncome = true,
    bool includeExpense = true,
  });
}
