import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/spending_trend_data.dart';
import '../../domain/repositories/spending_trend_repository.dart';

class TrendController {
  final SpendingTrendRepository _repository;
  final Ref ref;

  TrendController(this._repository, this.ref);

  List<String> generateRecommendations(SpendingTrendReport report) {
    if (report.isEmpty) return [];

    final recommendations = <String>[
      ...report.habits.recommendations,
    ];

    if (report.summary.direction == TrendDirection.increasing) {
      recommendations.add(
        'Spending is up ${report.summary.growthPercentage.toStringAsFixed(1)}% this period.',
      );
    } else if (report.summary.direction == TrendDirection.declining) {
      recommendations.add(
        'Spending is down ${report.summary.growthPercentage.abs().toStringAsFixed(1)}% this period.',
      );
    } else {
      recommendations.add('Your spending trend is stable.');
    }

    if (report.forecast.expectedSpending > report.summary.currentSpending) {
      recommendations.add('Forecasted spending is above the current period.');
    }

    return recommendations.toSet().toList();
  }

  String getPeriodLabel(String filter) {
    switch (filter) {
      case 'today':
        return 'Today';
      case 'week':
      case '7days':
        return 'Last 7 Days';
      case 'month':
      case '30days':
        return 'This Month';
      case 'quarter':
        return 'This Quarter';
      case 'year':
        return 'This Year';
      default:
        return 'Current Period';
    }
  }

  String directionLabel(TrendDirection direction) {
    switch (direction) {
      case TrendDirection.increasing:
        return 'Increasing';
      case TrendDirection.declining:
        return 'Declining';
      case TrendDirection.stable:
        return 'Stable';
    }
  }

  bool isEmpty(SpendingTrendReport report) => report.isEmpty;

  bool isOfflineMode() => false;

  SpendingTrendRepository get repository => _repository;
}
