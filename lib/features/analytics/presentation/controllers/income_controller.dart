import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/income_data.dart';
import '../../domain/repositories/income_repository.dart';

/// Controller for managing income analytics business logic
class IncomeController {
  final IncomeRepository _repository;
  final Ref ref;

  IncomeController(this._repository, this.ref);

  /// Refresh income report data
  Future<void> refreshIncomeReport(String timeFilter) async {
    await _repository.getIncomeReport(timeFilter);
  }

  /// Get growth indicator color (green for increase, red for decrease, grey for neutral)
  String getGrowthIndicator(double growthPercentage) {
    if (growthPercentage > 0) return 'increase';
    if (growthPercentage < 0) return 'decrease';
    return 'neutral';
  }

  /// Format growth text with sign
  String formatGrowthText(double growthPercentage) {
    if (growthPercentage > 0) {
      return '+${growthPercentage.toStringAsFixed(1)}%';
    }
    return '${growthPercentage.toStringAsFixed(1)}%';
  }

  /// Get insights based on income report
  List<String> generateInsights(IncomeReport report) {
    final insights = <String>[];

    // Growth insight
    if (report.comparison.growthPercentage > 20) {
      insights.add('Strong income growth! You\'ve earned ${report.comparison.growthPercentage.toStringAsFixed(1)}% more than last period.');
    } else if (report.comparison.growthPercentage < -20) {
      insights.add('Income declined by ${(-report.comparison.growthPercentage).toStringAsFixed(1)}% compared to last period.');
    }

    // Average income insight
    if (report.statistics.averagePerDay > 0) {
      insights.add('Your average daily income is ₹${report.statistics.averagePerDay.toStringAsFixed(0)}.');
    }

    // Top source insight
    if (report.sources.isNotEmpty) {
      final topSource = report.sources.first;
      final percentage = (topSource.amount / report.totalIncome * 100);
      insights.add('${topSource.sourceName} is your largest income source (${percentage.toStringAsFixed(0)}%).');
    }

    // Income consistency insight
    if (report.incomeCount > 3) {
      final variability = _calculateVariability(report.points);
      if (variability < 20) {
        insights.add('Your income is very consistent.');
      } else if (variability < 50) {
        insights.add('Your income shows moderate variation.');
      } else {
        insights.add('Your income is highly variable.');
      }
    }

    // Largest income insight
    if (report.largestIncomeInfo != null) {
      insights.add('Your largest income was ₹${report.largestIncomeInfo!.amount.toStringAsFixed(0)} from ${report.largestIncomeInfo!.merchant}.');
    }

    return insights;
  }

  /// Calculate income variability (coefficient of variation)
  double _calculateVariability(List<IncomePoint> points) {
    if (points.isEmpty || points.length < 2) return 0.0;

    final amounts = points.map((p) => p.amount).toList();
    final mean = amounts.reduce((a, b) => a + b) / amounts.length;

    if (mean == 0) return 0.0;

    final variance = amounts.map((x) => ((x - mean) * (x - mean))).reduce((a, b) => a + b) / amounts.length;
    final stdDev = variance > 0 ? sqrt(variance) : 0.0;
    final cv = (stdDev / mean) * 100;

    return cv;
  }

  /// Check if income data is empty
  bool isEmpty(IncomeReport report) {
    return report.incomeCount == 0;
  }

  /// Get formatted period label for comparison
  String getPeriodLabel(String timeFilter) {
    switch (timeFilter) {
      case 'today':
        return 'Today vs Yesterday';
      case 'yesterday':
        return 'Yesterday vs Day Before';
      case '7days':
        return 'Last 7 Days vs Previous 7 Days';
      case '30days':
        return 'Last 30 Days vs Previous 30 Days';
      case 'thisMonth':
        return 'This Month vs Last Month';
      case 'lastMonth':
        return 'Last Month vs Two Months Ago';
      case 'thisQuarter':
        return 'This Quarter vs Last Quarter';
      case 'thisYear':
        return 'This Year vs Last Year';
      default:
        return 'Current vs Previous Period';
    }
  }

  /// Check if device is in offline mode (can be extended with connectivity service)
  bool isOfflineMode() {
    // This would be enhanced with actual connectivity check
    return false;
  }
}
