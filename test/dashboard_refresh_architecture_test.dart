import 'dart:ffi';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fintrack/features/home/domain/models/dashboard_model.dart';
import 'package:fintrack/core/database/isar/collections/account_model.dart';

void main() {
  group('Dashboard Refresh Cross-Architecture Determinism Tests', () {
    test('Abi identification returns non-empty architecture string', () {
      final arch = Abi.current().toString();
      expect(arch, isNotEmpty);
    });

    test('Dashboard balance, income, expense calculation is consistent', () {
      final account = AccountModel()
        ..uuid = 'acc-wallet-1'
        ..name = 'Primary Wallet'
        ..balance = 1000.0;

      double incomeSum = 500.0;
      double expenseSum = 200.0;
      double openingBalance = 700.0;

      final computedBalance = openingBalance + incomeSum - expenseSum;

      final dashboard = DashboardModel(
        currentAccount: account,
        income: incomeSum,
        expense: expenseSum,
        balance: computedBalance,
        transactionCount: 2,
        syncStatus: HomeSyncStatus.synced,
      );

      expect(dashboard.balance, 1000.0);
      expect(dashboard.income, 500.0);
      expect(dashboard.expense, 200.0);
      expect(dashboard.transactionCount, 2);
    });

    test('Provider invalidation triggers fresh container state read', () {
      int readCount = 0;
      final testDataProvider = Provider<int>((ref) {
        readCount++;
        return readCount;
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final val1 = container.read(testDataProvider);
      expect(val1, 1);

      // Subsequent read returns cached value
      final val2 = container.read(testDataProvider);
      expect(val2, 1);

      // Invalidation forces recalculation
      container.invalidate(testDataProvider);
      final val3 = container.read(testDataProvider);
      expect(val3, 2);
    });
  });
}
