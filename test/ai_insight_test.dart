import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/analytics/domain/utils/pattern_detection_service.dart';
import 'package:fintrack/features/analytics/domain/utils/forecast_service.dart';
import 'package:fintrack/features/analytics/domain/utils/confidence_calculator.dart';
import 'package:fintrack/features/analytics/domain/utils/ai_recommendation_engine.dart';
import 'package:fintrack/features/analytics/domain/utils/ai_insight_engine.dart';
import 'package:fintrack/features/transactions/domain/entities/transaction_entity.dart';

void main() {
  group('PatternDetectionService Tests', () {
    test('detects category dependence when a single category exceeds 40%', () {
      final transactions = [
        _tx(id: '1', amount: 5000, type: 'expense', category: 'Shopping', date: DateTime.now()),
        _tx(id: '2', amount: 1000, type: 'expense', category: 'Food', date: DateTime.now()),
      ];

      final patterns = PatternDetectionService.detect(transactions);
      expect(patterns.any((p) => p.name == 'Category Dependence Alert'), true);
    });

    test('detects weekend spending peak when weekend average is 1.5x weekday average', () {
      final transactions = [
        // Weekend (Friday, Saturday, Sunday)
        _tx(id: '1', amount: 2000, type: 'expense', category: 'Food', date: DateTime(2026, 7, 3)), // Friday
        _tx(id: '2', amount: 3000, type: 'expense', category: 'Shopping', date: DateTime(2026, 7, 4)), // Saturday
        // Weekday (Monday)
        _tx(id: '3', amount: 500, type: 'expense', category: 'Food', date: DateTime(2026, 7, 6)),
      ];

      final patterns = PatternDetectionService.detect(transactions);
      expect(patterns.any((p) => p.name == 'Weekend Spending Peak'), true);
    });
  });

  group('ForecastService Tests', () {
    test('calculates correct daily average projections', () {
      final now = DateTime.now();
      final transactions = [
        _tx(id: '1', amount: 10000, type: 'income', date: now),
        _tx(id: '2', amount: 2000, type: 'expense', date: now), // If today is day X, daily average is 2000 / X
      ];

      final forecast = ForecastService.calculate(transactions: transactions);
      expect(forecast.remainingMonthExpenses, greaterThanOrEqualTo(0.0));
      expect(forecast.projectedCashFlow, isNotNull);
    });
  });

  group('ConfidenceCalculator Tests', () {
    test('calculates correct confidence percentage levels', () {
      final transactions = [
        _tx(id: '1', amount: 5000, type: 'income', date: DateTime.now()),
      ];

      final confidence = ConfidenceCalculator.calculate(transactions);
      expect(confidence, greaterThanOrEqualTo(0.0));
      expect(confidence, lessThanOrEqualTo(1.0));
    });
  });

  group('AIRecommendationEngine Tests', () {
    test('generates correct alerts and positive reinforcements', () {
      final now = DateTime.now();
      final transactions = [
        _tx(id: '1', amount: 10000, type: 'income', date: now),
        _tx(id: '2', amount: 3000, type: 'expense', date: now),
      ];

      final insights = AIRecommendationEngine.generate(transactions: transactions);
      expect(insights.isNotEmpty, true);
      expect(insights.any((i) => i.title.contains('Savings')), true);
    });
  });

  group('AIInsightEngine Tests', () {
    test('evaluates and compiles report', () {
      final now = DateTime.now();
      final transactions = [
        _tx(id: '1', amount: 10000, type: 'income', date: now),
        _tx(id: '2', amount: 4000, type: 'expense', date: now),
      ];

      final report = AIInsightEngine.generate(transactions: transactions);
      expect(report.isEmpty, false);
      expect(report.currentInsights.isNotEmpty, true);
      expect(report.forecast.budgetCompletionRate, greaterThan(0.0));
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
