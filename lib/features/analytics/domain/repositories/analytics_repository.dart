import '../entities/analytics_state.dart';
import '../entities/monthly_report_data.dart';
import '../entities/yearly_report_data.dart';
import '../entities/custom_report_data.dart';
import '../entities/financial_health_data.dart';
import '../entities/ai_insight_data.dart';




abstract class AnalyticsRepository {
  Future<AnalyticsState> getAnalyticsState();
  Stream<AnalyticsState> watchAnalyticsState();

  Future<MonthlyReport> getMonthlyReport(DateTime monthAnchor);
  Future<MonthlySummary> getMonthlySummary(DateTime monthAnchor);
  Future<MonthlyStatistics> getMonthlyStatistics(DateTime monthAnchor);
  Future<MonthlyBudgetProgress> getMonthlyBudget(DateTime monthAnchor);
  Future<List<MonthlyCategoryBreakdown>> getMonthlyCategories(DateTime monthAnchor);
  Future<MonthlyComparison> getMonthlyComparison(DateTime monthAnchor);
  Future<MonthlyScore> getMonthlyFinancialScore(DateTime monthAnchor);
  Stream<MonthlyReport> watchMonthlyReports(DateTime monthAnchor);

  Future<YearlyReport> getYearlyReport(DateTime yearAnchor);
  Future<YearlySummary> getYearlySummary(DateTime yearAnchor);
  Future<YearlyStatistics> getYearlyStatistics(DateTime yearAnchor);
  Future<YearlyBudgetProgress> getYearlyBudget(DateTime yearAnchor);
  Future<List<YearlyCategoryBreakdown>> getYearlyCategories(DateTime yearAnchor);
  Future<YearlyComparison> getYearComparison(DateTime yearAnchor);
  Future<YearlyHealth> getFinancialHealth(DateTime yearAnchor);
  Stream<YearlyReport> watchYearlyReports(DateTime yearAnchor);

  Future<CustomReportDataset> generateCustomReport(CustomReportFilter filter, String groupBy, String sortBy);
  Future<CustomReportDataset> previewCustomReport(CustomReportFilter filter);
  Future<void> saveCustomReport(CustomReportConfig config);
  Future<void> deleteCustomReport(String uuid);
  Future<List<CustomReportConfig>> loadSavedReports();
  Stream<List<CustomReportConfig>> watchCustomReports();

  Future<FinancialHealthReport> calculateFinancialHealth();
  Stream<FinancialHealthReport> watchFinancialHealthReport();

  Future<AIInsightsReport> generateAIInsights();
  Stream<AIInsightsReport> watchAIInsights();
  Future<List<AIInsight>> getInsightHistory();
  Future<void> dismissInsight(String id);
  Future<void> pinInsight(String id);

  Future<void> clearCache();
  Future<void> refreshAnalytics();
}






