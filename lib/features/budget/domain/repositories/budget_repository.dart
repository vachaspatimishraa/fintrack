import '../entities/budget_entity.dart';
import '../entities/budget_statistics.dart';

/// Repository responsible for managing spending limits and budget lifecycles.
/// 
/// Handles CRUD operations, progress calculations, and financial statistics.
/// Adheres to Offline First principles by prioritizing local storage (Isar).
abstract class BudgetRepository {
  /// Persists a new budget to local storage and queues for cloud synchronization.
  Future<void> createBudget(BudgetEntity budget);

  /// Updates an existing budget and triggers progress recalculation.
  Future<void> updateBudget(BudgetEntity budget);

  /// Soft-deletes a budget by marking it as deleted.
  Future<void> deleteBudget(String uuid);

  /// Restores a soft-deleted budget.
  Future<void> restoreBudget(String uuid);

  /// Archives a budget to remove it from active tracking while preserving data.
  Future<void> archiveBudget(String uuid);

  /// Creates a duplicate of an existing budget for a new period.
  Future<void> duplicateBudget(String uuid);
  
  /// Retrieves a specific budget by its unique identifier.
  Future<BudgetEntity?> getBudget(String uuid);

  /// Returns a reactive stream for a specific budget.
  Stream<BudgetEntity?> watchBudget(String uuid);

  /// Returns a reactive stream of all non-deleted budgets.
  Stream<List<BudgetEntity>> watchBudgets();
  
  /// Retrieves all budgets.
  Future<List<BudgetEntity>> getBudgets();
  
  /// Retrieves all budgets currently in 'active' status.
  Future<List<BudgetEntity>> getActiveBudgets();

  /// Retrieves all budgets that have been completed.
  Future<List<BudgetEntity>> getCompletedBudgets();

  /// Retrieves budgets specifically allocated to expense categories.
  Future<List<BudgetEntity>> getCategoryBudgets();
  
  /// Recalculates spent amount and progress percentage for a specific budget.
  /// 
  /// Throws an exception if the budget is not found.
  Future<double> calculateProgress(String uuid);

  /// Calculates the remaining currency amount available in the budget.
  Future<double> calculateRemaining(String uuid);

  /// Generates high-level aggregated statistics for all budgets.
  Future<BudgetStatistics> calculateStatistics();
  
  /// Manually refreshes progress for all active budgets.
  Future<void> refresh();

  /// Synchronizes local budget changes with the remote Supabase instance.
  Future<void> sync();
}
