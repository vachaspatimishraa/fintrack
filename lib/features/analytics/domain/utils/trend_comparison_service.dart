import '../entities/spending_trend_data.dart';
import 'velocity_calculator.dart';

class TrendComparisonService {
  const TrendComparisonService._();

  static double growthPercentage(double current, double previous) {
    if (previous == 0) return current > 0 ? 100 : 0;
    return ((current - previous) / previous) * 100;
  }

  static TrendDirection directionFor(double growthPercentage) {
    if (growthPercentage > 5) return TrendDirection.increasing;
    if (growthPercentage < -5) return TrendDirection.declining;
    return TrendDirection.stable;
  }

  static TrendComparison compare({
    required String label,
    required double current,
    required double previous,
  }) {
    final difference = VelocityCalculator.calculate(current, previous);
    final growth = growthPercentage(current, previous);
    return TrendComparison(
      label: label,
      currentAmount: current,
      previousAmount: previous,
      difference: difference,
      growthPercentage: growth,
      direction: directionFor(growth),
    );
  }
}
