import '../entities/weekly_report_data.dart';

abstract class WeeklyReportRepository {
  Future<WeeklyReport> getWeeklyReport(DateTime weekAnchor);

  Future<WeeklySummary> getWeeklySummary(DateTime weekAnchor);

  Future<WeeklyStatistics> getWeeklyStatistics(DateTime weekAnchor);

  Future<List<WeeklyCategoryBreakdown>> getWeeklyCategories(DateTime weekAnchor);

  Future<List<WeeklyTransactionItem>> getWeeklyTimeline(DateTime weekAnchor);

  Future<WeeklyComparison> getWeeklyComparison(DateTime weekAnchor);

  Future<WeeklyScore> getWeeklyScore(DateTime weekAnchor);

  Stream<WeeklyReport> watchWeeklyReports(DateTime weekAnchor);
}
