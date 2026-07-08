import '../entities/income_data.dart';

/// Service for managing running income (accumulated income)
class RunningIncomeService {
  /// Calculate running total income from a list of income points
  ///
  /// Formula: Previous Total + Current Income
  static double getRunningTotal(List<IncomePoint> points, int index) {
    if (index < 0 || index >= points.length) return 0.0;
    return points[index].runningTotal;
  }

  /// Get cumulative income up to a specific date
  static double getCumulativeIncomeUpTo(List<IncomePoint> points, DateTime date) {
    for (final point in points.reversed) {
      if (point.date.isBefore(date) || point.date.isAtSameMomentAs(date)) {
        return point.runningTotal;
      }
    }
    return 0.0;
  }

  /// Calculate average running income
  static double getAverageRunningIncome(List<IncomePoint> points) {
    if (points.isEmpty) return 0.0;
    final totalRunning = points.fold(0.0, (sum, point) => sum + point.runningTotal);
    return totalRunning / points.length;
  }

  /// Get running income growth
  static double getRunningIncomeGrowth(List<IncomePoint> points) {
    if (points.length < 2) return 0.0;
    final firstValue = points.first.runningTotal;
    final lastValue = points.last.runningTotal;
    return lastValue - firstValue;
  }

  /// Get running income growth percentage
  static double getRunningIncomeGrowthPercentage(List<IncomePoint> points) {
    if (points.length < 2 || points.first.runningTotal == 0) return 0.0;
    final firstValue = points.first.runningTotal;
    final lastValue = points.last.runningTotal;
    return ((lastValue - firstValue) / firstValue) * 100;
  }

  /// Build running income summary for a period
  static IncomeRunningIncomeSummary buildSummary(List<IncomePoint> points) {
    if (points.isEmpty) {
      return IncomeRunningIncomeSummary(
        startingBalance: 0.0,
        endingBalance: 0.0,
        totalAdded: 0.0,
        growthAmount: 0.0,
        growthPercentage: 0.0,
        averageRunningIncome: 0.0,
      );
    }

    final startingBalance = points.first.runningTotal - points.first.amount;
    final endingBalance = points.last.runningTotal;
    final totalAdded = points.fold(0.0, (sum, point) => sum + point.amount);
    final growthAmount = endingBalance - startingBalance;
    final growthPercentage = startingBalance > 0 ? (growthAmount / startingBalance) * 100 : 0.0;
    final averageRunningIncome = getAverageRunningIncome(points);

    return IncomeRunningIncomeSummary(
      startingBalance: startingBalance,
      endingBalance: endingBalance,
      totalAdded: totalAdded,
      growthAmount: growthAmount,
      growthPercentage: growthPercentage,
      averageRunningIncome: averageRunningIncome,
    );
  }

  /// Get projected income at a future date based on current trend
  static double projectFutureIncome(List<IncomePoint> points, Duration daysAhead) {
    if (points.length < 2) return 0.0;

    final currentRunningIncome = points.last.runningTotal;
    final previousPoint = points[points.length - 2];
    final dailyIncomeRate = (points.last.amount + previousPoint.amount) / 2;
    final projectedDays = daysAhead.inDays;

    return currentRunningIncome + (dailyIncomeRate * projectedDays);
  }
}

/// Summary of running income data
class IncomeRunningIncomeSummary {
  final double startingBalance;
  final double endingBalance;
  final double totalAdded;
  final double growthAmount;
  final double growthPercentage;
  final double averageRunningIncome;

  const IncomeRunningIncomeSummary({
    required this.startingBalance,
    required this.endingBalance,
    required this.totalAdded,
    required this.growthAmount,
    required this.growthPercentage,
    required this.averageRunningIncome,
  });
}
