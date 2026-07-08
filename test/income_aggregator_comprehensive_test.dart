import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/analytics/domain/utils/income_aggregator.dart';
import 'package:fintrack/features/analytics/domain/entities/income_data.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_entity.dart';

void main() {
  group('IncomeAggregator Comprehensive Tests', () {
    late List<TransactionEntity> testTransactions;

    setUp(() {
      final now = DateTime.now();
      testTransactions = [
        // Today's transactions
        TransactionEntity(
          uuid: 'tx-1',
          accountId: 'acc-1',
          type: 'income',
          categoryId: 'Salary',
          category: 'Salary',
          amount: 1000.0,
          title: 'Paycheck',
          description: '',
          currency: 'USD',
          paymentMethod: 'Bank Transfer',
          tags: const [],
          isDeleted: false,
          isSynced: false,
          isRecurring: false,
          date: now,
          createdAt: now,
          updatedAt: now,
          syncVersion: 1,
          merchant: 'Employer',
        ),
        // 3 days ago
        TransactionEntity(
          uuid: 'tx-2',
          accountId: 'acc-1',
          type: 'income',
          categoryId: 'Freelance',
          category: 'Freelance',
          amount: 500.0,
          title: 'Project',
          description: '',
          currency: 'USD',
          paymentMethod: 'PayPal',
          tags: const [],
          isDeleted: false,
          isSynced: false,
          isRecurring: false,
          date: now.subtract(const Duration(days: 3)),
          createdAt: now.subtract(const Duration(days: 3)),
          updatedAt: now.subtract(const Duration(days: 3)),
          syncVersion: 1,
          merchant: 'Client A',
        ),
        // 7 days ago
        TransactionEntity(
          uuid: 'tx-3',
          accountId: 'acc-1',
          type: 'income',
          categoryId: 'Bonus',
          category: 'Bonus',
          amount: 2000.0,
          title: 'Performance Bonus',
          description: '',
          currency: 'USD',
          paymentMethod: 'Bank Transfer',
          tags: const [],
          isDeleted: false,
          isSynced: false,
          isRecurring: false,
          date: now.subtract(const Duration(days: 7)),
          createdAt: now.subtract(const Duration(days: 7)),
          updatedAt: now.subtract(const Duration(days: 7)),
          syncVersion: 1,
          merchant: 'Employer',
        ),
        // 35 days ago (outside 30 days filter)
        TransactionEntity(
          uuid: 'tx-4',
          accountId: 'acc-1',
          type: 'income',
          categoryId: 'Gift',
          category: 'Gift',
          amount: 200.0,
          title: 'Birthday Gift',
          description: '',
          currency: 'USD',
          paymentMethod: 'Cash',
          tags: const [],
          isDeleted: false,
          isSynced: false,
          isRecurring: false,
          date: now.subtract(const Duration(days: 35)),
          createdAt: now.subtract(const Duration(days: 35)),
          updatedAt: now.subtract(const Duration(days: 35)),
          syncVersion: 1,
          merchant: 'Friend',
        ),
        // Deleted transaction (should be ignored)
        TransactionEntity(
          uuid: 'tx-5',
          accountId: 'acc-1',
          type: 'income',
          categoryId: 'Refund',
          category: 'Refund',
          amount: 100.0,
          title: 'Refund',
          description: '',
          currency: 'USD',
          paymentMethod: 'Bank Transfer',
          tags: const [],
          isDeleted: true,
          isSynced: false,
          isRecurring: false,
          date: now,
          createdAt: now,
          updatedAt: now,
          syncVersion: 1,
          merchant: 'Store',
        ),
        // Expense (should be ignored)
        TransactionEntity(
          uuid: 'tx-6',
          accountId: 'acc-1',
          type: 'expense',
          categoryId: 'Groceries',
          category: 'Groceries',
          amount: 50.0,
          title: 'Groceries',
          description: '',
          currency: 'USD',
          paymentMethod: 'Credit Card',
          tags: const [],
          isDeleted: false,
          isSynced: false,
          isRecurring: false,
          date: now,
          createdAt: now,
          updatedAt: now,
          syncVersion: 1,
          merchant: 'Supermarket',
        ),
      ];
    });

    test('aggregate filters income transactions correctly', () {
      final report = IncomeAggregator.aggregate(
        transactions: testTransactions,
        timeFilter: '30days',
      );

      // Should have 3 income transactions (tx-1, tx-2, tx-3)
      expect(report.incomeCount, 3);
      expect(report.totalIncome, 3500.0);
    });

    test('aggregate calculates total income correctly', () {
      final report = IncomeAggregator.aggregate(
        transactions: testTransactions,
        timeFilter: '30days',
      );

      expect(report.totalIncome, 1000.0 + 500.0 + 2000.0);
    });

    test('aggregate calculates average income correctly', () {
      final report = IncomeAggregator.aggregate(
        transactions: testTransactions,
        timeFilter: '30days',
      );

      expect(report.statistics.averageIncome, 3500.0 / 3);
    });

    test('aggregate identifies largest income correctly', () {
      final report = IncomeAggregator.aggregate(
        transactions: testTransactions,
        timeFilter: '30days',
      );

      expect(report.largestIncome, 2000.0);
      expect(report.largestIncomeInfo?.amount, 2000.0);
    });

    test('aggregate identifies smallest income correctly', () {
      final report = IncomeAggregator.aggregate(
        transactions: testTransactions,
        timeFilter: '30days',
      );

      expect(report.smallestIncome, 500.0);
      expect(report.smallestIncomeInfo?.amount, 500.0);
    });

    test('aggregate calculates category distribution', () {
      final report = IncomeAggregator.aggregate(
        transactions: testTransactions,
        timeFilter: '30days',
      );

      expect(report.categories.length, 3);
      expect(report.categories[0].categoryName, 'Bonus'); // Highest
      expect(report.categories[0].amount, 2000.0);
    });

    test('aggregate calculates source distribution', () {
      final report = IncomeAggregator.aggregate(
        transactions: testTransactions,
        timeFilter: '30days',
      );

      final sources = report.sources;
      expect(sources.isNotEmpty, true);

      // Check that Employer appears as a source
      final employerSource = sources.firstWhere(
        (s) => s.sourceName == 'Bank Transfer',
        orElse: () => const SourceSlice(sourceName: '', amount: 0),
      );
      expect(employerSource.amount, greaterThan(0));
    });

    test('aggregate calculates statistics correctly', () {
      final report = IncomeAggregator.aggregate(
        transactions: testTransactions,
        timeFilter: '30days',
      );

      expect(report.statistics.totalIncome, 3500.0);
      expect(report.statistics.incomeCount, 3);
      expect(report.statistics.largestIncome, 2000.0);
      expect(report.statistics.smallestIncome, 500.0);
      expect(report.statistics.averagePerDay, greaterThan(0));
    });

    test('aggregate builds calendar data', () {
      final report = IncomeAggregator.aggregate(
        transactions: testTransactions,
        timeFilter: '30days',
      );

      expect(report.calendarData.isNotEmpty, true);
      // Should have income recorded for at least 3 different days
      expect(report.calendarData.length, greaterThanOrEqualTo(3));
    });

    test('aggregate creates income points for chart', () {
      final report = IncomeAggregator.aggregate(
        transactions: testTransactions,
        timeFilter: '30days',
      );

      expect(report.points.isNotEmpty, true);
      expect(report.points.length, 3);
      
      // Check running total progression
      expect(report.points[0].runningTotal, report.points[0].amount);
      expect(
        report.points[1].runningTotal,
        report.points[0].amount + report.points[1].amount,
      );
    });

    test('aggregate returns empty report for no income', () {
      final emptyTransactions = [
        TransactionEntity(
          uuid: 'tx-1',
          accountId: 'acc-1',
          type: 'expense',
          categoryId: 'Food',
          category: 'Food',
          amount: 50.0,
          title: 'Lunch',
          description: '',
          currency: 'USD',
          paymentMethod: 'Card',
          tags: const [],
          isDeleted: false,
          isSynced: false,
          isRecurring: false,
          date: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          syncVersion: 1,
          merchant: 'Restaurant',
        ),
      ];

      final report = IncomeAggregator.aggregate(
        transactions: emptyTransactions,
        timeFilter: '30days',
      );

      expect(report.isEmpty(report), true);
      expect(report.totalIncome, 0);
      expect(report.incomeCount, 0);
    });

    test('aggregate filters by 7days correctly', () {
      final report = IncomeAggregator.aggregate(
        transactions: testTransactions,
        timeFilter: '7days',
      );

      // Should include only recent transactions
      expect(report.incomeCount, lessThanOrEqualTo(3));
    });

    test('aggregate builds category percentage distribution', () {
      final report = IncomeAggregator.aggregate(
        transactions: testTransactions,
        timeFilter: '30days',
      );

      final totalPercentage = report.categories
          .fold<double>(0, (sum, cat) => sum + cat.percentage);
      
      // Should sum to approximately 100
      expect(totalPercentage, closeTo(100, 0.1));
    });
  });

  group('IncomeAggregator Time Filter Tests', () {
    late List<TransactionEntity> testTransactions;
    late DateTime now;

    setUp(() {
      now = DateTime.now();
      testTransactions = [
        // Create transactions for various time periods
        _createTransaction(
          uuid: 'tx-today',
          date: now,
          amount: 100,
        ),
        _createTransaction(
          uuid: 'tx-yesterday',
          date: now.subtract(const Duration(days: 1)),
          amount: 200,
        ),
        _createTransaction(
          uuid: 'tx-7days',
          date: now.subtract(const Duration(days: 6, hours: 23)),
          amount: 300,
        ),
        _createTransaction(
          uuid: 'tx-30days',
          date: now.subtract(const Duration(days: 29, hours: 23)),
          amount: 400,
        ),
        _createTransaction(
          uuid: 'tx-60days',
          date: now.subtract(const Duration(days: 60)),
          amount: 500,
        ),
      ];
    });

    test('today filter includes only today\'s transactions', () {
      final report = IncomeAggregator.aggregate(
        transactions: testTransactions,
        timeFilter: 'today',
      );

      expect(report.incomeCount, 1);
      expect(report.totalIncome, 100);
    });

    test('7days filter includes last 7 days', () {
      final report = IncomeAggregator.aggregate(
        transactions: testTransactions,
        timeFilter: '7days',
      );

      expect(report.incomeCount, 3); // today + yesterday + 7 days ago
      expect(report.totalIncome, 600);
    });

    test('30days filter includes last 30 days', () {
      final report = IncomeAggregator.aggregate(
        transactions: testTransactions,
        timeFilter: '30days',
      );

      expect(report.incomeCount, 4); // today + yesterday + 7 days ago + 30 days ago
      expect(report.totalIncome, 1000);
    });
  });
}

/// Helper function to create test transactions
TransactionEntity _createTransaction({
  required String uuid,
  required DateTime date,
  required double amount,
}) {
  return TransactionEntity(
    uuid: uuid,
    accountId: 'acc-1',
    type: 'income',
    categoryId: 'Income',
    category: 'Income',
    amount: amount,
    title: 'Income',
    description: '',
    currency: 'USD',
    paymentMethod: 'Bank Transfer',
    tags: const [],
    isDeleted: false,
    isSynced: false,
    isRecurring: false,
    date: date,
    createdAt: date,
    updatedAt: date,
    syncVersion: 1,
    merchant: 'Employer',
  );
}
