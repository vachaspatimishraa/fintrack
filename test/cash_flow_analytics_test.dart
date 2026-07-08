import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/analytics/domain/utils/cash_flow_aggregators.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_entity.dart';

void main() {
  group('Cash Flow Analytics Engine & Aggregation Tests', () {
    test('CashFlowAggregators aggregates transactions and calculates running balance', () {
      final list = [
        TransactionEntity(
          uuid: 'tx-1',
          accountId: 'acc-1',
          type: 'income',
          categoryId: 'Salary',
          category: 'Salary',
          amount: 5000.0,
          title: 'Paycheck',
          description: '',
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
          categoryId: 'Food',
          category: 'Food',
          amount: 200.0,
          title: 'Groceries',
          description: '',
          currency: 'USD',
          paymentMethod: 'Card',
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

      final report = CashFlowAggregators.aggregate(transactions: list, timeFilter: '30days');
      expect(report.points.length, equals(2));
      expect(report.netCashFlow, equals(4800.0));
      expect(report.averageDailyFlow, equals(2400.0));
      expect(report.highestIncome, equals(5000.0));
      expect(report.highestExpense, equals(200.0));

      final firstPoint = report.points.first;
      expect(firstPoint.runningBalance, equals(5000.0));

      final secondPoint = report.points.last;
      expect(secondPoint.runningBalance, equals(4800.0));
    });

    test('CashFlowAggregators returns empty report when transactions is empty', () {
      final report = CashFlowAggregators.aggregate(transactions: [], timeFilter: '30days');
      expect(report.points, isEmpty);
      expect(report.netCashFlow, equals(0.0));
    });
  });
}
