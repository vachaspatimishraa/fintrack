import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/expense_data.dart';

/// Widget to display expense trend chart
class ExpenseTrendChart extends ConsumerWidget {
  final List<ExpensePoint> points;

  const ExpenseTrendChart({
    super.key,
    required this.points,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (points.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'No data available',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      );
    }

    final maxAmount = points.fold<double>(
      0,
      (prev, point) => point.amount > prev ? point.amount : prev,
    );

    return SizedBox(
      height: 200,
      child: CustomPaint(
        painter: _ExpenseTrendChartPainter(
          points: points,
          maxAmount: maxAmount,
        ),
        size: const Size(double.infinity, 200),
      ),
    );
  }
}

/// Custom painter for expense trend chart
class _ExpenseTrendChartPainter extends CustomPainter {
  final List<ExpensePoint> points;
  final double maxAmount;

  _ExpenseTrendChartPainter({
    required this.points,
    required this.maxAmount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.red.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final pointPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final padding = 16.0;
    final graphHeight = size.height - (padding * 2);
    final graphWidth = size.width - (padding * 2);
    final xStep = graphWidth / (points.length - 1).clamp(1, double.infinity);

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final x = padding + (i * xStep);
      final y = size.height -
          padding -
          ((point.amount / maxAmount) * graphHeight);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(padding, size.height - padding);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Complete fill path
    fillPath.lineTo(
      padding + ((points.length - 1) * xStep),
      size.height - padding,
    );
    fillPath.close();

    // Draw fill
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    canvas.drawPath(path, paint);

    // Draw points
    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final x = padding + (i * xStep);
      final y = size.height -
          padding -
          ((point.amount / maxAmount) * graphHeight);
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
