import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/formatter.dart';
import '../../domain/entities/category_data.dart';
import '../../domain/utils/category_growth_calculator.dart';

/// Widget to display category period comparisons
class CategoryComparisonCard extends ConsumerWidget {
  final List<CategoryPeriodComparison> comparisons;

  const CategoryComparisonCard({
    super.key,
    required this.comparisons,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    // Get categories with significant changes
    final significant = comparisons
        .where((c) => c.growthPercentage.abs() > 5)
        .toList()
      ..sort((a, b) => b.growthPercentage.abs().compareTo(a.growthPercentage.abs()));

    if (significant.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Month-over-Month Comparison',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'No significant changes',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Changes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: min(significant.length, 5),
              separatorBuilder: (context, index) => Divider(
                height: 12,
                color: colorScheme.outlineVariant,
              ),
              itemBuilder: (context, index) {
                final comp = significant[index];
                final color = comp.isIncrease ? Colors.red : Colors.green;

                return _ComparisonItem(
                  categoryName: comp.categoryName,
                  currentAmount: comp.currentAmount,
                  previousAmount: comp.previousAmount,
                  growthPercentage: comp.growthPercentage,
                  isIncrease: comp.isIncrease,
                  color: color,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual comparison item
class _ComparisonItem extends StatelessWidget {
  final String categoryName;
  final double currentAmount;
  final double previousAmount;
  final double growthPercentage;
  final bool isIncrease;
  final Color color;

  const _ComparisonItem({
    required this.categoryName,
    required this.currentAmount,
    required this.previousAmount,
    required this.growthPercentage,
    required this.isIncrease,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = isIncrease ? Icons.trending_up : Icons.trending_down;

    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                categoryName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '${AppFormatter.formatCurrency(previousAmount)} → ',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                  Text(
                    AppFormatter.formatCurrency(currentAmount),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            CategoryGrowthCalculator.formatGrowth(growthPercentage),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }
}
