import '../entities/category_data.dart';

/// Abstract repository for category analytics
abstract class CategoryRepository {
  /// Get category analytics report for a time filter
  Future<CategoryAnalyticsReport> getCategoryAnalytics(String timeFilter);

  /// Watch category analytics changes reactively
  Stream<CategoryAnalyticsReport> watchCategoryAnalytics(String timeFilter);

  /// Get detailed category information
  Future<CategoryDetails> getCategoryDetails(String categoryName, String timeFilter);

  /// Get category rankings
  Future<List<CategoryRanking>> getCategoryRankings(String timeFilter);

  /// Get expense categories only
  Future<List<CategoryRanking>> getExpenseCategories(String timeFilter);

  /// Get income categories only
  Future<List<CategoryRanking>> getIncomeCategories(String timeFilter);

  /// Get category comparison between periods
  Future<List<CategoryPeriodComparison>> getCategoryComparison(String timeFilter);
}
