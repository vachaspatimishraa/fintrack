import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/accounts/domain/utils/balance_calculator.dart';
import 'package:fintrack/features/accounts/domain/utils/conflict_resolver.dart';
import 'package:fintrack/core/database/isar/collections/account_model.dart';

void main() {
  group('BalanceCalculator & ConflictResolver Tests', () {
    test('BalanceCalculator computes balance correctly', () {
      final balance = BalanceCalculator.calculateCurrentBalance(
        openingBalance: 1000.0,
        income: 500.0,
        expense: 200.0,
      );
      expect(balance, 1300.0);
    });

    test('ConflictResolver resolves conflicts correctly based on timestamps', () {
      final baseTime = DateTime.now();

      final local = AccountModel()
        ..uuid = 'acc-1'
        ..updatedAt = baseTime.add(const Duration(minutes: 5));

      final remote = AccountModel()
        ..uuid = 'acc-1'
        ..updatedAt = baseTime.add(const Duration(minutes: 10));

      final res1 = ConflictResolver.resolve(local: local, remote: remote);
      expect(res1, ConflictResolutionResult.remoteWins);

      final res2 = ConflictResolver.resolve(
        local: local..updatedAt = baseTime.add(const Duration(minutes: 20)),
        remote: remote,
      );
      expect(res2, ConflictResolutionResult.localWins);

      final res3 = ConflictResolver.resolve(
        local: local..updatedAt = remote.updatedAt,
        remote: remote,
      );
      expect(res3, ConflictResolutionResult.noConflict);
    });
  });
}
