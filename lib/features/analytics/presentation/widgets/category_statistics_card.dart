import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/formatter.dart';
import '../../domain/entities/category_data.dart';
import '../../domain/utils/category_ranking_service.dart';

/// Widget to display category statistics
class CategoryStatisticsCard extends ConsumerWidget {
  final CategoryAnalyticsReport report;

  const CategoryStatisticsCard({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final concentration =
        CategoryRankingService.calculateConcentration(report.rankings);
    final concentrationStr =
        CategoryRankingService.getConcentrationInterpretation(concentration);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Insights',
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
                _StatisticTile(
                  label: 'Total Categories',
                  value: report.categoryCount.toString(),
                  icon: Icons.category,
                  color: colorScheme.primary,
                ),
                _StatisticTile(
                  label: 'Total Amount',
                  value: AppFormatter.formatCurrency(report.totalAmount),
                  icon: Icons.attach_money,
                  color: colorScheme.secondary,
                ),
                _StatisticTile(
                  label: 'Top Category',
                  value: report.topSpendingCategory?.categoryName ?? 'N/A',
                  icon: Icons.trending_up,
                  color: Colors.orange,
                ),
                _StatisticTile(
                  label: 'Top %',
                  value:
                      '${report.topSpendingCategory?.percentage.toStringAsFixed(1) ?? '0'}%',
                  icon: Icons.percent,
                  color: Colors.amber,
                ),
                _StatisticTile(
                  label: 'Concentration',
                  value: concentrationStr,
                  icon: Icons.pie_chart,
                  color: colorScheme.tertiary,
                ),
                _StatisticTile(
                  label: 'Frequency Leader',
                  value: report.mostFrequentCategory?.categoryName ?? 'N/A',
                  icon: Icons.repeat,
                  color: Colors.teal,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual statistic tile
class _StatisticTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatisticTile({
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
        border: Border.all(color: Theme.of(context).colorScheme.outline),
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
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
