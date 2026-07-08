/// Utility to verify that budget features comply with "Offline First" standards.
class OfflineComplianceChecker {
  /// Checks if a budget operation can proceed without an internet connection.
  static bool verifyOfflineCapability(String feature) {
    const offlineCompliantFeatures = [
      'createBudget',
      'updateBudget',
      'deleteBudget',
      'calculateProgress',
      'viewDashboard',
      'generateAnalytics',
    ];
    
    return offlineCompliantFeatures.contains(feature);
  }
}
