class HealthBreakdown {
  final double savingsScore;
  final double budgetScore;
  final double cashFlowScore;
  final double expenseScore;
  final double incomeScore;
  final double consistencyScore;

  const HealthBreakdown({
    required this.savingsScore,
    required this.budgetScore,
    required this.cashFlowScore,
    required this.expenseScore,
    required this.incomeScore,
    required this.consistencyScore,
  });

  factory HealthBreakdown.zero() => const HealthBreakdown(
        savingsScore: 0.0,
        budgetScore: 0.0,
        cashFlowScore: 0.0,
        expenseScore: 0.0,
        incomeScore: 0.0,
        consistencyScore: 0.0,
      );
}

class HistoricalHealthScore {
  final DateTime date;
  final double overallScore;
  final double savingsScore;
  final double budgetScore;
  final double cashFlowScore;
  final double expenseScore;
  final double incomeScore;
  final double consistencyScore;

  const HistoricalHealthScore({
    required this.date,
    required this.overallScore,
    required this.savingsScore,
    required this.budgetScore,
    required this.cashFlowScore,
    required this.expenseScore,
    required this.incomeScore,
    required this.consistencyScore,
  });
}

class FinancialHealthReport {
  final double overallScore;
  final String rating; // Critical, Poor, Average, Good, Excellent
  final String ratingDescription;
  final String improvementAdvice;
  final HealthBreakdown breakdown;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> recommendations;
  final List<HistoricalHealthScore> historicalScores;
  final bool isEmpty;

  const FinancialHealthReport({
    required this.overallScore,
    required this.rating,
    required this.ratingDescription,
    required this.improvementAdvice,
    required this.breakdown,
    required this.strengths,
    required this.weaknesses,
    required this.recommendations,
    required this.historicalScores,
    this.isEmpty = false,
  });

  factory FinancialHealthReport.empty() => FinancialHealthReport(
        overallScore: 0.0,
        rating: 'Critical',
        ratingDescription: 'Not enough financial data to evaluate health.',
        improvementAdvice: 'Add transactions and budgets to begin tracking.',
        breakdown: HealthBreakdown.zero(),
        strengths: const [],
        weaknesses: const [],
        recommendations: const [],
        historicalScores: const [],
        isEmpty: true,
      );
}
