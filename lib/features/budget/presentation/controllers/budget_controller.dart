import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../providers/budget_provider.dart';
import '../../domain/utils/budget_validator.dart';

/// Controller handling UI-triggered budget operations.
/// 
/// Validates inputs, coordinates with the repository, and manages
/// high-level lifecycle events like archiving or duplicating budgets.
class BudgetController {
  final Ref _ref;

  BudgetController(this._ref);

  BudgetRepository get _repository => _ref.read(budgetRepositoryProvider);

  /// Creates a new budget after validating its attributes.
  /// 
  /// Throws an [Exception] if validation fails.
  Future<void> createBudget(BudgetEntity budget) async {
    if (!BudgetValidator.isValid(budget)) {
      throw Exception('Invalid budget data');
    }
    await _repository.createBudget(budget);
    await _repository.refresh();
  }

  /// Updates an existing budget with new values.
  /// 
  /// Throws an [Exception] if validation fails.
  Future<void> updateBudget(BudgetEntity budget) async {
    if (!BudgetValidator.isValid(budget)) {
      throw Exception('Invalid budget data');
    }
    await _repository.updateBudget(budget);
    await _repository.refresh();
  }

  /// Initiates the soft-deletion process for a budget.
  Future<void> deleteBudget(String uuid) async {
    await _repository.deleteBudget(uuid);
    await _repository.refresh();
  }

  /// Restores a previously deleted budget.
  Future<void> restoreBudget(String uuid) async {
    await _repository.restoreBudget(uuid);
    await _repository.refresh();
  }

  /// Moves a budget to the archive.
  Future<void> archiveBudget(String uuid) async {
    await _repository.archiveBudget(uuid);
    await _repository.refresh();
  }

  /// Duplicates a budget for quick re-use.
  Future<void> duplicateBudget(String uuid) async {
    await _repository.duplicateBudget(uuid);
    await _repository.refresh();
  }
}

final budgetControllerProvider = Provider<BudgetController>((ref) => BudgetController(ref));
