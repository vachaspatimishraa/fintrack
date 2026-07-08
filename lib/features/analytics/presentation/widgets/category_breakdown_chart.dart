import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/utils/formatter.dart';
import '../../domain/entities/monthly_report_data.dart';

class CategoryBreakdownChart extends StatelessWidget {
  final List<MonthlyCategoryBreakdown> categories;
  final Function(String)? onCategoryTap;

  const CategoryBreakdownChart({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  Color _getTrendColor(String trend) {
    switch (trend) {
      case 'up':
        return const Color(0xFFF43F5E);
      case 'down':
        return const Color(0xFF10B981);
      case 'stable':
      default:
        return Colors.grey;
    }
  }

  IconData _getTrendIcon(String trend) {
    switch (trend) {
      case 'up':
        return Icons.arrow_upward;
      case 'down':
        return Icons.arrow_downward;
      case 'stable':
      default:
        return Icons.trending_flat;
    }
  }

  Color _getCategoryColor(String name) {
    const palette = [
      '#6750A4',
      '#006A6A',
      '#B3261E',
      '#386A20',
      '#7D5260',
      '#625B71',
      '#005DB7',
      '#8C5000',
      '#006D3B',
      '#7F4E1D',
    ];
    final index = name.codeUnits.fold<int>(0, (sum, code) => sum + code) % palette.length;
    return Color(int.parse(palette[index].replaceFirst('#', '0xff')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (categories.isEmpty) {
      return Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withOpacity(0.3),
          ),
        ),
        child: const SizedBox(
          height: 180,
          child: Center(child: Text('No category statistics available')),
        ),
      );
    }

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Category Distribution',
              style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: CustomPaint(
                painter: _PieChartPainter(categories: categories, getCategoryColor: _getCategoryColor),
              ),
            ),
            const SizedBox(height: 20),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: categories.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final category = categories[index];
                final catColor = _getCategoryColor(category.category);
                final trendColor = _getTrendColor(category.trend);

                return GestureDetector(
                  onTap: () => onCategoryTap?.call(category.category),
                  child: Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: catColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.category,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              '${category.transactionCount} transactions',
                              style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            _getTrendIcon(category.trend),
                            color: trendColor,
                            size: 14,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                AppFormatter.formatCurrency(category.amount),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                '${category.percentage.toStringAsFixed(1)}%',
                                style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<MonthlyCategoryBreakdown> categories;
  final Color Function(String) getCategoryColor;

  _PieChartPainter({
    required this.categories,
    required this.getCategoryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (categories.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 * 0.9;

    double startAngle = -pi / 2;

    for (int i = 0; i < categories.length; i++) {
      final category = categories[i];
      final sweepAngle = (category.percentage / 100) * 2 * pi;

      final paint = Paint()
        ..color = getCategoryColor(category.category)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) => true;
}
