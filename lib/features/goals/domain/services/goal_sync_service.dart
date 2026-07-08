import '../repositories/goal_repository.dart';

class GoalSyncService {
  final GoalRepository _repository;

  GoalSyncService(this._repository);

  Future<void> performSync() async {
    await _repository.synchronizeGoals();
  }
}
