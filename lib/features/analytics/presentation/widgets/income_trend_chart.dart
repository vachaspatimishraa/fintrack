import 'package:flutter/material.dart';
import '../../domain/entities/income_data.dart';

class IncomeTrendChart extends StatelessWidget {
  final List<IncomePoint> points;

  const IncomeTrendChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('No Income Trend available'),
        ),
      );
    }

    return CustomPaint(
      size: const Size(double.infinity, 180),
      painter: _IncomeTrendPainter(points: points),
    );
  }
}

class _IncomeTrendPainter extends CustomPainter {
  final List<IncomePoint> points;

  _IncomeTrendPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    double maxVal = 1.0;
    for (final pt in points) {
      if (pt.amount > maxVal) maxVal = pt.amount;
      if (pt.runningTotal > maxVal) maxVal = pt.runningTotal;
    }

    final double widthBetween = size.width / (points.length == 1 ? 1 : points.length - 1);

    final linePaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final areaPaint = Paint()
      ..color = Colors.green.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final path = Path();
    final areaPath = Path();

    areaPath.moveTo(0, size.height);

    for (int i = 0; i < points.length; i++) {
      final pt = points[i];
      final x = i * widthBetween;
      final y = size.height - (pt.amount / maxVal) * (size.height - 20);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      areaPath.lineTo(x, y);
    }

    areaPath.lineTo(size.width, size.height);

    canvas.drawPath(areaPath, areaPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
