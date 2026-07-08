import 'package:flutter/material.dart';

import '../../../../core/utils/formatter.dart';
import '../../domain/entities/spending_trend_data.dart';

class TrendChart extends StatelessWidget {
  final List<SpendingTrendPoint> points;

  const TrendChart({
    super.key,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text('No trend points available')),
      );
    }

    return SizedBox(
      height: 220,
      child: CustomPaint(
        painter: _TrendChartPainter(
          points: points,
          lineColor: Theme.of(context).colorScheme.primary,
          averageColor: Theme.of(context).colorScheme.secondary,
          gridColor: Theme.of(context).colorScheme.outlineVariant,
        ),
        child: Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 4),
            child: Text(
              AppFormatter.formatCurrency(points.last.amount),
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ),
      ),
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  final List<SpendingTrendPoint> points;
  final Color lineColor;
  final Color averageColor;
  final Color gridColor;

  const _TrendChartPainter({
    required this.points,
    required this.lineColor,
    required this.averageColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final maxAmount = points
        .map((point) => point.amount > point.movingAverage
            ? point.amount
            : point.movingAverage)
        .reduce((a, b) => a > b ? a : b);
    final safeMax = maxAmount <= 0 ? 1 : maxAmount;
    final chartRect = Rect.fromLTWH(0, 8, size.width, size.height - 24);

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final y = chartRect.top + (chartRect.height / 3) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final areaPath = Path();
    final linePath = Path();
    final averagePath = Path();

    for (var index = 0; index < points.length; index++) {
      final x = points.length == 1
          ? chartRect.center.dx
          : chartRect.left + (chartRect.width / (points.length - 1)) * index;
      final y =
          chartRect.bottom - (points[index].amount / safeMax) * chartRect.height;
      final averageY = chartRect.bottom -
          (points[index].movingAverage / safeMax) * chartRect.height;

      if (index == 0) {
        linePath.moveTo(x, y);
        averagePath.moveTo(x, averageY);
        areaPath.moveTo(x, chartRect.bottom);
        areaPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        averagePath.lineTo(x, averageY);
        areaPath.lineTo(x, y);
      }

      if (index == points.length - 1) {
        areaPath.lineTo(x, chartRect.bottom);
        areaPath.close();
      }
    }

    canvas.drawPath(
      areaPath,
      Paint()..color = lineColor.withOpacity(0.12),
    );
    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      averagePath,
      Paint()
        ..color = averageColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.averageColor != averageColor;
  }
}
