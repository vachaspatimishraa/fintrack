import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/analytics/domain/utils/income_aggregator.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_entity.dart';

void main() {
  group('Income Analytics Engine & Aggregator Tests', () {
    test('IncomeAggregator sums values and calculates period growth correctly', () {
      final list = [
        TransactionEntity(
          uuid: 'tx-1',
          accountId: 'acc-1',
          type: 'income',
          categoryId: 'Freelance',
          category: 'Freelance',
          amount: 1000.0,
          title: 'Project 1',
          description: '',
          currency: 'USD',
          paymentMethod: 'PayPal',
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
          type: 'income',
          categoryId: 'Salary',
          category: 'Salary',
          amount: 2000.0,
          title: 'Paycheck',
          description: '',
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

      final report = IncomeAggregator.aggregate(transactions: list, timeFilter: '30days');
      expect(report.totalIncome, equals(3000.0));
      expect(report.averageIncome, equals(1500.0));
      expect(report.largestIncome, equals(2000.0));
      expect(report.growthPercentage, equals(0.0)); // both are in the current period, so previous is empty and growth is 0

      expect(report.categories.first.categoryName, equals('Salary'));
      expect(report.categories.first.percentage, equals(2000.0 / 3000.0 * 100));
    });

    test('IncomeAggregator returns empty report when list is empty', () {
      final report = IncomeAggregator.aggregate(transactions: [], timeFilter: '30days');
      expect(report.totalIncome, equals(0.0));
      expect(report.points, isEmpty);
    });
  });
}
