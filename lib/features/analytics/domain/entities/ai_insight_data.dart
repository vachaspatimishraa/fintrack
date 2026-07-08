class AIInsight {
  final String id;
  final String title;
  final String description;
  final String category; // Savings, Budget, Income, Expenses, Cash Flow
  final String severity; // Positive, Warning, Critical, Recommendation, Forecast
  final double confidence; // 0.0 to 1.0
  final DateTime generatedAt;
  final bool dismissed;
  final bool pinned;
  final bool viewed;

  const AIInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.severity,
    required this.confidence,
    required this.generatedAt,
    this.dismissed = false,
    this.pinned = false,
    this.viewed = false,
  });

  AIInsight copyWith({
    bool? dismissed,
    bool? pinned,
    bool? viewed,
  }) {
    return AIInsight(
      id: id,
      title: title,
      description: description,
      category: category,
      severity: severity,
      confidence: confidence,
      generatedAt: generatedAt,
      dismissed: dismissed ?? this.dismissed,
      pinned: pinned ?? this.pinned,
      viewed: viewed ?? this.viewed,
    );
  }
}

class AIForecast {
  final double remainingMonthExpenses;
  final double expectedSavings;
  final double budgetCompletionRate;
  final double projectedCashFlow;

  const AIForecast({
    required this.remainingMonthExpenses,
    required this.expectedSavings,
    required this.budgetCompletionRate,
    required this.projectedCashFlow,
  });

  factory AIForecast.zero() => const AIForecast(
        remainingMonthExpenses: 0.0,
        expectedSavings: 0.0,
        budgetCompletionRate: 0.0,
        projectedCashFlow: 0.0,
      );
}

class AISpendingPattern {
  final String name;
  final String description;
  final String frequency;
  final double averageAmount;
  final String category;

  const AISpendingPattern({
    required this.name,
    required this.description,
    required this.frequency,
    required this.averageAmount,
    required this.category,
  });
}

class AIInsightsReport {
  final List<AIInsight> currentInsights;
  final AIForecast forecast;
  final List<AISpendingPattern> detectedPatterns;
  final bool isEmpty;

  const AIInsightsReport({
    required this.currentInsights,
    required this.forecast,
    required this.detectedPatterns,
    this.isEmpty = false,
  });

  factory AIInsightsReport.empty() => AIInsightsReport(
        currentInsights: const [],
        forecast: AIForecast.zero(),
        detectedPatterns: const [],
        isEmpty: true,
      );
}
