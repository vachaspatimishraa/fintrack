import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/utils/formatter.dart';
import '../../domain/entities/yearly_report_data.dart';

class BudgetPerformanceCard extends StatefulWidget {
  final YearlyBudgetProgress budgetProgress;

  const BudgetPerformanceCard({
    super.key,
    required this.budgetProgress,
  });

  @override
  State<BudgetPerformanceCard> createState() => _BudgetPerformanceCardState();
}

class _BudgetPerformanceCardState extends State<BudgetPerformanceCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _sweepAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _sweepAnimation = Tween<double>(
      begin: 0.0,
      end: widget.budgetProgress.utilization.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _animationController.forward();
  }

  @override
  void didUpdateWidget(covariant BudgetPerformanceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.budgetProgress.utilization != widget.budgetProgress.utilization) {
      _sweepAnimation = Tween<double>(
        begin: _sweepAnimation.value,
        end: widget.budgetProgress.utilization.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'exceeded':
        return Colors.red;
      case 'critical':
        return Colors.orange;
      case 'warning':
        return Colors.amber;
      case 'completed':
        return Colors.blue;
      case 'safe':
      default:
        return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = widget.budgetProgress;

    if (progress.budgetLimit <= 0) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Annual Budget Performance',
                style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'No budget limits defined for this year.',
                style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    final statusColor = _getStatusColor(progress.status);

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Annual Budget Performance',
                  style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    progress.status,
                    style: theme.textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: AnimatedBuilder(
                    animation: _sweepAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _BudgetProgressPainter(
                          value: _sweepAnimation.value,
                          color: statusColor,
                          trackColor: theme.colorScheme.surfaceContainerHighest,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${(progress.utilization * 100).toStringAsFixed(0)}%',
                                style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                'Spent',
                                style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BudgetMetricRow(
                        label: 'Annual Limit',
                        value: AppFormatter.formatCurrency(progress.budgetLimit),
                      ),
                      const SizedBox(height: 6),
                      _BudgetMetricRow(
                        label: 'Annual Spent',
                        value: AppFormatter.formatCurrency(progress.spent),
                      ),
                      const SizedBox(height: 6),
                      _BudgetMetricRow(
                        label: 'Remaining Limit',
                        value: AppFormatter.formatCurrency(progress.remaining),
                        valueColor: progress.remaining > 0 ? const Color(0xFF10B981) : Colors.red,
                      ),
                      const SizedBox(height: 6),
                      _BudgetMetricRow(
                        label: 'Compliance Score',
                        value: '${progress.complianceScore.toStringAsFixed(0)}/100',
                        valueColor: progress.complianceScore >= 75 ? const Color(0xFF10B981) : Colors.orange,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (progress.exceededCategories.isNotEmpty || progress.safeCategories.isNotEmpty) ...[
              const Divider(height: 32),
              if (progress.exceededCategories.isNotEmpty) ...[
                Text(
                  'Exceeded Category Limits',
                  style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: progress.exceededCategories.map((c) {
                    return Chip(
                      label: Text(c, style: const TextStyle(fontSize: 11)),
                      backgroundColor: Colors.red.withOpacity(0.08),
                      side: BorderSide.none,
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],
              if (progress.safeCategories.isNotEmpty) ...[
                Text(
                  'Successful Category Limits',
                  style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF10B981),
                      ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: progress.safeCategories.map((c) {
                    return Chip(
                      label: Text(c, style: const TextStyle(fontSize: 11)),
                      backgroundColor: const Color(0xFF10B981).withOpacity(0.08),
                      side: BorderSide.none,
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _BudgetMetricRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _BudgetMetricRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
        ),
      ],
    );
  }
}

class _BudgetProgressPainter extends CustomPainter {
  final double value;
  final Color color;
  final Color trackColor;

  _BudgetProgressPainter({
    required this.value,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 6;

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    final sweepPaint = Paint()
      ..color = color
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * value,
      false,
      sweepPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BudgetProgressPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.color != color;
  }
}
