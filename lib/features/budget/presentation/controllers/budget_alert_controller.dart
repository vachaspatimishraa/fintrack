import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fintrack/features/budget/domain/repositories/budget_alert_repository.dart';
import 'package:fintrack/features/budget/providers/budget_provider.dart';

class BudgetAlertController {
  final Ref _ref;

  BudgetAlertController(this._ref);

  BudgetAlertRepository get _repository => _ref.read(budgetAlertRepositoryProvider);

  Future<void> dismissAlert(String uuid) async {
    await _repository.dismissAlert(uuid);
  }

  Future<void> resolveAlert(String uuid) async {
    await _repository.resolveAlert(uuid);
  }

  Future<void> deleteAlert(String uuid) async {
    await _repository.deleteAlert(uuid);
  }
}

final budgetAlertControllerProvider = Provider<BudgetAlertController>(BudgetAlertController.new);
