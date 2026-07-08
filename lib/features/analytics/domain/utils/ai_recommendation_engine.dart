import '../../../transactions/domain/entities/transaction_entity.dart';
import '../entities/ai_insight_data.dart';
import 'confidence_calculator.dart';

class AIRecommendationEngine {
  const AIRecommendationEngine._();

  static List<AIInsight> generate({
    required List<TransactionEntity> transactions,
  }) {
    final activeTx = transactions.where((tx) => !tx.isDeleted).toList();
    if (activeTx.isEmpty) return const [];

    final list = <AIInsight>[];
    final confidence = ConfidenceCalculator.calculate(activeTx);
    final now = DateTime.now();

    // 1. Deficit check
    double income = 0.0;
    double expense = 0.0;
    for (final tx in activeTx.where((tx) => tx.date.year == now.year && tx.date.month == now.month)) {
      if (tx.type == 'income') income += tx.amount;
      if (tx.type == 'expense') expense += tx.amount;
    }

    if (expense > income && income > 0) {
      list.add(
        AIInsight(
          id: 'insight-deficit-warning',
          title: 'Deficit Alert Detected',
          description: 'Your expenses (₹${expense.toStringAsFixed(0)}) have exceeded your income (₹${income.toStringAsFixed(0)}) this month by ₹${(expense - income).toStringAsFixed(0)}.',
          category: 'Cash Flow',
          severity: 'Critical',
          confidence: confidence,
          generatedAt: DateTime.now(),
        ),
      );
    }

    // 2. High Category Spending check
    final categorySums = <String, double>{};
    for (final tx in activeTx.where((tx) => tx.type == 'expense' && tx.date.year == now.year && tx.date.month == now.month)) {
      categorySums[tx.category] = (categorySums[tx.category] ?? 0) + tx.amount;
    }

    categorySums.forEach((category, sum) {
      if (sum > 5000) {
        list.add(
          AIInsight(
            id: 'insight-high-category-$category',
            title: 'High Spending in $category',
            description: 'You spent ₹${sum.toStringAsFixed(0)} in $category this month. Consider setting up a budget limit to trim this down.',
            category: 'Expenses',
            severity: 'Warning',
            confidence: confidence,
            generatedAt: DateTime.now(),
          ),
        );
      }
    });

    // 3. Positive reinforcement
    if (income > expense && expense > 0) {
      final rate = ((income - expense) / income) * 100;
      list.add(
        AIInsight(
          id: 'insight-savings-positive',
          title: 'Healthy Savings Rate',
          description: 'Great job! You saved ${rate.toStringAsFixed(0)}% of your income this month.',
          category: 'Savings',
          severity: 'Positive',
          confidence: confidence,
          generatedAt: DateTime.now(),
        ),
      );
    }

    // Default insight if empty
    if (list.isEmpty) {
      list.add(
        AIInsight(
          id: 'insight-default-educational',
          title: 'Start Tracking Habits',
          description: 'Keep logging transactions daily to let the AI engines recognize your weekend peaks and salary spikes.',
          category: 'Financial Health',
          severity: 'Positive',
          confidence: 1.0,
          generatedAt: DateTime.now(),
        ),
      );
    }

    return list;
  }
}
