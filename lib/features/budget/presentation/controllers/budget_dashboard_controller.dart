import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fintrack/features/budget/providers/budget_provider.dart';

class BudgetDashboardController {
  final Ref _ref;

  BudgetDashboardController(this._ref);

  Future<void> refresh() async {
    _ref.invalidate(budgetDashboardProvider);
  }
}

final budgetDashboardControllerProvider = Provider<BudgetDashboardController>(BudgetDashboardController.new);
