import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/formatter.dart';
import '../../domain/entities/expense_data.dart';

/// Widget to display comprehensive expense statistics
class ExpenseStatisticsCard extends ConsumerWidget {
  final ExpenseStatistics statistics;

  const ExpenseStatisticsCard({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _StatisticsTile(
                  label: 'Total Expense',
                  value:
                      AppFormatter.formatCurrency(statistics.totalExpense),
                  icon: Icons.trending_down,
                  color: Colors.red,
                ),
                _StatisticsTile(
                  label: 'Average',
                  value: AppFormatter.formatCurrency(statistics.averageExpense),
                  icon: Icons.equalizer,
                  color: colorScheme.secondary,
                ),
                _StatisticsTile(
                  label: 'Highest',
                  value: AppFormatter.formatCurrency(statistics.highestExpense),
                  icon: Icons.arrow_upward,
                  color: Colors.red,
                ),
                _StatisticsTile(
                  label: 'Lowest',
                  value: AppFormatter.formatCurrency(statistics.lowestExpense),
                  icon: Icons.arrow_downward,
                  color: Colors.orange,
                ),
                _StatisticsTile(
                  label: 'Median',
                  value: AppFormatter.formatCurrency(statistics.medianExpense),
                  icon: Icons.linear_scale,
                  color: colorScheme.tertiary,
                ),
                _StatisticsTile(
                  label: 'Std Dev',
                  value: AppFormatter.formatCurrency(
                      statistics.standardDeviation),
                  icon: Icons.show_chart,
                  color: Colors.blueAccent,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _PeriodStatistic(
                    label: 'Per Day',
                    value: AppFormatter.formatCurrency(
                        statistics.averagePerDay),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: colorScheme.outline,
                  ),
                  _PeriodStatistic(
                    label: 'Per Week',
                    value: AppFormatter.formatCurrency(
                        statistics.averagePerWeek),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: colorScheme.outline,
                  ),
                  _PeriodStatistic(
                    label: 'Per Month',
                    value: AppFormatter.formatCurrency(
                        statistics.averagePerMonth),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual statistics tile
class _StatisticsTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatisticsTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
            color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Period statistic display
class _PeriodStatistic extends StatelessWidget {
  final String label;
  final String value;

  const _PeriodStatistic({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color:
                    Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
