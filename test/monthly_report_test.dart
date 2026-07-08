import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/analytics/domain/entities/monthly_report_data.dart';
import 'package:fintrack/features/analytics/domain/utils/monthly_aggregator.dart';
import 'package:fintrack/features/analytics/domain/utils/monthly_comparison_service.dart';
import 'package:fintrack/features/analytics/domain/utils/monthly_analytics_engine.dart';
import 'package:fintrack/features/budget/domain/entities/budget_entity.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_entity.dart';

void main() {
  group('MonthlyComparisonService Tests', () {
    test('calculates MoM growth percentage accurately', () {
      expect(MonthlyComparisonService.growth(150, 100), 50.0);
      expect(MonthlyComparisonService.growth(50, 100), -50.0);
      expect(MonthlyComparisonService.growth(100, 0), 100.0);
      expect(MonthlyComparisonService.growth(0, 0), 0.0);
    });

    test('compares current and previous summaries correctly', () {
      const current = MonthlySummary(income: 1000, expense: 600, savings: 400, cashFlow: 400);
      const previous = MonthlySummary(income: 800, expense: 500, savings: 300, cashFlow: 300);

      final comparison = MonthlyComparisonService.compare(
        current: current,
        previous: previous,
        currentBudgetSpent: 600,
        previousBudgetSpent: 500,
        currentTransactionsCount: 10,
        previousTransactionsCount: 8,
      );

      expect(comparison.incomeChange, 200.0);
      expect(comparison.expenseChange, 100.0);
      expect(comparison.savingsChange, 100.0);
      expect(comparison.cashFlowChange, 100.0);
      expect(comparison.incomeGrowthPercentage, 25.0);
      expect(comparison.expenseGrowthPercentage, 20.0);
      expect(comparison.budgetDifference, 100.0);
      expect(comparison.transactionDifference, 2.0);
    });
  });

  group('MonthlyAnalyticsEngine Tests', () {
    test('calculates financial score correctly based on metrics', () {
      const summary = MonthlySummary(income: 10000, expense: 4000, savings: 6000, cashFlow: 6000);
      const budgetProgress = MonthlyBudgetProgress(
        budgetLimit: 5000,
        spent: 4000,
        remaining: 1000,
        utilization: 0.8,
        status: 'Safe',
        exceededCategories: [],
        safeCategories: [],
        categoryBudgetsCount: 0,
      );

      final score = MonthlyAnalyticsEngine.calculateScore(
        summary: summary,
        budgetProgress: budgetProgress,
      );

      expect(score.score, greaterThanOrEqualTo(50));
      expect(score.score, lessThanOrEqualTo(100));
      expect(score.factors, isNotEmpty);
      expect(score.grade, anyOf('A', 'B', 'C', 'D', 'F'));
      expect(score.status, anyOf('Excellent', 'Good', 'Fair', 'Needs Attention'));
    });

    test('generates relevant recommendations and insights', () {
      const summary = MonthlySummary(income: 10000, expense: 4000, savings: 6000, cashFlow: 6000);
      const comparison = MonthlyComparison(
        incomeChange: 2000,
        expenseChange: -1000,
        savingsChange: 3000,
        cashFlowChange: 3000,
        incomeGrowthPercentage: 25.0,
        expenseGrowthPercentage: -20.0,
        savingsGrowthPercentage: 100.0,
        cashFlowGrowthPercentage: 100.0,
        budgetDifference: 0.0,
        transactionDifference: 2.0,
      );
      const budgetProgress = MonthlyBudgetProgress(
        budgetLimit: 5000,
        spent: 4000,
        remaining: 1000,
        utilization: 0.8,
        status: 'Safe',
        exceededCategories: ['Shopping'],
        safeCategories: ['Food'],
        categoryBudgetsCount: 2,
      );

      final recommendations = MonthlyAnalyticsEngine.generateRecommendations(
        summary: summary,
        comparison: comparison,
        budgetProgress: budgetProgress,
        categories: [
          const MonthlyCategoryBreakdown(category: 'Food', amount: 3000, percentage: 75.0, transactionCount: 5, trend: 'stable')
        ],
      );

      expect(recommendations, isNotEmpty);
      expect(recommendations.any((r) => r.contains('Savings increased')), true);
      expect(recommendations.any((r) => r.contains('Shopping')), true);
      expect(recommendations.any((r) => r.contains('Food')), true);
    });
  });

  group('MonthlyAggregator Tests', () {
    test('aggregates transactions within calendar month bounds', () {
      final anchor = DateTime(2026, 7, 15);
      final transactions = [
        _tx(id: '1', amount: 5000, type: 'income', date: DateTime(2026, 7, 5)), // in month
        _tx(id: '2', amount: 2000, type: 'expense', date: DateTime(2026, 7, 10), category: 'Food'), // in month
        _tx(id: '3', amount: 1500, type: 'expense', date: DateTime(2026, 7, 20), category: 'Shopping'), // in month
        _tx(id: '4', amount: 1000, type: 'expense', date: DateTime(2026, 6, 25)), // previous month
        _tx(id: '5', amount: 4000, type: 'income', date: DateTime(2026, 8, 2)), // next month
      ];

      final budgets = [
        BudgetEntity(
          uuid: 'b1',
          ownerId: 'u1',
          title: 'Shopping',
          budgetType: 'category',
          amount: 1000,
          categoryId: 'Shopping',
          startDate: DateTime(2026, 7, 1),
          endDate: DateTime(2026, 7, 31),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final report = MonthlyAggregator.aggregate(
        transactions: transactions,
        budgets: budgets,
        monthAnchor: anchor,
      );

      expect(report.monthStart.year, 2026);
      expect(report.monthStart.month, 7);
      expect(report.monthStart.day, 1);
      expect(report.monthEnd.day, 31);

      expect(report.summary.income, 5000.0);
      expect(report.summary.expense, 3500.0);
      expect(report.summary.savings, 1500.0);

      expect(report.statistics.totalTransactions, 3);
      expect(report.statistics.incomeTransactions, 1);
      expect(report.statistics.expenseTransactions, 2);
      expect(report.statistics.largestExpense, 2000.0);
      expect(report.statistics.largestIncome, 5000.0);

      expect(report.categories.length, 2);
      expect(report.categories.first.category, 'Food');
      expect(report.categories.first.amount, 2000.0);

      // Verify budget exceeded category 'Shopping' (spent 1500 > budget 1000)
      expect(report.budgetProgress.exceededCategories.contains('Shopping'), true);
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
