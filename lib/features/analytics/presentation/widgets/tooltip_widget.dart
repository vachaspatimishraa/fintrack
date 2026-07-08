import 'package:flutter/material.dart';
import '../../../../core/utils/formatter.dart';
import '../../domain/entities/income_data.dart';

/// Custom tooltip widget for chart interactions
class IncomeChartTooltip extends StatelessWidget {
  final IncomePoint point;
  final Offset position;
  final Size chartSize;

  const IncomeChartTooltip({
    super.key,
    required this.point,
    required this.position,
    required this.chartSize,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Calculate tooltip position to prevent overflow
    var topOffset = position.dy - 80;
    var leftOffset = position.dx - 60;

    if (topOffset < 0) {
      topOffset = position.dy + 10;
    }
    if (leftOffset < 0) {
      leftOffset = 10;
    } else if (leftOffset + 120 > chartSize.width) {
      leftOffset = chartSize.width - 130;
    }

    return Positioned(
      top: topOffset,
      left: leftOffset,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            border: Border.all(
              color: colorScheme.outline,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                AppFormatter.formatDate(point.date),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 1,
                color: colorScheme.outline,
              ),
              const SizedBox(height: 8),
              Text(
                'Income',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                AppFormatter.formatCurrency(point.amount),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 1,
                color: colorScheme.outline,
              ),
              const SizedBox(height: 8),
              Text(
                'Running Total',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                AppFormatter.formatCurrency(point.runningTotal),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hover card for displaying transaction details
class IncomeHoverCard extends StatelessWidget {
  final LargestIncomeInfo income;
  final bool isSmallest;

  const IncomeHoverCard({
    super.key,
    required this.income,
    this.isSmallest = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = isSmallest ? Colors.orange : Colors.green;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isSmallest ? 'Smallest Income' : 'Largest Income',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Icon(
                  isSmallest ? Icons.arrow_downward : Icons.arrow_upward,
                  color: accentColor,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(color: colorScheme.outline),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Merchant',
              value: income.merchant,
            ),
            const SizedBox(height: 6),
            _InfoRow(
              label: 'Amount',
              value: AppFormatter.formatCurrency(income.amount),
              valueColor: accentColor,
            ),
            const SizedBox(height: 6),
            _InfoRow(
              label: 'Date',
              value: AppFormatter.formatDate(income.date),
            ),
            const SizedBox(height: 6),
            _InfoRow(
              label: 'Category',
              value: income.category,
            ),
          ],
        ),
      ),
    );
  }
}

/// Information row for displaying key-value pairs
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
