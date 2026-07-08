import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/home/domain/models/dashboard_model.dart';
import 'package:fintrack/features/home/domain/models/home_state.dart';
import 'package:fintrack/core/database/isar/collections/account_model.dart';

void main() {
  group('DashboardModel tests', () {
    test('default constructor works correctly', () {
      const model = DashboardModel();
      expect(model.currentAccount, isNull);
      expect(model.income, 0.0);
      expect(model.expense, 0.0);
      expect(model.balance, 0.0);
      expect(model.transactionCount, 0);
      expect(model.recentTransactions, isEmpty);
      expect(model.syncStatus, HomeSyncStatus.synced);
    });

    test('copyWith updates fields correctly', () {
      final account = AccountModel()
        ..uuid = 'acc-1'
        ..name = 'Savings'
        ..balance = 100.0;

      var model = const DashboardModel();
      model = model.copyWith(
        currentAccount: account,
        income: 200.0,
        expense: 50.0,
        balance: 150.0,
        transactionCount: 3,
        syncStatus: HomeSyncStatus.syncing,
      );

      expect(model.currentAccount?.uuid, 'acc-1');
      expect(model.income, 200.0);
      expect(model.expense, 50.0);
      expect(model.balance, 150.0);
      expect(model.transactionCount, 3);
      expect(model.syncStatus, HomeSyncStatus.syncing);
    });
  });

  group('HomeState tests', () {
    test('copyWith works correctly', () {
      const state = HomeState(isLoading: true);
      expect(state.isLoading, isTrue);
      expect(state.dashboard, isNull);

      final newState = state.copyWith(
        isLoading: false,
        error: 'Test Error',
      );

      expect(newState.isLoading, isFalse);
      expect(newState.error, 'Test Error');

      final clearedState = newState.copyWith(clearError: true);
      expect(clearedState.error, isNull);
    });
  });
}
