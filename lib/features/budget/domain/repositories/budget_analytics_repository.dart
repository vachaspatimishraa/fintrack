import 'package:fintrack/features/budget/domain/entities/budget_analytics.dart';
import 'package:fintrack/features/budget/domain/entities/budget_history_record.dart';
import 'package:fintrack/features/budget/domain/entities/budget_insight.dart';

abstract class BudgetAnalyticsRepository {
  Future<BudgetAnalytics> getBudgetAnalytics();
  Future<List<BudgetHistoryRecord>> getBudgetHistory();
  Future<List<BudgetInsight>> getBudgetInsights();
  Future<Map<String, double>> getCategorySpending();
  Future<Map<String, double>> getMonthlyTrends();
}
