import '../../domain/entities/budget_entity.dart';
import '../../data/mappers/budget_mapper.dart';

class SyncOptimizer {
  /// Batches multiple budget updates into a single payload to reduce network requests.
  static List<Map<String, dynamic>> prepareBatchPayload(List<BudgetEntity> budgets) {
    return budgets.map((b) => BudgetMapper.toJson(b)).toList();
  }

  /// Filters out records that don't need immediate synchronization.
  static List<BudgetEntity> getPendingSync(List<BudgetEntity> budgets) {
    return budgets.where((b) => b.syncStatus == 'pending').toList();
  }
}
