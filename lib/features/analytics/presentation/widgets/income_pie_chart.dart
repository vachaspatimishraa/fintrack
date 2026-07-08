import 'package:flutter/material.dart';
import '../../domain/entities/income_data.dart';

class IncomePieChart extends StatelessWidget {
  final List<CategorySlice> categories;

  const IncomePieChart({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text('No categories to display'),
        ),
      );
    }

    return Column(
      children: [
        CustomPaint(
          size: const Size(120, 120),
          painter: _PiePainter(categories: categories),
        ),
        const SizedBox(height: 16),
        Column(
          children: categories.map((slice) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      slice.categoryName,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    '${slice.percentage.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _PiePainter extends CustomPainter {
  final List<CategorySlice> categories;

  _PiePainter({required this.categories});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20.0;

    double startAngle = 0.0;
    for (final slice in categories) {
      final sweepAngle = (slice.percentage / 100) * 360 * (3.14159 / 180);
      paint.color = Colors.green;
      canvas.drawArc(
        Rect.fromLTWH(10, 10, size.width - 20, size.height - 20),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
