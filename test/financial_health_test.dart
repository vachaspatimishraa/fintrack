import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/analytics/domain/entities/financial_health_data.dart';
import 'package:fintrack/features/analytics/domain/utils/health_score_calculator.dart';
import 'package:fintrack/features/analytics/domain/utils/recommendation_engine.dart';
import 'package:fintrack/features/analytics/domain/utils/financial_health_engine.dart';
import 'package:fintrack/features/budget/domain/entities/budget_entity.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_entity.dart';

void main() {
  group('HealthScoreCalculator Tests', () {
    test('calculates savings score accurately', () {
      expect(HealthScoreCalculator.calculateSavingsScore(10000, 7000), 100.0); // 30% savings rate
      expect(HealthScoreCalculator.calculateSavingsScore(10000, 8000), 80.0); // 20% savings rate
      expect(HealthScoreCalculator.calculateSavingsScore(10000, 9500), 40.0); // <10% savings rate
      expect(HealthScoreCalculator.calculateSavingsScore(10000, 12000), lessThan(40.0)); // Negative savings
    });

    test('calculates budget score correctly based on limits', () {
      final List<TransactionEntity> transactions = [
        _tx(id: '1', amount: 3000, type: 'expense', category: 'Food', date: DateTime.now()),
        _tx(id: '2', amount: 1500, type: 'expense', category: 'Shopping', date: DateTime.now()),
      ];

      final budgets = [
        BudgetEntity(
          uuid: 'b1',
          ownerId: 'u1',
          title: 'Food Budget',
          budgetType: 'category',
          amount: 2000, // Exceeded
          categoryId: 'Food',
          startDate: DateTime.now(),
          endDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        BudgetEntity(
          uuid: 'b2',
          ownerId: 'u1',
          title: 'Shopping Budget',
          budgetType: 'category',
          amount: 2000, // Under limit
          categoryId: 'Shopping',
          startDate: DateTime.now(),
          endDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final score = HealthScoreCalculator.calculateBudgetScore(transactions, budgets);
      expect(score, 50.0); // 1 out of 2 succeeded
    });

    test('calculates expense control score', () {
      expect(HealthScoreCalculator.calculateExpenseScore(10000, 4000), 100.0); // 40% ratio
      expect(HealthScoreCalculator.calculateExpenseScore(10000, 6000), 85.0); // 60% ratio
      expect(HealthScoreCalculator.calculateExpenseScore(10000, 11000), lessThan(50.0)); // Over spending
    });

    test('calculates cash flow score', () {
      expect(HealthScoreCalculator.calculateCashFlowScore(10000, 9000), 100.0); // Positive cash flow
      expect(HealthScoreCalculator.calculateCashFlowScore(10000, 10000), 50.0); // Balanced cash flow
      expect(HealthScoreCalculator.calculateCashFlowScore(10000, 12000), lessThan(50.0)); // Deficit
    });

    test('calculates overall score using weighted averages', () {
      final overall = HealthScoreCalculator.calculateOverallScore(
        savings: 80,
        budget: 50,
        cashFlow: 100,
        expense: 85,
        income: 60,
        consistency: 80,
      );
      // Expected: (80 * 0.25) + (50 * 0.20) + (100 * 0.20) + (85 * 0.15) + (60 * 0.10) + (80 * 0.10)
      // 20 + 10 + 20 + 12.75 + 6 + 8 = 76.75
      expect(overall, 76.75);
    });
  });

  group('RecommendationEngine Tests', () {
    test('identifies correct strengths and weaknesses', () {
      const breakdown = HealthBreakdown(
        savingsScore: 80.0,
        budgetScore: 50.0,
        cashFlowScore: 100.0,
        expenseScore: 85.0,
        incomeScore: 60.0,
        consistencyScore: 40.0,
      );

      final strengths = <String>[];
      final weaknesses = <String>[];
      final recommendations = <String>[];

      RecommendationEngine.analyze(
        breakdown: breakdown,
        strengths: strengths,
        weaknesses: weaknesses,
        recommendations: recommendations,
      );

      expect(strengths.any((s) => s.contains('Savings')), true);
      expect(strengths.any((s) => s.contains('Cash Flow')), true);
      expect(weaknesses.any((w) => w.contains('Overspending')), true);
      expect(weaknesses.any((w) => w.contains('Inconsistent')), true);
      expect(recommendations.isNotEmpty, true);
    });
  });

  group('FinancialHealthEngine Tests', () {
    test('evaluates data and creates complete report', () {
      final now = DateTime.now();
      final transactions = [
        _tx(id: '1', amount: 10000, type: 'income', date: now),
        _tx(id: '2', amount: 4000, type: 'expense', date: now),
      ];

      final report = FinancialHealthEngine.evaluate(transactions: transactions, budgets: const []);
      expect(report.isEmpty, false);
      expect(report.overallScore, greaterThan(50));
      expect(report.rating, anyOf('Excellent', 'Good', 'Average'));
      expect(report.historicalScores.length, 6);
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
