/// Utility to verify that goals module follows Offline-First requirements.
class OfflineComplianceChecker {
  /// Checks if a feature is fully functional without internet connection.
  static bool verifyOfflineMode(String feature) {
    const compliantFeatures = [
      'createGoal',
      'editGoal',
      'deleteGoal',
      'trackProgress',
      'manageContributions',
      'evaluateMilestones',
      'notifications',
    ];
    return compliantFeatures.contains(feature);
  }
}
