import 'package:flutter/material.dart';

import '../../../../core/utils/formatter.dart';
import '../../domain/entities/spending_trend_data.dart';

class MovingAverageCard extends StatelessWidget {
  final SpendingTrendReport report;

  const MovingAverageCard({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    final latest = report.points.isEmpty ? 0.0 : report.points.last.movingAverage;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.show_chart,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '7-Day Average',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Velocity ${AppFormatter.formatCurrency(report.summary.velocity)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Text(
              AppFormatter.formatCurrency(latest),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}
