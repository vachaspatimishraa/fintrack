import '../entities/budget_dashboard_data.dart';
import '../entities/budget_entity.dart';
import '../repositories/budget_repository.dart';
import '../repositories/budget_alert_repository.dart';
import '../repositories/budget_analytics_repository.dart';

class BudgetDashboardEngine {
  final BudgetRepository _budgetRepository;
  final BudgetAlertRepository _alertRepository;
  final BudgetAnalyticsRepository _analyticsRepository;

  BudgetDashboardEngine({
    required BudgetRepository budgetRepository,
    required BudgetAlertRepository alertRepository,
    required BudgetAnalyticsRepository analyticsRepository,
  })  : _budgetRepository = budgetRepository,
        _alertRepository = alertRepository,
        _analyticsRepository = analyticsRepository;

  Future<BudgetDashboardData> getDashboardData() async {
    final budgets = await _budgetRepository.getActiveBudgets();
    
    BudgetEntity? overall;
    try {
      overall = budgets.firstWhere((b) => b.budgetType == 'overall');
    } catch (_) {
      overall = null;
    }

    final categoryBudgets = budgets.where((b) => b.budgetType == 'category').toList();
    final statistics = await _budgetRepository.calculateStatistics();
    final alerts = await _alertRepository.watchActiveAlerts().first;
    final insights = await _analyticsRepository.getBudgetInsights();
    
    // For recent activity, we can use history
    final history = await _analyticsRepository.getBudgetHistory();

    return BudgetDashboardData(
      overallBudget: overall,
      categoryBudgets: categoryBudgets,
      statistics: statistics,
      alerts: alerts,
      recommendations: insights,
      recentActivity: history.take(5).toList(),
    );
  }
}
