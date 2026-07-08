import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/analytics/domain/utils/category_aggregator.dart';
import 'package:fintrack/features/analytics/domain/entities/category_data.dart';
import 'package:fintrack/features/analytics/domain/utils/category_growth_calculator.dart';
import 'package:fintrack/features/analytics/domain/utils/category_ranking_service.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_entity.dart';

void main() {
  group('CategoryAggregator', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    test('should handle empty transaction list', () {
      final result = CategoryAggregator.aggregate(
        transactions: [],
        timeFilter: 'month',
      );
      expect(result.isEmpty, true);
      expect(result.categoryCount, 0);
    });

    test('should aggregate transactions by category', () {
      final transactions = [
        TransactionEntity(
          id: '1',
          type: 'expense',
          amount: 100,
          category: 'Food',
          merchant: 'Restaurant',
          date: today,
          isDeleted: false,
          categoryColor: '#FF0000',
          categoryIcon: 'fastfood',
        ),
        TransactionEntity(
          id: '2',
          type: 'expense',
          amount: 50,
          category: 'Food',
          merchant: 'Cafe',
          date: today,
          isDeleted: false,
          categoryColor: '#FF0000',
          categoryIcon: 'fastfood',
        ),
        TransactionEntity(
          id: '3',
          type: 'expense',
          amount: 30,
          category: 'Transport',
          merchant: 'Taxi',
          date: today,
          isDeleted: false,
          categoryColor: '#0000FF',
          categoryIcon: 'directions_car',
        ),
      ];

      final result = CategoryAggregator.aggregate(
        transactions: transactions,
        timeFilter: 'month',
      );

      expect(result.categoryCount, 2);
      expect(result.totalAmount, 180);
      expect(result.rankings[0].categoryName, 'Food');
      expect(result.rankings[0].amount, 150);
    });

    test('should calculate percentages correctly', () {
      final transactions = [
        TransactionEntity(
          id: '1',
          type: 'expense',
          amount: 100,
          category: 'Food',
          merchant: 'Restaurant',
          date: today,
          isDeleted: false,
          categoryColor: '#FF0000',
          categoryIcon: 'fastfood',
        ),
        TransactionEntity(
          id: '2',
          type: 'expense',
          amount: 100,
          category: 'Transport',
          merchant: 'Taxi',
          date: today,
          isDeleted: false,
          categoryColor: '#0000FF',
          categoryIcon: 'directions_car',
        ),
      ];

      final result = CategoryAggregator.aggregate(
        transactions: transactions,
        timeFilter: 'month',
      );

      expect(result.rankings[0].percentage, 50.0);
      expect(result.rankings[1].percentage, 50.0);
    });

    test('should separate expense and income categories', () {
      final transactions = [
        TransactionEntity(
          id: '1',
          type: 'expense',
          amount: 100,
          category: 'Food',
          merchant: 'Restaurant',
          date: today,
          isDeleted: false,
          categoryColor: '#FF0000',
          categoryIcon: 'fastfood',
        ),
        TransactionEntity(
          id: '2',
          type: 'income',
          amount: 500,
          category: 'Salary',
          merchant: 'Company',
          date: today,
          isDeleted: false,
          categoryColor: '#00FF00',
          categoryIcon: 'attach_money',
        ),
      ];

      final result = CategoryAggregator.aggregate(
        transactions: transactions,
        timeFilter: 'month',
      );

      expect(result.expenseCategories.length, 1);
      expect(result.incomeCategories.length, 1);
      expect(result.expenseCategories[0].categoryName, 'Food');
      expect(result.incomeCategories[0].categoryName, 'Salary');
    });

    test('should identify top spending category', () {
      final transactions = [
        TransactionEntity(
          id: '1',
          type: 'expense',
          amount: 500,
          category: 'Food',
          merchant: 'Restaurant',
          date: today,
          isDeleted: false,
          categoryColor: '#FF0000',
          categoryIcon: 'fastfood',
        ),
        TransactionEntity(
          id: '2',
          type: 'expense',
          amount: 100,
          category: 'Transport',
          merchant: 'Taxi',
          date: today,
          isDeleted: false,
          categoryColor: '#0000FF',
          categoryIcon: 'directions_car',
        ),
      ];

      final result = CategoryAggregator.aggregate(
        transactions: transactions,
        timeFilter: 'month',
      );

      expect(result.topSpendingCategory?.categoryName, 'Food');
      expect(result.topSpendingCategory?.amount, 500);
    });

    test('should identify most frequent category', () {
      final transactions = [
        TransactionEntity(
          id: '1',
          type: 'expense',
          amount: 10,
          category: 'Food',
          merchant: 'Restaurant',
          date: today,
          isDeleted: false,
          categoryColor: '#FF0000',
          categoryIcon: 'fastfood',
        ),
        TransactionEntity(
          id: '2',
          type: 'expense',
          amount: 15,
          category: 'Food',
          merchant: 'Cafe',
          date: today,
          isDeleted: false,
          categoryColor: '#FF0000',
          categoryIcon: 'fastfood',
        ),
        TransactionEntity(
          id: '3',
          type: 'expense',
          amount: 20,
          category: 'Food',
          merchant: 'Burger',
          date: today,
          isDeleted: false,
          categoryColor: '#FF0000',
          categoryIcon: 'fastfood',
        ),
        TransactionEntity(
          id: '4',
          type: 'expense',
          amount: 100,
          category: 'Transport',
          merchant: 'Taxi',
          date: today,
          isDeleted: false,
          categoryColor: '#0000FF',
          categoryIcon: 'directions_car',
        ),
      ];

      final result = CategoryAggregator.aggregate(
        transactions: transactions,
        timeFilter: 'month',
      );

      expect(result.mostFrequentCategory?.categoryName, 'Food');
      expect(result.mostFrequentCategory?.transactionCount, 3);
    });

    test('should filter by time period', () {
      final twoDaysAgo = today.subtract(const Duration(days: 2));

      final transactions = [
        TransactionEntity(
          id: '1',
          type: 'expense',
          amount: 100,
          category: 'Food',
          merchant: 'Restaurant',
          date: today,
          isDeleted: false,
          categoryColor: '#FF0000',
          categoryIcon: 'fastfood',
        ),
        TransactionEntity(
          id: '2',
          type: 'expense',
          amount: 50,
          category: 'Transport',
          merchant: 'Taxi',
          date: twoDaysAgo,
          isDeleted: false,
          categoryColor: '#0000FF',
          categoryIcon: 'directions_car',
        ),
      ];

      final result = CategoryAggregator.aggregate(
        transactions: transactions,
        timeFilter: 'today',
      );

      expect(result.categoryCount, 1);
      expect(result.rankings[0].categoryName, 'Food');
    });

    test('should calculate category comparisons', () {
      final transactions = [
        TransactionEntity(
          id: '1',
          type: 'expense',
          amount: 100,
          category: 'Food',
          merchant: 'Restaurant',
          date: today,
          isDeleted: false,
          categoryColor: '#FF0000',
          categoryIcon: 'fastfood',
        ),
        TransactionEntity(
          id: '2',
          type: 'expense',
          amount: 50,
          category: 'Food',
          merchant: 'Cafe',
          date: today.subtract(const Duration(days: 35)),
          isDeleted: false,
          categoryColor: '#FF0000',
          categoryIcon: 'fastfood',
        ),
      ];

      final result = CategoryAggregator.aggregate(
        transactions: transactions,
        timeFilter: 'month',
      );

      expect(result.comparisons.isNotEmpty, true);
      expect(result.comparisons[0].categoryName, 'Food');
    });

    test('should ignore deleted transactions', () {
      final transactions = [
        TransactionEntity(
          id: '1',
          type: 'expense',
          amount: 100,
          category: 'Food',
          merchant: 'Restaurant',
          date: today,
          isDeleted: false,
          categoryColor: '#FF0000',
          categoryIcon: 'fastfood',
        ),
        TransactionEntity(
          id: '2',
          type: 'expense',
          amount: 50,
          category: 'Food',
          merchant: 'Cafe',
          date: today,
          isDeleted: true,
          categoryColor: '#FF0000',
          categoryIcon: 'fastfood',
        ),
      ];

      final result = CategoryAggregator.aggregate(
        transactions: transactions,
        timeFilter: 'month',
      );

      expect(result.totalAmount, 100);
      expect(result.rankings[0].transactionCount, 1);
    });

    test('should get category details', () {
      final transactions = [
        TransactionEntity(
          id: '1',
          type: 'expense',
          amount: 100,
          category: 'Food',
          merchant: 'Restaurant',
          date: today,
          isDeleted: false,
          categoryColor: '#FF0000',
          categoryIcon: 'fastfood',
        ),
        TransactionEntity(
          id: '2',
          type: 'expense',
          amount: 50,
          category: 'Food',
          merchant: 'Cafe',
          date: today,
          isDeleted: false,
          categoryColor: '#FF0000',
          categoryIcon: 'fastfood',
        ),
      ];

      final details = CategoryAggregator.getCategoryDetails(
        transactions: transactions,
        categoryName: 'Food',
        timeFilter: 'month',
      );

      expect(details.categoryName, 'Food');
      expect(details.totalAmount, 150);
      expect(details.transactionCount, 2);
      expect(details.averageAmount, 75);
      expect(details.largestAmount, 100);
      expect(details.smallestAmount, 50);
    });
  });

  group('CategoryGrowthCalculator', () {
    test('should calculate positive growth', () {
      final growth = CategoryGrowthCalculator.calculateGrowth(200, 100);
      expect(growth, 100.0);
    });

    test('should calculate negative growth', () {
      final growth = CategoryGrowthCalculator.calculateGrowth(50, 100);
      expect(growth, -50.0);
    });

    test('should handle zero previous value', () {
      final growth = CategoryGrowthCalculator.calculateGrowth(100, 0);
      expect(growth, 100.0);
    });


    test('should get growth status critical increase', () {
      final status = CategoryGrowthCalculator.getGrowthStatus(25);
      expect(status, 'critical_increase');
    });

    test('should get growth status stable', () {
      final status = CategoryGrowthCalculator.getGrowthStatus(-2);
      expect(status, 'stable');
    });

    test('should format growth percentage', () {
      final formatted = CategoryGrowthCalculator.formatGrowth(25.5);
      expect(formatted, '+25.5%');
    });


    test('should format negative growth', () {
      final formatted = CategoryGrowthCalculator.formatGrowth(-15.3);
      expect(formatted, '-15.3%');
    });

    test('should get growth color for positive', () {
      final color = CategoryGrowthCalculator.getGrowthColor(10);
      expect(color, 'error');
    });

    test('should get growth color for negative', () {
      final color = CategoryGrowthCalculator.getGrowthColor(-10);
      expect(color, 'success');
    });
  });

  group('CategoryRankingService', () {
    final rankings = [
      (name: 'Food', amount: 500.0, percentage: 50.0, transactions: 10),
      (name: 'Transport', amount: 300.0, percentage: 30.0, transactions: 8),
      (name: 'Shopping', amount: 200.0, percentage: 20.0, transactions: 5),
    ]
        .map((r) => CategoryRanking(
              categoryName: r.name,
              amount: r.amount,
              percentage: r.percentage,
              rank: 1,
              transactionCount: r.transactions,
              categoryColor: '#FF0000',
              categoryIcon: 'category',
              averageAmount: r.amount / r.transactions,
            ))
        .toList();

    test('should get top categories', () {
      final top = CategoryRankingService.getTopCategories(rankings, limit: 2);
      expect(top.length, 2);
      expect(top[0].categoryName, 'Food');
    });

    test('should sort by amount', () {
      final sorted = CategoryRankingService.sortByAmount(rankings);
      expect(sorted[0].amount, 500.0);
      expect(sorted.last.amount, 200.0);
    });

    test('should calculate concentration', () {
      final concentration = CategoryRankingService.calculateConcentration(rankings);
      expect(concentration, greaterThan(0));
      expect(concentration, lessThan(1));
    });

    test('should categorize concentration as highly concentrated', () {
      final concentrated = [
        CategoryRanking(
          categoryName: 'Food',
          amount: 800.0,
          percentage: 80.0,
          rank: 1,
          transactionCount: 10,
          categoryColor: '#FF0000',
          categoryIcon: 'category',
          averageAmount: 80.0,
        ),
        CategoryRanking(
          categoryName: 'Other',
          amount: 200.0,
          percentage: 20.0,
          rank: 2,
          transactionCount: 5,
          categoryColor: '#0000FF',
          categoryIcon: 'category',
          averageAmount: 40.0,
        ),
      ];
      final concentration =
          CategoryRankingService.calculateConcentration(concentrated);
      final interpretation =
          CategoryRankingService.getConcentrationInterpretation(concentration);
      expect(interpretation, 'Highly Concentrated');
    });

    test('should categorize spending level', () {
      expect(CategoryRankingService.categorizeCategoryLevel(50), 'dominant');
      expect(CategoryRankingService.categorizeCategoryLevel(25), 'major');
      expect(CategoryRankingService.categorizeCategoryLevel(12), 'moderate');
      expect(CategoryRankingService.categorizeCategoryLevel(7), 'minor');
      expect(CategoryRankingService.categorizeCategoryLevel(2), 'negligible');
    });

    test('should get extremes', () {
      final extremes =
          CategoryRankingService.getExtremes(rankings, limit: 1);
      expect(extremes['top']!.length, 1);
      expect(extremes['bottom']!.length, 1);
      expect(extremes['top']![0].categoryName, 'Food');
      expect(extremes['bottom']![0].categoryName, 'Shopping');
    });
  });
}
