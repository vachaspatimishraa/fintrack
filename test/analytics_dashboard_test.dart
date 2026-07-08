import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/analytics/domain/utils/analytics_engine.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_entity.dart';

void main() {
  group('Analytics Engine & Dashboard Foundation Unit Tests', () {
    test('AnalyticsEngine calculates income, expense, and savings correctly', () {
      final list = [
        TransactionEntity(
          uuid: 'tx-1',
          accountId: 'acc-1',
          type: 'income',
          categoryId: 'Salary',
          category: 'Salary',
          amount: 3000.0,
          title: 'Salary paycheck',
          description: 'Monthly pay',
          currency: 'USD',
          paymentMethod: 'Bank Deposit',
          tags: const [],
          isDeleted: false,
          isSynced: false,
          isRecurring: false,
          date: DateTime(2026, 7, 1),
          createdAt: DateTime(2026, 7, 1),
          updatedAt: DateTime(2026, 7, 1),
          syncVersion: 1,
        ),
        TransactionEntity(
          uuid: 'tx-2',
          accountId: 'acc-1',
          type: 'expense',
          categoryId: 'Rent',
          category: 'Rent',
          amount: 1200.0,
          title: 'Rent payment',
          description: 'Apartment rent',
          currency: 'USD',
          paymentMethod: 'Bank Transfer',
          tags: const [],
          isDeleted: false,
          isSynced: false,
          isRecurring: false,
          date: DateTime(2026, 7, 2),
          createdAt: DateTime(2026, 7, 2),
          updatedAt: DateTime(2026, 7, 2),
          syncVersion: 1,
        ),
      ];

      final state = AnalyticsEngine.calculateState(list);
      expect(state.totalIncome, equals(3000.0));
      expect(state.totalExpense, equals(1200.0));
      expect(state.savings, equals(1800.0));
      expect(state.totalBalance, equals(1800.0));
      expect(state.recentTransactions.length, equals(2));
    });
  });
}
