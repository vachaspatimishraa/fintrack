import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/transactions/domain/utils/developer_playbook.dart';

void main() {
  group('Developer Playbook & Health Score Tests', () {
    test('HealthScoreCalculator computes scores correctly based on metrics', () {
      final perfect = HealthScoreCalculator.computeScore(
        testCoverage: 95.0,
        actualLatencyMs: 120,
        hasWarnings: false,
      );
      expect(perfect, equals(100.0));

      final poor = HealthScoreCalculator.computeScore(
        testCoverage: 80.0,
        actualLatencyMs: 200,
        hasWarnings: true,
      );
      // 100.0 - 20 (coverage) - 25 (latency) - 10 (warnings) = 45.0
      expect(poor, equals(45.0));
    });

    test('DeveloperPlaybook returns correct template parameters', () {
      expect(DeveloperPlaybook.getCommitTemplate(), contains('feat(transaction)'));
      expect(DeveloperPlaybook.getPullRequestTemplate(), contains('## Summary'));
      expect(DeveloperPlaybook.getBranchStrategy(), contains('develop <-'));
      expect(DeveloperPlaybook.getDebuggingFlow(), contains('UI -> Provider'));
    });
  });
}
