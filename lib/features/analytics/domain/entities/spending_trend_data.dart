enum TrendDirection { increasing, stable, declining }

enum TrendGranularity { daily, weekly, monthly, yearly }

class SpendingTrendPoint {
  final DateTime periodStart;
  final DateTime periodEnd;
  final double amount;
  final double previousAmount;
  final double difference;
  final double growthPercentage;
  final double movingAverage;
  final int transactionCount;
  final TrendDirection direction;

  const SpendingTrendPoint({
    required this.periodStart,
    required this.periodEnd,
    required this.amount,
    required this.previousAmount,
    required this.difference,
    required this.growthPercentage,
    required this.movingAverage,
    required this.transactionCount,
    required this.direction,
  });
}

class TrendSummary {
  final double currentSpending;
  final double previousSpending;
  final double growthPercentage;
  final double velocity;
  final double momentum;
  final double confidence;
  final TrendDirection direction;
  final String description;

  const TrendSummary({
    required this.currentSpending,
    required this.previousSpending,
    required this.growthPercentage,
    required this.velocity,
    required this.momentum,
    required this.confidence,
    required this.direction,
    required this.description,
  });

  factory TrendSummary.empty() => const TrendSummary(
        currentSpending: 0,
        previousSpending: 0,
        growthPercentage: 0,
        velocity: 0,
        momentum: 0,
        confidence: 0,
        direction: TrendDirection.stable,
        description: 'No spending trend available',
      );
}

class SpendingPeriodInsight {
  final String label;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double amount;
  final int transactionCount;

  const SpendingPeriodInsight({
    required this.label,
    required this.periodStart,
    required this.periodEnd,
    required this.amount,
    required this.transactionCount,
  });
}

class TrendComparison {
  final String label;
  final double currentAmount;
  final double previousAmount;
  final double difference;
  final double growthPercentage;
  final TrendDirection direction;

  const TrendComparison({
    required this.label,
    required this.currentAmount,
    required this.previousAmount,
    required this.difference,
    required this.growthPercentage,
    required this.direction,
  });
}

class SpendingForecast {
  final DateTime periodStart;
  final DateTime periodEnd;
  final double expectedSpending;
  final double confidenceScore;
  final TrendDirection direction;

  const SpendingForecast({
    required this.periodStart,
    required this.periodEnd,
    required this.expectedSpending,
    required this.confidenceScore,
    required this.direction,
  });

  factory SpendingForecast.empty() {
    final now = DateTime.now();
    return SpendingForecast(
      periodStart: now,
      periodEnd: now,
      expectedSpending: 0,
      confidenceScore: 0,
      direction: TrendDirection.stable,
    );
  }
}

class SpendingHabitIndicators {
  final bool regularSpending;
  final bool impulseSpending;
  final bool weekendPeaks;
  final bool salaryDaySpending;
  final bool subscriptionPatterns;
  final List<String> recommendations;

  const SpendingHabitIndicators({
    required this.regularSpending,
    required this.impulseSpending,
    required this.weekendPeaks,
    required this.salaryDaySpending,
    required this.subscriptionPatterns,
    required this.recommendations,
  });

  factory SpendingHabitIndicators.empty() => const SpendingHabitIndicators(
        regularSpending: false,
        impulseSpending: false,
        weekendPeaks: false,
        salaryDaySpending: false,
        subscriptionPatterns: false,
        recommendations: [],
      );
}

class SpendingTrendReport {
  final double totalSpending;
  final int transactionCount;
  final TrendGranularity granularity;
  final TrendSummary summary;
  final List<SpendingTrendPoint> points;
  final List<SpendingPeriodInsight> peakPeriods;
  final List<SpendingPeriodInsight> lowPeriods;
  final List<TrendComparison> comparisons;
  final SpendingForecast forecast;
  final SpendingHabitIndicators habits;

  const SpendingTrendReport({
    required this.totalSpending,
    required this.transactionCount,
    required this.granularity,
    required this.summary,
    required this.points,
    required this.peakPeriods,
    required this.lowPeriods,
    required this.comparisons,
    required this.forecast,
    required this.habits,
  });

  factory SpendingTrendReport.empty({
    TrendGranularity granularity = TrendGranularity.daily,
  }) =>
      SpendingTrendReport(
        totalSpending: 0,
        transactionCount: 0,
        granularity: granularity,
        summary: TrendSummary.empty(),
        points: const [],
        peakPeriods: const [],
        lowPeriods: const [],
        comparisons: const [],
        forecast: SpendingForecast.empty(),
        habits: SpendingHabitIndicators.empty(),
      );

  bool get isEmpty => transactionCount == 0 || points.isEmpty;
}
