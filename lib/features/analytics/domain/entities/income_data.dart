/// Represents a single income data point on the chart
class IncomePoint {
  final DateTime date;
  final double amount;
  final double runningTotal;

  const IncomePoint({
    required this.date,
    required this.amount,
    required this.runningTotal,
  });
}

/// Represents a category slice in the pie chart
class CategorySlice {
  final String categoryName;
  final double amount;
  final double percentage;

  const CategorySlice({
    required this.categoryName,
    required this.amount,
    required this.percentage,
  });
}

/// Represents an income source (e.g., salary, freelancing)
class SourceSlice {
  final String sourceName;
  final double amount;

  const SourceSlice({
    required this.sourceName,
    required this.amount,
  });
}

/// Represents the largest income transaction
class LargestIncomeInfo {
  final String merchant;
  final double amount;
  final DateTime date;
  final String category;

  const LargestIncomeInfo({
    required this.merchant,
    required this.amount,
    required this.date,
    required this.category,
  });
}

/// Represents smallest income transaction
class SmallestIncomeInfo {
  final String merchant;
  final double amount;
  final DateTime date;
  final String category;

  const SmallestIncomeInfo({
    required this.merchant,
    required this.amount,
    required this.date,
    required this.category,
  });
}

/// Represents income statistics across different time periods
class IncomeStatistics {
  final double totalIncome;
  final double averageIncome;
  final double largestIncome;
  final double smallestIncome;
  final int incomeCount;
  final double averagePerDay;
  final double averagePerWeek;
  final double averagePerMonth;

  const IncomeStatistics({
    required this.totalIncome,
    required this.averageIncome,
    required this.largestIncome,
    required this.smallestIncome,
    required this.incomeCount,
    required this.averagePerDay,
    required this.averagePerWeek,
    required this.averagePerMonth,
  });

  factory IncomeStatistics.empty() {
    return const IncomeStatistics(
      totalIncome: 0.0,
      averageIncome: 0.0,
      largestIncome: 0.0,
      smallestIncome: 0.0,
      incomeCount: 0,
      averagePerDay: 0.0,
      averagePerWeek: 0.0,
      averagePerMonth: 0.0,
    );
  }
}

/// Represents period comparison data
class PeriodComparison {
  final double currentPeriodIncome;
  final double previousPeriodIncome;
  final double growthPercentage;
  final bool isIncrease;

  const PeriodComparison({
    required this.currentPeriodIncome,
    required this.previousPeriodIncome,
    required this.growthPercentage,
    required this.isIncrease,
  });

  factory PeriodComparison.empty() {
    return const PeriodComparison(
      currentPeriodIncome: 0.0,
      previousPeriodIncome: 0.0,
      growthPercentage: 0.0,
      isIncrease: false,
    );
  }
}

/// Represents income data for a specific calendar day
class IncomeCalendarDay {
  final DateTime date;
  final double totalIncome;
  final int incomeCount;

  const IncomeCalendarDay({
    required this.date,
    required this.totalIncome,
    required this.incomeCount,
  });
}

/// Main income report containing all analytics data
class IncomeReport {
  final double totalIncome;
  final double growthPercentage;
  final double averageIncome;
  final double largestIncome;
  final double smallestIncome;
  final int incomeCount;
  final LargestIncomeInfo? largestIncomeInfo;
  final SmallestIncomeInfo? smallestIncomeInfo;
  final List<IncomePoint> points;
  final List<CategorySlice> categories;
  final List<SourceSlice> sources;
  final IncomeStatistics statistics;
  final PeriodComparison comparison;
  final List<IncomeCalendarDay> calendarData;

  const IncomeReport({
    required this.totalIncome,
    required this.growthPercentage,
    required this.averageIncome,
    required this.largestIncome,
    required this.smallestIncome,
    required this.incomeCount,
    this.largestIncomeInfo,
    this.smallestIncomeInfo,
    required this.points,
    required this.categories,
    required this.sources,
    required this.statistics,
    required this.comparison,
    required this.calendarData,
  });

  bool isEmpty([dynamic _]) => totalIncome == 0.0 && incomeCount == 0;

  factory IncomeReport.empty() {
    return IncomeReport(
      totalIncome: 0.0,
      growthPercentage: 0.0,
      averageIncome: 0.0,
      largestIncome: 0.0,
      smallestIncome: 0.0,
      incomeCount: 0,
      largestIncomeInfo: null,
      smallestIncomeInfo: null,
      points: const [],
      categories: const [],
      sources: const [],
      statistics: IncomeStatistics.empty(),
      comparison: PeriodComparison.empty(),
      calendarData: const [],
    );
  }
}
