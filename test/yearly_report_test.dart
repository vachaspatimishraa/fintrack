import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/analytics/domain/entities/yearly_report_data.dart';
import 'package:fintrack/features/analytics/domain/utils/year_comparison_service.dart';
import 'package:fintrack/features/analytics/domain/utils/yearly_analytics_engine.dart';
import 'package:fintrack/features/analytics/domain/utils/yearly_aggregator.dart';
import 'package:fintrack/features/budget/domain/entities/budget_entity.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_entity.dart';

void main() {
  group('YearComparisonService Tests', () {
    test('calculates YoY growth percentage accurately', () {
      expect(YearComparisonService.growth(150, 100), 50.0);
      expect(YearComparisonService.growth(50, 100), -50.0);
      expect(YearComparisonService.growth(100, 0), 100.0);
      expect(YearComparisonService.growth(0, 0), 0.0);
    });

    test('compares current and previous summaries correctly', () {
      const current = YearlySummary(income: 10000, expense: 6000, savings: 4000, cashFlow: 4000);
      const previous = YearlySummary(income: 8000, expense: 5000, savings: 3000, cashFlow: 3000);

      final comparison = YearComparisonService.compare(
        current: current,
        previous: previous,
        currentBudgetSpent: 6000,
        previousBudgetSpent: 5000,
        currentTransactionsCount: 120,
        previousTransactionsCount: 100,
      );

      expect(comparison.incomeChange, 2000.0);
      expect(comparison.expenseChange, 1000.0);
      expect(comparison.savingsChange, 1000.0);
      expect(comparison.cashFlowChange, 1000.0);
      expect(comparison.incomeGrowthPercentage, 25.0);
      expect(comparison.expenseGrowthPercentage, 20.0);
      expect(comparison.budgetDifference, 1000.0);
      expect(comparison.transactionDifference, 20.0);
    });
  });

  group('YearlyAnalyticsEngine Tests', () {
    test('calculates health score correctly based on metrics', () {
      const summary = YearlySummary(income: 100000, expense: 40000, savings: 60000, cashFlow: 60000);
      const budgetProgress = YearlyBudgetProgress(
        budgetLimit: 50000,
        spent: 40000,
        remaining: 10000,
        utilization: 0.8,
        status: 'Safe',
        exceededCategories: [],
        safeCategories: [],
        categoryBudgetsCount: 0,
        complianceScore: 100.0,
      );

      final health = YearlyAnalyticsEngine.calculateHealth(
        summary: summary,
        budgetProgress: budgetProgress,
      );

      expect(health.score, greaterThanOrEqualTo(50));
      expect(health.score, lessThanOrEqualTo(100));
      expect(health.factors, isNotEmpty);
      expect(health.grade, anyOf('A', 'B', 'C', 'D', 'F'));
      expect(health.status, anyOf('Excellent', 'Good', 'Fair', 'Needs Attention'));
    });

    test('generates relevant insights and recommendations', () {
      const summary = YearlySummary(income: 100000, expense: 40000, savings: 60000, cashFlow: 60000);
      const comparison = YearlyComparison(
        incomeChange: 20000,
        expenseChange: -10000,
        savingsChange: 30000,
        cashFlowChange: 30000,
        incomeGrowthPercentage: 25.0,
        expenseGrowthPercentage: -20.0,
        savingsGrowthPercentage: 100.0,
        cashFlowGrowthPercentage: 100.0,
        budgetDifference: 0.0,
        transactionDifference: 20.0,
      );
      const budgetProgress = YearlyBudgetProgress(
        budgetLimit: 50000,
        spent: 40000,
        remaining: 10000,
        utilization: 0.8,
        status: 'Safe',
        exceededCategories: ['Shopping'],
        safeCategories: ['Food'],
        categoryBudgetsCount: 2,
        complianceScore: 50.0,
      );

      final insights = YearlyAnalyticsEngine.generateInsights(
        summary: summary,
        comparison: comparison,
        budgetProgress: budgetProgress,
        categories: [
          const YearlyCategoryBreakdown(category: 'Food', amount: 30000, percentage: 75.0, transactionCount: 50, trend: 'down', monthlyAverage: 2500)
        ],
      );

      expect(insights, isNotEmpty);
      expect(insights.any((r) => r.contains('Annual savings increased')), true);
      expect(insights.any((r) => r.contains('Shopping')), true);
      expect(insights.any((r) => r.contains('Food')), true);
    });
  });

  group('YearlyAggregator Tests', () {
    test('aggregates transactions within calendar year bounds', () {
      final anchor = DateTime(2026, 7, 15);
      final transactions = [
        _tx(id: '1', amount: 50000, type: 'income', date: DateTime(2026, 3, 5)), // in year
        _tx(id: '2', amount: 20000, type: 'expense', date: DateTime(2026, 5, 10), category: 'Food'), // in year
        _tx(id: '3', amount: 15000, type: 'expense', date: DateTime(2026, 11, 20), category: 'Shopping'), // in year
        _tx(id: '4', amount: 10000, type: 'expense', date: DateTime(2025, 12, 25)), // previous year
        _tx(id: '5', amount: 40000, type: 'income', date: DateTime(2027, 1, 2)), // next year
      ];

      final budgets = [
        BudgetEntity(
          uuid: 'b1',
          ownerId: 'u1',
          title: 'Shopping',
          budgetType: 'category',
          amount: 10000,
          categoryId: 'Shopping',
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 12, 31),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final report = YearlyAggregator.aggregate(
        transactions: transactions,
        budgets: budgets,
        yearAnchor: anchor,
      );

      expect(report.yearStart.year, 2026);
      expect(report.yearStart.month, 1);
      expect(report.yearStart.day, 1);
      expect(report.yearEnd.year, 2026);
      expect(report.yearEnd.month, 12);
      expect(report.yearEnd.day, 31);

      expect(report.summary.income, 50000.0);
      expect(report.summary.expense, 35000.0);
      expect(report.summary.savings, 15000.0);

      expect(report.statistics.totalTransactions, 3);
      expect(report.statistics.incomeTransactions, 1);
      expect(report.statistics.expenseTransactions, 2);
      expect(report.statistics.largestExpense, 20000.0);
      expect(report.statistics.largestIncome, 50000.0);

      expect(report.categories.length, 2);
      expect(report.categories.first.category, 'Food');
      expect(report.categories.first.amount, 20000.0);

      // Exceeded budget categories (spent 15000 > budget 10000)
      expect(report.budgetProgress.exceededCategories.contains('Shopping'), true);

      // Verify monthly breakdown counts
      expect(report.monthlyBreakdown.length, 12);
      expect(report.monthlyBreakdown[2].income, 50000.0); // March
      expect(report.monthlyBreakdown[4].expense, 20000.0); // May
      expect(report.monthlyBreakdown[10].expense, 15000.0); // November
    });
  });
}

TransactionEntity _tx({
  required String id,
  required double amount,
  required String type,
  required DateTime date,
  String category = 'Others',
}) {
  return TransactionEntity(
    id: id,
    type: type,
    amount: amount,
    category: category,
    title: 'Sample',
    date: date,
  );
}
