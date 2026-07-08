import 'package:flutter/material.dart';
import '../../domain/entities/cash_flow_data.dart';

class CashFlowChart extends StatelessWidget {
  final CashFlowReport report;

  const CashFlowChart({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    if (report.points.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('No Cash Flow Data available'),
        ),
      );
    }

    return Column(
      children: [
        CustomPaint(
          size: const Size(double.infinity, 220),
          painter: _CashFlowPainter(points: report.points),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _LegendItem(color: Colors.green, label: 'Income'),
            _LegendItem(color: Colors.red, label: 'Expense'),
            _LegendItem(color: Colors.blue, label: 'Net Flow'),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _CashFlowPainter extends CustomPainter {
  final List<CashFlowPoint> points;

  _CashFlowPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    double maxVal = 1.0;
    for (final pt in points) {
      if (pt.income > maxVal) maxVal = pt.income;
      if (pt.expense > maxVal) maxVal = pt.expense;
      if (pt.runningBalance.abs() > maxVal) maxVal = pt.runningBalance.abs();
    }

    final double widthBetween = size.width / (points.length - 1);

    final gridPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1.0;
    for (int i = 1; i < 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final incomePaint = Paint()
      ..color = Colors.green.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final expensePaint = Paint()
      ..color = Colors.red.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final balancePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final incomePath = Path();
    final expensePath = Path();
    final balancePath = Path();

    incomePath.moveTo(0, size.height);
    expensePath.moveTo(0, size.height);

    for (int i = 0; i < points.length; i++) {
      final pt = points[i];
      final x = i * widthBetween;

      final incomeY = size.height - (pt.income / maxVal) * (size.height - 20);
      final expenseY = size.height - (pt.expense / maxVal) * (size.height - 20);
      final balanceY = size.height - ((pt.runningBalance + maxVal) / (maxVal * 2)) * (size.height - 20);

      incomePath.lineTo(x, incomeY);
      expensePath.lineTo(x, expenseY);

      if (i == 0) {
        balancePath.moveTo(x, balanceY);
      } else {
        balancePath.lineTo(x, balanceY);
      }
    }

    incomePath.lineTo(size.width, size.height);
    expensePath.lineTo(size.width, size.height);

    canvas.drawPath(incomePath, incomePaint);
    canvas.drawPath(expensePath, expensePaint);
    canvas.drawPath(balancePath, balancePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
