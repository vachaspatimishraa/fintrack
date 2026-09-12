import 'package:fintrack/features/budget/domain/entities/budget_entity.dart';
import 'package:fintrack/features/budget/domain/entities/budget_statistics.dart';
import 'package:fintrack/features/budget/domain/entities/budget_alert_entity.dart';
import 'package:fintrack/features/budget/domain/entities/budget_insight.dart';

class BudgetDashboardData {
  final BudgetEntity? overallBudget;
  final List<BudgetEntity> categoryBudgets;
  final BudgetStatistics statistics;
  final List<BudgetAlertEntity> alerts;
  final List<BudgetInsight> recommendations;
  final List<dynamic> recentActivity; // Could be BudgetHistoryEntity or custom events

  BudgetDashboardData({
    this.overallBudget,
    required this.categoryBudgets,
    required this.statistics,
    required this.alerts,
    required this.recommendations,
    required this.recentActivity,
  });
}
