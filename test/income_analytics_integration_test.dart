import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/analytics/domain/utils/income_aggregator.dart';
import 'package:fintrack/features/analytics/domain/utils/income_growth_calculator.dart';
import 'package:fintrack/features/analytics/domain/utils/running_income_service.dart';
import 'package:fintrack/features/analytics/domain/entities/income_data.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_entity.dart';

void main() {
  group('Income Analytics Integration Tests', () {
    late List<TransactionEntity> testTransactions;
    late DateTime now;

    setUp(() {
      now = DateTime.now();
      testTransactions = [
        _createTransaction(
          uuid: 'tx-1',
          date: DateTime(now.year, now.month, 1),
          amount: 1000,
          category: 'Salary',
          merchant: 'Employer A',
        ),
        _createTransaction(
          uuid: 'tx-2',
          date: DateTime(now.year, now.month, 5),
          amount: 500,
          category: 'Freelance',
          merchant: 'Client B',
        ),
        _createTransaction(
          uuid: 'tx-3',
          date: DateTime(now.year, now.month, 10),
          amount: 2000,
          category: 'Bonus',
          merchant: 'Employer A',
        ),
        _createTransaction(
          uuid: 'tx-4',
          date: DateTime(now.year, now.month, 15),
          amount: 300,
          category: 'Interest',
          merchant: 'Bank',
        ),
        _createTransaction(
          uuid: 'tx-5',
          date: DateTime(now.year, now.month, 20),
          amount: 750,
          category: 'Freelance',
          merchant: 'Client C',
        ),
      ];
    });

    test('Complete income analysis workflow', () {
      // Step 1: Aggregate income data
      final report = IncomeAggregator.aggregate(
        transactions: testTransactions,
        timeFilter: 'thisMonth',
      );

      // Verify aggregation
      expect(report.totalIncome, 4550);
      expect(report.incomeCount, 5);
      expect(report.statistics.largestIncome, 2000);
      expect(report.statistics.smallestIncome, 300);

      // Step 2: Calculate growth metrics
      final growthPercentage = report.comparison.growthPercentage;
      expect(growthPercentage, isNotNull);

      // Step 3: Analyze category distribution
      expect(report.categories.isNotEmpty, true);
      final freelanceCategory = report.categories.firstWhere(
        (c) => c.categoryName == 'Freelance',
        orElse: () => const CategorySlice(
          categoryName: '',
          amount: 0,
          percentage: 0,
        ),
      );
      expect(freelanceCategory.amount, 1250); // 500 + 750

      // Step 4: Analyze source distribution
      expect(report.sources.isNotEmpty, true);

      // Step 5: Get insights about running income
      final runningGrowth = RunningIncomeService.getRunningIncomeGrowth(report.points);
      expect(runningGrowth, 4550 - 1000); // Last - First

      // Step 6: Calculate growth indicators
      final growthState = IncomeGrowthCalculator.getGrowthState(growthPercentage);
      expect(growthState, isIn(['increasing', 'stable', 'declining']));
    });

    test('Income comparison between periods', () {
      final currentPeriodTx = testTransactions;
      final previousPeriodTx = [
        _createTransaction(
          uuid: 'tx-p1',
          date: DateTime(now.year, now.month - 1, 1),
          amount: 1000,
          category: 'Salary',
          merchant: 'Employer A',
        ),
        _createTransaction(
          uuid: 'tx-p2',
          date: DateTime(now.year, now.month - 1, 15),
          amount: 1500,
          category: 'Salary',
          merchant: 'Employer A',
        ),
      ];

      final currentReport = IncomeAggregator.aggregate(
        transactions: currentPeriodTx,
        timeFilter: 'thisMonth',
      );

      final previousReport = IncomeAggregator.aggregate(
        transactions: previousPeriodTx,
        timeFilter: 'lastMonth',
      );

      // Compare totals
      expect(
        currentReport.totalIncome,
        greaterThan(previousReport.totalIncome),
      );

      // Calculate growth
      final growth = IncomeGrowthCalculator.calculateGrowthPercentage(
        currentReport.totalIncome,
        previousReport.totalIncome,
      );
      expect(growth, greaterThan(0));
    });

    test('Income analytics with multiple categories', () {
      final report = IncomeAggregator.aggregate(
        transactions: testTransactions,
        timeFilter: 'thisMonth',
      );

      // Verify category aggregation
      final categories = report.categories;
      expect(categories.length, greaterThan(0));

      // Verify percentages sum to ~100
      final totalPercentage = categories.fold<double>(
        0,
        (sum, cat) => sum + cat.percentage,
      );
      expect(totalPercentage, closeTo(100, 0.1));

      // Verify sorting (highest first)
      for (int i = 0; i < categories.length - 1; i++) {
        expect(
          categories[i].amount,
          greaterThanOrEqualTo(categories[i + 1].amount),
        );
      }
    });

    test('Income statistics calculations', () {
      final report = IncomeAggregator.aggregate(
        transactions: testTransactions,
        timeFilter: 'thisMonth',
      );

      final stats = report.statistics;

      // Verify all statistics are calculated
      expect(stats.totalIncome, 4550);
      expect(stats.incomeCount, 5);
      expect(stats.averageIncome, 910); // 4550 / 5
      expect(stats.largestIncome, 2000);
      expect(stats.smallestIncome, 300);

      // Verify period averages
      expect(stats.averagePerDay, greaterThan(0));
      expect(stats.averagePerWeek, greaterThan(stats.averagePerDay));
      expect(stats.averagePerMonth, greaterThan(stats.averagePerWeek));
    });

    test('Running income projection', () {
      final report = IncomeAggregator.aggregate(
        transactions: testTransactions,
        timeFilter: 'thisMonth',
      );

      if (report.points.length >= 2) {
        final projection = RunningIncomeService.projectFutureIncome(
          report.points,
          const Duration(days: 10),
        );

        // Projection should be higher than current running total
        expect(
          projection,
          greaterThan(report.points.last.runningTotal),
        );
      }
    });

    test('Empty income handling', () {
      final emptyReport = IncomeAggregator.aggregate(
        transactions: [],
        timeFilter: 'thisMonth',
      );

      expect(emptyReport.totalIncome, 0);
      expect(emptyReport.incomeCount, 0);
      expect(emptyReport.points.isEmpty, true);
      expect(emptyReport.categories.isEmpty, true);
      expect(emptyReport.sources.isEmpty, true);
    });

    test('Deleted transaction filtering', () {
      final transactionsWithDeleted = [
        ...testTransactions,
        _createTransaction(
          uuid: 'tx-deleted',
          date: DateTime(now.year, now.month, 25),
          amount: 5000,
          category: 'Income',
          merchant: 'Employer',
          isDeleted: true,
        ),
      ];

      final report = IncomeAggregator.aggregate(
        transactions: transactionsWithDeleted,
        timeFilter: 'thisMonth',
      );

      // Deleted transaction should not be included
      expect(report.totalIncome, 4550);
      expect(report.incomeCount, 5);
    });

    test('Calendar data generation', () {
      final report = IncomeAggregator.aggregate(
        transactions: testTransactions,
        timeFilter: 'thisMonth',
      );

      expect(report.calendarData.isNotEmpty, true);

      // Verify calendar data is sorted by date
      for (int i = 0; i < report.calendarData.length - 1; i++) {
        expect(
          report.calendarData[i].date.isBefore(
            report.calendarData[i + 1].date,
          ),
          true,
        );
      }

      // Verify calendar totals match actual transactions
      final calendarTotal = report.calendarData.fold<double>(
        0,
        (sum, day) => sum + day.totalIncome,
      );
      expect(calendarTotal, 4550);
    });

    test('Growth indicator color selection', () {
      // Test positive growth
      expect(
        IncomeGrowthCalculator.getGrowthColor(15.0),
        'success',
      );

      // Test negative growth
      expect(
        IncomeGrowthCalculator.getGrowthColor(-15.0),
        'error',
      );

      // Test zero growth
      expect(
        IncomeGrowthCalculator.getGrowthColor(0.0),
        'surface',
      );
    });

    test('Trend description generation', () {
      // Strong upward trend
      final upTrend = IncomeGrowthCalculator.getTrendDescription([100, 120, 150, 200]);
      expect(upTrend, contains('upward'));

      // Stable trend
      final stableTrend = IncomeGrowthCalculator.getTrendDescription([100, 101, 100, 102]);
      expect(stableTrend, 'Stable trend');

      // Downward trend
      final downTrend = IncomeGrowthCalculator.getTrendDescription([200, 150, 100, 50]);
      expect(downTrend, contains('downward'));
    });
  });
}

/// Helper function to create test transactions
TransactionEntity _createTransaction({
  required String uuid,
  required DateTime date,
  required double amount,
  String category = 'Income',
  String merchant = 'Source',
  bool isDeleted = false,
}) {
  return TransactionEntity(
    uuid: uuid,
    accountId: 'acc-1',
    type: 'income',
    categoryId: category,
    category: category,
    amount: amount,
    title: 'Income Transaction',
    description: '',
    currency: 'USD',
    paymentMethod: 'Bank Transfer',
    tags: const [],
    isDeleted: isDeleted,
    isSynced: false,
    isRecurring: false,
    date: date,
    createdAt: date,
    updatedAt: date,
    syncVersion: 1,
    merchant: merchant,
  );
}
