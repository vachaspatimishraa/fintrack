import '../entities/goal_entity.dart';

class SyncOptimizer {
  /// Filters goals that actually need synchronization.
  static List<GoalEntity> getPendingSync(List<GoalEntity> goals) {
    return goals.where((g) => g.syncStatus == 'pending' || g.syncStatus == 'error').toList();
  }

  /// Batches goals into groups for optimized network transfer.
  static List<List<GoalEntity>> batchGoals(List<GoalEntity> goals, {int batchSize = 50}) {
    List<List<GoalEntity>> batches = [];
    for (var i = 0; i < goals.length; i += batchSize) {
      batches.add(goals.sublist(i, (i + batchSize).clamp(0, goals.length)));
    }
    return batches;
  }
}
