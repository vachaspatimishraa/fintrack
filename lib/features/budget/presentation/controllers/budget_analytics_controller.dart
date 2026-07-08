import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/budget_analytics_provider.dart';

class BudgetAnalyticsController {
  final Ref _ref;

  BudgetAnalyticsController(this._ref);

  Future<void> refresh() async {
    // In Riverpod 2.x, refreshing can be done by invalidating the provider
    _ref.invalidate(budgetAnalyticsProvider);
    _ref.invalidate(budgetHistoryProvider);
    _ref.invalidate(budgetInsightsProvider);
    _ref.invalidate(categorySpendingProvider);
    _ref.invalidate(monthlyTrendsProvider);
  }
}

final budgetAnalyticsControllerProvider = Provider<BudgetAnalyticsController>((ref) => BudgetAnalyticsController(ref));
