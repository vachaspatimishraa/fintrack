import '../entities/spending_trend_data.dart';

abstract class SpendingTrendRepository {
  Future<SpendingTrendReport> getSpendingTrend(String timeFilter);

  Future<SpendingTrendReport> getDailyTrend();

  Future<SpendingTrendReport> getWeeklyTrend();

  Future<SpendingTrendReport> getMonthlyTrend();

  Future<SpendingTrendReport> getYearlyTrend();

  Future<List<SpendingTrendPoint>> getMovingAverage(String timeFilter);

  Future<SpendingForecast> getTrendForecast(String timeFilter);

  Future<List<TrendComparison>> getTrendComparison(String timeFilter);

  Stream<SpendingTrendReport> watchTrendAnalytics(String timeFilter);
}
