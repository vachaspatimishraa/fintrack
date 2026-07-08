/// Contract for remote synchronization of goals data with the cloud.
abstract class GoalsRemoteDatasource {
  Future<void> uploadGoals();
  Future<void> downloadGoals();
  Future<void> synchronize();
}
