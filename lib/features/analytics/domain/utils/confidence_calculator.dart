import '../../../transactions/domain/entities/transaction_entity.dart';

class ConfidenceCalculator {
  const ConfidenceCalculator._();

  static double calculate(List<TransactionEntity> transactions) {
    final activeTx = transactions.where((tx) => !tx.isDeleted).toList();
    if (activeTx.isEmpty) return 0.0;

    double confidence = 0.3; // Baseline confidence

    // Data Completeness factor (up to 0.3)
    final completionScore = (activeTx.length / 50.0).clamp(0.0, 1.0) * 0.3;
    confidence += completionScore;

    // Time Span factor (up to 0.2)
    final months = <String>{};
    for (final tx in activeTx) {
      months.add('${tx.date.year}-${tx.date.month}');
    }
    final timeSpanScore = (months.length / 6.0).clamp(0.0, 1.0) * 0.2;
    confidence += timeSpanScore;

    // Pattern Stability factor (up to 0.2)
    // Check if logging is balanced or highly sparse
    final weeklyCounts = <int, int>{};
    for (final tx in activeTx) {
      final week = ((tx.date.day - 1) / 7).floor();
      weeklyCounts[week] = (weeklyCounts[week] ?? 0) + 1;
    }
    if (weeklyCounts.length >= 2) {
      confidence += 0.2;
    } else {
      confidence += 0.05;
    }

    return confidence.clamp(0.0, 1.0);
  }
}
