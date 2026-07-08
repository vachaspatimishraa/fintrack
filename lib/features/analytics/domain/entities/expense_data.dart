/// Represents a single expense data point on the chart
class ExpensePoint {
  final DateTime date;
  final double amount;
  final double runningTotal;

  const ExpensePoint({
    required this.date,
    required this.amount,
    required this.runningTotal,
  });
}

/// Represents a category slice in the pie chart
class ExpenseCategorySlice {
  final String categoryName;
  final double amount;
  final double percentage;
  final int transactionCount;

  const ExpenseCategorySlice({
    required this.categoryName,
    required this.amount,
    required this.percentage,
    required this.transactionCount,
  });
}

/// Represents an expense merchant
class MerchantSlice {
  final String merchantName;
  final double amount;
  final int transactionCount;
  final double percentage;

  const MerchantSlice({
    required this.merchantName,
    required this.amount,
    required this.transactionCount,
    required this.percentage,
  });
}

/// Represents the highest expense transaction
class HighestExpenseInfo {
  final String merchant;
  final double amount;
  final DateTime date;
  final String category;

  const HighestExpenseInfo({
    required this.merchant,
    required this.amount,
    required this.date,
    required this.category,
  });
}

/// Represents the lowest expense transaction
class LowestExpenseInfo {
  final String merchant;
  final double amount;
  final DateTime date;
  final String category;

  const LowestExpenseInfo({
    required this.merchant,
    required this.amount,
    required this.date,
    required this.category,
  });
}

/// Represents unusual/anomalous expenses
class UnusualExpense {
  final String merchant;
  final double amount;
  final DateTime date;
  final String category;
  final double zScore; // Standard deviations from mean
  final String reason; // Why it's unusual

  const UnusualExpense({
    required this.merchant,
    required this.amount,
    required this.date,
    required this.category,
    required this.zScore,
    required this.reason,
  });
}

/// Represents expense statistics across different time periods
class ExpenseStatistics {
  final double totalExpense;
  final double averageExpense;
  final double highestExpense;
  final double lowestExpense;
  final int expenseCount;
  final double averagePerDay;
  final double averagePerWeek;
  final double averagePerMonth;
  final double medianExpense;
  final double standardDeviation;

  const ExpenseStatistics({
    required this.totalExpense,
    required this.averageExpense,
    required this.highestExpense,
    required this.lowestExpense,
    required this.expenseCount,
    required this.averagePerDay,
    required this.averagePerWeek,
    required this.averagePerMonth,
    required this.medianExpense,
    required this.standardDeviation,
  });

  factory ExpenseStatistics.empty() {
    return const ExpenseStatistics(
      totalExpense: 0.0,
      averageExpense: 0.0,
      highestExpense: 0.0,
      lowestExpense: 0.0,
      expenseCount: 0,
      averagePerDay: 0.0,
      averagePerWeek: 0.0,
      averagePerMonth: 0.0,
      medianExpense: 0.0,
      standardDeviation: 0.0,
    );
  }
}

/// Represents period comparison data
class ExpensePeriodComparison {
  final double currentPeriodExpense;
  final double previousPeriodExpense;
  final double growthPercentage;
  final bool isIncreasing;

  const ExpensePeriodComparison({
    required this.currentPeriodExpense,
    required this.previousPeriodExpense,
    required this.growthPercentage,
    required this.isIncreasing,
  });

  factory ExpensePeriodComparison.empty() {
    return const ExpensePeriodComparison(
      currentPeriodExpense: 0.0,
      previousPeriodExpense: 0.0,
      growthPercentage: 0.0,
      isIncreasing: false,
    );
  }
}

/// Represents expense data for a specific calendar day
class ExpenseCalendarDay {
  final DateTime date;
  final double totalExpense;
  final int expenseCount;
  final String topCategory;

  const ExpenseCalendarDay({
    required this.date,
    required this.totalExpense,
    required this.expenseCount,
    required this.topCategory,
  });
}

/// Represents spending heatmap data
class SpendingHeatmapData {
  final DateTime date;
  final double amount;
  final int intensity; // 0-10 scale for heatmap color

  const SpendingHeatmapData({
    required this.date,
    required this.amount,
    required this.intensity,
  });
}

/// Represents expense health score
class ExpenseHealthScore {
  final double score; // 0-100
  final String grade; // A+, A, B+, B, C+, C, D, F
  final String status; // Excellent, Good, Fair, Poor, Critical
  final String recommendation;
  final List<String> insights;

  const ExpenseHealthScore({
    required this.score,
    required this.grade,
    required this.status,
    required this.recommendation,
    required this.insights,
  });
}

/// Represents recurring expense pattern
class RecurringExpensePattern {
  final String merchant;
  final String category;
  final double averageAmount;
  final int frequency; // days between occurrences
  final DateTime nextExpected;
  final int confidence; // 0-100

  const RecurringExpensePattern({
    required this.merchant,
    required this.category,
    required this.averageAmount,
    required this.frequency,
    required this.nextExpected,
    required this.confidence,
  });
}

/// Main expense report containing all analytics data
class ExpenseReport {
  final double totalExpense;
  final double growthPercentage;
  final double averageExpense;
  final double highestExpense;
  final double lowestExpense;
  final int expenseCount;
  final HighestExpenseInfo? highestExpenseInfo;
  final LowestExpenseInfo? lowestExpenseInfo;
  final List<ExpensePoint> points;
  final List<ExpenseCategorySlice> categories;
  final List<MerchantSlice> merchants;
  final ExpenseStatistics statistics;
  final ExpensePeriodComparison comparison;
  final List<ExpenseCalendarDay> calendarData;
  final List<UnusualExpense> unusualExpenses;
  final List<RecurringExpensePattern> recurringPatterns;
  final ExpenseHealthScore healthScore;
  final List<SpendingHeatmapData> heatmapData;

  const ExpenseReport({
    required this.totalExpense,
    required this.growthPercentage,
    required this.averageExpense,
    required this.highestExpense,
    required this.lowestExpense,
    required this.expenseCount,
    this.highestExpenseInfo,
    this.lowestExpenseInfo,
    required this.points,
    required this.categories,
    required this.merchants,
    required this.statistics,
    required this.comparison,
    required this.calendarData,
    required this.unusualExpenses,
    required this.recurringPatterns,
    required this.healthScore,
    required this.heatmapData,
  });

  factory ExpenseReport.empty() {
    return ExpenseReport(
      totalExpense: 0.0,
      growthPercentage: 0.0,
      averageExpense: 0.0,
      highestExpense: 0.0,
      lowestExpense: 0.0,
      expenseCount: 0,
      highestExpenseInfo: null,
      lowestExpenseInfo: null,
      points: const [],
      categories: const [],
      merchants: const [],
      statistics: ExpenseStatistics.empty(),
      comparison: ExpensePeriodComparison.empty(),
      calendarData: const [],
      unusualExpenses: const [],
      recurringPatterns: const [],
      healthScore: const ExpenseHealthScore(
        score: 0,
        grade: 'F',
        status: 'Critical',
        recommendation: 'No data available',
        insights: [],
      ),
      heatmapData: const [],
    );
  }
}
