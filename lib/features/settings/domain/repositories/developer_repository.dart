abstract class DeveloperRepository {
  Future<Map<String, dynamic>> getAppDiagnostics();
  Future<Map<String, dynamic>> getDatabaseDiagnostics();
  Future<Map<String, dynamic>> getRepositoryDiagnostics();
  Future<void> clearAllCaches();
  Future<void> resetSyncQueue();
  Future<void> toggleFeatureFlag(String flag, bool enabled);
  Future<void> enableDeveloperMode();
}
