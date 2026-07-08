class HealthScoreCalculator {
  static double computeScore({
    required double testCoverage,
    required int actualLatencyMs,
    required bool hasWarnings,
  }) {
    double score = 100.0;
    if (testCoverage < 90.0) score -= (90.0 - testCoverage) * 2;
    if (actualLatencyMs > 150) score -= (actualLatencyMs - 150) * 0.5;
    if (hasWarnings) score -= 10.0;
    return score < 0 ? 0.0 : score;
  }
}

class DeveloperPlaybook {
  static String getCommitTemplate() {
    return 'feat(transaction): [Description of feature upload]';
  }

  static String getPullRequestTemplate() {
    return '''## Summary
[Brief description of changes]
## Verification
[Include screenshot links or test command logs]
''';
  }

  static String getBranchStrategy() {
    return 'develop <- feature/* | bugfix/* | hotfix/*';
  }

  static String getDebuggingFlow() {
    return 'UI -> Provider -> Controller -> Repository -> Datasource -> Local DB -> Cloud Sync';
  }
}
