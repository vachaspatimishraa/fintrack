import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/analytics/domain/utils/expense_aggregator.dart';
import 'package:fintrack/features/analytics/domain/utils/expense_growth_calculator.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_entity.dart';

void main() {
  group('ExpenseAggregator', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    test('should aggregate empty transaction list', () {
      final result = ExpenseAggregator.aggregate(
        transactions: [],
        timeFilter: '30days',
      );
      expect(result.expenseCount, 0);
      expect(result.totalExpense, 0);
    });

    test('should calculate total expense correctly', () {
      final transactions = [
        TransactionEntity(
          id: '1',
          type: 'expense',
          amount: 100,
          category: 'Food',
          merchant: 'Restaurant A',
          date: today,
          isDeleted: false,
        ),
        TransactionEntity(
          id: '2',
          type: 'expense',
          amount: 50,
          category: 'Transport',
          merchant: 'Taxi',
          date: today,
          isDeleted: false,
        ),
      ];

      final result = ExpenseAggregator.aggregate(
        transactions: transactions,
        timeFilter: '30days',
      );

      expect(result.totalExpense, 150);
      expect(result.expenseCount, 2);
    });

    test('should filter by income type only', () {
      final transactions = [
        TransactionEntity(
          id: '1',
          type: 'expense',
          amount: 100,
          category: 'Food',
          merchant: 'Restaurant',
          date: today,
          isDeleted: false,
        ),
        TransactionEntity(
          id: '2',
          type: 'income',
          amount: 500,
          category: 'Salary',
          merchant: 'Company',
          date: today,
          isDeleted: false,
        ),
      ];

      final result = ExpenseAggregator.aggregate(
        transactions: transactions,
        timeFilter: '30days',
      );

      expect(result.expenseCount, 1);
      expect(result.totalExpense, 100);
    });

    test('should calculate statistics correctly', () {
      final transactions = [
        TransactionEntity(
          id: '1',
          type: 'expense',
          amount: 100,
          category: 'Food',
          merchant: 'Restaurant A',
          date: today,
          isDeleted: false,
        ),
        TransactionEntity(
          id: '2',
          type: 'expense',
          amount: 200,
          category: 'Transport',
          merchant: 'Taxi',
          date: today,
          isDeleted: false,
        ),
        TransactionEntity(
          id: '3',
          type: 'expense',
          amount: 300,
          category: 'Food',
          merchant: 'Restaurant B',
          date: today,
          isDeleted: false,
        ),
      ];

      final result = ExpenseAggregator.aggregate(
        transactions: transactions,
        timeFilter: '30days',
      );

      expect(result.statistics.totalExpense, 600);
      expect(result.statistics.averageExpense, 200);
      expect(result.statistics.highestExpense, 300);
      expect(result.statistics.lowestExpense, 100);
    });

    test('should build category distribution', () {
      final transactions = [
        TransactionEntity(
          id: '1',
          type: 'expense',
          amount: 100,
          category: 'Food',
          merchant: 'Restaurant',
          date: today,
          isDeleted: false,
        ),
        TransactionEntity(
          id: '2',
          type: 'expense',
          amount: 200,
          category: 'Food',
          merchant: 'Cafe',
          date: today,
          isDeleted: false,
        ),
        TransactionEntity(
          id: '3',
          type: 'expense',
          amount: 100,
          category: 'Transport',
          merchant: 'Taxi',
          date: today,
          isDeleted: false,
        ),
      ];

      final result = ExpenseAggregator.aggregate(
        transactions: transactions,
        timeFilter: '30days',
      );

      expect(result.categories.length, 2);
      expect(result.categories[0].categoryName, 'Food');
      expect(result.categories[0].amount, 300);
    });

    test('should detect unusual expenses', () {
      final transactions = [
        TransactionEntity(
          id: '1',
          type: 'expense',
          amount: 50,
          category: 'Food',
          merchant: 'Cafe',
          date: today,
          isDeleted: false,
        ),
        TransactionEntity(
          id: '2',
          type: 'expense',
          amount: 55,
          category: 'Food',
          merchant: 'Restaurant',
          date: today.add(const Duration(days: 1)),
          isDeleted: false,
        ),
        TransactionEntity(
          id: '3',
          type: 'expense',
          amount: 1000, // Outlier
          category: 'Electronics',
          merchant: 'Store',
          date: today.add(const Duration(days: 2)),
          isDeleted: false,
        ),
        TransactionEntity(
          id: '4',
          type: 'expense',
          amount: 50,
          category: 'Food',
          merchant: 'Cafe',
          date: today,
          isDeleted: false,
        ),
        TransactionEntity(
          id: '5',
          type: 'expense',
          amount: 50,
          category: 'Food',
          merchant: 'Cafe',
          date: today,
          isDeleted: false,
        ),
        TransactionEntity(
          id: '6',
          type: 'expense',
          amount: 50,
          category: 'Food',
          merchant: 'Cafe',
          date: today,
          isDeleted: false,
        ),
        TransactionEntity(
          id: '7',
          type: 'expense',
          amount: 50,
          category: 'Food',
          merchant: 'Cafe',
          date: today,
          isDeleted: false,
        ),
        TransactionEntity(
          id: '8',
          type: 'expense',
          amount: 50,
          category: 'Food',
          merchant: 'Cafe',
          date: today,
          isDeleted: false,
        ),
      ];

      final result = ExpenseAggregator.aggregate(
        transactions: transactions,
        timeFilter: '30days',
      );

      expect(result.unusualExpenses.isNotEmpty, true);
      expect(result.unusualExpenses[0].amount, 1000);
    });

    test('should calculate health score', () {
      final transactions = [
        TransactionEntity(
          id: '1',
          type: 'expense',
          amount: 100,
          category: 'Food',
          merchant: 'Restaurant',
          date: today,
          isDeleted: false,
        ),
      ];

      final result = ExpenseAggregator.aggregate(
        transactions: transactions,
        timeFilter: '30days',
      );

      expect(result.healthScore.score, greaterThanOrEqualTo(0));
      expect(result.healthScore.score, lessThanOrEqualTo(100));
      expect(['A+', 'A', 'B+', 'B', 'C+', 'C', 'D', 'F']
          .contains(result.healthScore.grade), true);
    });

    test('should filter by time range today', () {
      final yesterday = today.subtract(const Duration(days: 1));

      final transactions = [
        TransactionEntity(
          id: '1',
          type: 'expense',
          amount: 100,
          category: 'Food',
          merchant: 'Restaurant A',
          date: today,
          isDeleted: false,
        ),
        TransactionEntity(
          id: '2',
          type: 'expense',
          amount: 50,
          category: 'Transport',
          merchant: 'Taxi',
          date: yesterday,
          isDeleted: false,
        ),
      ];

      final result = ExpenseAggregator.aggregate(
        transactions: transactions,
        timeFilter: 'today',
      );

      expect(result.expenseCount, 1);
      expect(result.totalExpense, 100);
    });

    test('should filter by 30 days', () {
      final dayAgo = today.subtract(const Duration(days: 40));

      final transactions = [
        TransactionEntity(
          id: '1',
          type: 'expense',
          amount: 100,
          category: 'Food',
          merchant: 'Restaurant',
          date: today,
          isDeleted: false,
        ),
        TransactionEntity(
          id: '2',
          type: 'expense',
          amount: 50,
          category: 'Transport',
          merchant: 'Taxi',
          date: dayAgo,
          isDeleted: false,
        ),
      ];

      final result = ExpenseAggregator.aggregate(
        transactions: transactions,
        timeFilter: '30days',
      );

      expect(result.expenseCount, 1);
      expect(result.totalExpense, 100);
    });
  });

  group('ExpenseGrowthCalculator', () {
    test('should calculate positive growth', () {
      final growth = ExpenseGrowthCalculator.calculateGrowthPercentage(150, 100);
      expect(growth, 50.0);
    });

    test('should calculate negative growth', () {
      final growth = ExpenseGrowthCalculator.calculateGrowthPercentage(50, 100);
      expect(growth, -50.0);
    });

    test('should handle zero previous value', () {
      final growth = ExpenseGrowthCalculator.calculateGrowthPercentage(100, 0);
      expect(growth, 100.0);
    });

    test('should determine expense trend escalating', () {
      final trend = ExpenseGrowthCalculator.getExpenseTrend(15);
      expect(trend, 'escalating');
    });

    test('should determine expense trend increasing', () {
      final trend = ExpenseGrowthCalculator.getExpenseTrend(5);
      expect(trend, 'increasing');
    });

    test('should determine expense trend stable', () {
      final trend = ExpenseGrowthCalculator.getExpenseTrend(0);
      expect(trend, 'stable');
    });

    test('should determine expense trend declining', () {
      final trend = ExpenseGrowthCalculator.getExpenseTrend(-5);
      expect(trend, 'declining');
    });

    test('should get spending status critical', () {
      final status = ExpenseGrowthCalculator.getSpendingStatus(25);
      expect(status, 'critical');
    });

    test('should get spending status warning', () {
      final status = ExpenseGrowthCalculator.getSpendingStatus(15);
      expect(status, 'warning');
    });

    test('should get spending status good', () {
      final status = ExpenseGrowthCalculator.getSpendingStatus(-5);
      expect(status, 'good');
    });

    test('should get growth color for positive growth', () {
      final color = ExpenseGrowthCalculator.getGrowthColor(10);
      expect(color, 'error');
    });

    test('should get growth color for negative growth', () {
      final color = ExpenseGrowthCalculator.getGrowthColor(-10);
      expect(color, 'success');
    });

    test('should format growth percentage', () {
      final formatted = ExpenseGrowthCalculator.formatGrowth(25.5);
      expect(formatted, '+25.5%');
    });

    test('should format negative growth percentage', () {
      final formatted = ExpenseGrowthCalculator.formatGrowth(-15.3);
      expect(formatted, '-15.3%');
    });

    test('should categorize spending level unsustainable', () {
      final level = ExpenseGrowthCalculator.categorizeSpendinLevel(9000, 10000);
      expect(level, 'unsustainable');
    });

    test('should categorize spending level high', () {
      final level = ExpenseGrowthCalculator.categorizeSpendinLevel(7000, 10000);
      expect(level, 'high');
    });

    test('should categorize spending level moderate', () {
      final level = ExpenseGrowthCalculator.categorizeSpendinLevel(5000, 10000);
      expect(level, 'moderate');
    });
  });
}
