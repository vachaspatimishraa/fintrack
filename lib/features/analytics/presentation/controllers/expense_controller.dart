import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/expense_data.dart';
import '../../domain/repositories/expense_repository.dart';

/// Controller for managing expense analytics business logic
class ExpenseController {
  final ExpenseRepository _repository;
  final Ref ref;

  ExpenseController(this._repository, this.ref);

  /// Refresh expense report data
  Future<void> refreshExpenseReport(String timeFilter) async {
    await _repository.getExpenseReport(timeFilter);
  }

  /// Get spending indicator color (red for increase, green for decrease)
  String getSpendingIndicator(double growthPercentage) {
    if (growthPercentage > 0) return 'increase';
    if (growthPercentage < 0) return 'decrease';
    return 'neutral';
  }

  /// Format spending change text with sign
  String formatSpendingChangeText(double growthPercentage) {
    if (growthPercentage > 0) {
      return '+${growthPercentage.toStringAsFixed(1)}%';
    }
    return '${growthPercentage.toStringAsFixed(1)}%';
  }

  /// Generate expense insights
  List<String> generateInsights(ExpenseReport report) {
    final insights = <String>[];

    // Growth insight
    if (report.comparison.growthPercentage > 15) {
      insights.add(
        'Expenses increased by ${report.comparison.growthPercentage.toStringAsFixed(1)}% compared to last period - monitor this trend.',
      );
    } else if (report.comparison.growthPercentage < -15) {
      insights.add(
        'Great job! Expenses decreased by ${(-report.comparison.growthPercentage).toStringAsFixed(1)}%.',
      );
    }

    // Average expense insight
    if (report.statistics.averagePerDay > 0) {
      insights.add(
        'Your average daily spending is ₹${report.statistics.averagePerDay.toStringAsFixed(0)}.',
      );
    }

    // Top category insight
    if (report.categories.isNotEmpty) {
      final topCategory = report.categories.first;
      insights.add(
        'Top expense: ${topCategory.categoryName} (${topCategory.percentage.toStringAsFixed(0)}% of spending)',
      );
    }

    // Unusual expense insight
    if (report.unusualExpenses.isNotEmpty) {
      final highestUnusual = report.unusualExpenses.first;
      insights.add(
        'Unusual expense detected: ₹${highestUnusual.amount.toStringAsFixed(0)} at ${highestUnusual.merchant}',
      );
    }

    // Recurring expense insight
    if (report.recurringPatterns.isNotEmpty) {
      insights.add(
        '${report.recurringPatterns.length} recurring expense patterns detected',
      );
    }

    // Largest expense insight
    if (report.highestExpenseInfo != null) {
      insights.add(
        'Largest expense: ₹${report.highestExpenseInfo!.amount.toStringAsFixed(0)} at ${report.highestExpenseInfo!.merchant}',
      );
    }

    // Health score insight
    insights.add('Spending health: ${report.healthScore.grade} (${report.healthScore.status})');

    return insights;
  }

  /// Get period label for comparison
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
      case 'quarter':
        return 'This Quarter vs Last Quarter';
      case 'year':
        return 'This Year vs Last Year';
      default:
        return 'Current vs Previous Period';
    }
  }

  /// Check if expense data is empty
  bool isEmpty(ExpenseReport report) {
    return report.expenseCount == 0;
  }

  /// Get spending status description
  String getSpendingStatusDescription(ExpenseReport report) {
    final health = report.healthScore;
    return '${health.status} - ${health.recommendation}';
  }

  /// Check if overspending detected
  bool isOverspending(ExpenseReport report) {
    return report.comparison.growthPercentage > 10;
  }

  /// Get top merchants for quick view
  List<MerchantSlice> getTopMerchants(ExpenseReport report, {int limit = 5}) {
    return report.merchants.take(limit).toList();
  }

  /// Check if device is in offline mode
  bool isOfflineMode() {
    // This would be enhanced with actual connectivity check
    return false;
  }

  /// Get category budget warnings
  List<String> getCategoryWarnings(ExpenseReport report) {
    final warnings = <String>[];

    for (final cat in report.categories) {
      if (cat.percentage > 40) {
        warnings.add('${cat.categoryName} exceeds 40% of total spending');
      }
      if (cat.transactionCount > 20) {
        warnings.add('${cat.categoryName} has unusually high transaction count');
      }
    }

    return warnings;
  }
}
