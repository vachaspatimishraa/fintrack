import 'package:flutter/material.dart';

import '../../../../core/utils/formatter.dart';
import '../../domain/entities/spending_trend_data.dart';

class TrendSummaryCard extends StatelessWidget {
  final SpendingTrendReport report;
  final String periodLabel;
  final String directionLabel;

  const TrendSummaryCard({
    super.key,
    required this.report,
    required this.periodLabel,
    required this.directionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final direction = report.summary.direction;
    final color = switch (direction) {
      TrendDirection.increasing => colorScheme.error,
      TrendDirection.declining => Colors.green,
      TrendDirection.stable => colorScheme.secondary,
    };
    final icon = switch (direction) {
      TrendDirection.increasing => Icons.trending_up,
      TrendDirection.declining => Icons.trending_down,
      TrendDirection.stable => Icons.trending_flat,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(periodLabel, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  directionLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Text(
                  '${report.summary.growthPercentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              AppFormatter.formatCurrency(report.totalSpending),
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              report.summary.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
