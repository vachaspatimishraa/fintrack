import '../../../transactions/domain/entities/transaction_entity.dart';
import '../entities/ai_insight_data.dart';

class PatternDetectionService {
  const PatternDetectionService._();

  static List<AISpendingPattern> detect(List<TransactionEntity> transactions) {
    final activeTx = transactions.where((tx) => !tx.isDeleted).toList();
    if (activeTx.isEmpty) return const [];

    final patterns = <AISpendingPattern>[];

    // 1. Category Dependence Alert
    final expenses = activeTx.where((tx) => tx.type == 'expense').toList();
    if (expenses.isNotEmpty) {
      final categorySums = <String, double>{};
      double totalExpense = 0.0;
      for (final tx in expenses) {
        categorySums[tx.category] = (categorySums[tx.category] ?? 0) + tx.amount;
        totalExpense += tx.amount;
      }

      final sortedCategories = categorySums.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      if (sortedCategories.isNotEmpty && totalExpense > 0) {
        final primary = sortedCategories.first;
        final ratio = primary.value / totalExpense;
        if (ratio >= 0.40) {
          patterns.add(
            AISpendingPattern(
              name: 'Category Dependence Alert',
              description: 'Your spending is heavily concentrated in "${primary.key}". It constitutes ${(ratio * 100).toStringAsFixed(0)}% of your overall monthly expenses.',
              frequency: 'Critical',
              averageAmount: primary.value,
              category: primary.key,
            ),
          );
        }
      }
    }

    // 2. Weekend Spending Peak
    if (expenses.isNotEmpty) {
      double weekendSum = 0;
      int weekendCount = 0;
      double weekdaySum = 0;
      int weekdayCount = 0;

      for (final tx in expenses) {
        final day = tx.date.weekday;
        if (day == DateTime.friday || day == DateTime.saturday || day == DateTime.sunday) {
          weekendSum += tx.amount;
          weekendCount++;
        } else {
          weekdaySum += tx.amount;
          weekdayCount++;
        }
      }

      final avgWeekend = weekendCount > 0 ? weekendSum / weekendCount : 0.0;
      final avgWeekday = weekdayCount > 0 ? weekdaySum / weekdayCount : 0.0;

      if (avgWeekend > avgWeekday * 1.5 && avgWeekend > 500) {
        patterns.add(
          AISpendingPattern(
            name: 'Weekend Spending Peak',
            description: 'Your average weekend expense (₹${avgWeekend.toStringAsFixed(0)}) is ${( (avgWeekend - avgWeekday) / (avgWeekday > 0 ? avgWeekday : 1) * 100).toStringAsFixed(0)}% higher than your weekday average.',
            frequency: 'Weekly',
            averageAmount: avgWeekend,
            category: 'General',
          ),
        );
      }
    }

    // 3. Salary Day Spike
    final incomeTx = activeTx.where((tx) => tx.type == 'income').toList();
    if (incomeTx.isNotEmpty && expenses.isNotEmpty) {
      double postSalaryExpenseSum = 0.0;
      int count = 0;

      for (final inc in incomeTx) {
        final salaryDate = inc.date;
        final limitDate = salaryDate.add(const Duration(days: 3));

        final postSalaryTx = expenses.where((tx) => tx.date.isAfter(salaryDate) && tx.date.isBefore(limitDate));
        for (final tx in postSalaryTx) {
          postSalaryExpenseSum += tx.amount;
          count++;
        }
      }

      if (count > 0 && (postSalaryExpenseSum / count) > 2000) {
        patterns.add(
          AISpendingPattern(
            name: 'Salary Day Spike',
            description: 'Increased spending activity detected within 3 days of receiving deposits. Keep an eye on impulse purchases.',
            frequency: 'Monthly',
            averageAmount: postSalaryExpenseSum / count,
            category: 'Behavior',
          ),
        );
      }
    }

    return patterns;
  }
}
