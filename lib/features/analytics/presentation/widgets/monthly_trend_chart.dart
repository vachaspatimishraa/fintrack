import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/utils/formatter.dart';
import '../../domain/entities/monthly_report_data.dart';

class MonthlyTrendChart extends StatefulWidget {
  final List<MonthlyDayBreakdown> dailyBreakdown;

  const MonthlyTrendChart({
    super.key,
    required this.dailyBreakdown,
  });

  @override
  State<MonthlyTrendChart> createState() => _MonthlyTrendChartState();
}

class _MonthlyTrendChartState extends State<MonthlyTrendChart> {
  String _selectedTrend = 'expense'; // 'expense', 'income', 'savings', 'cashflow'

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.dailyBreakdown.isEmpty) {
      return Card(
        color: theme.colorScheme.surfaceContainerLow,
        child: const SizedBox(
          height: 200,
          child: Center(child: Text('No trend data available')),
        ),
      );
    }

    final List<double> values = widget.dailyBreakdown.map((day) {
      switch (_selectedTrend) {
        case 'income':
          return day.income;
        case 'savings':
          return day.savings;
        case 'cashflow':
          return day.savings; // Savings & Cash Flow are equivalent (income - expense)
        case 'expense':
        default:
          return day.expense;
      }
    }).toList();

    Color trendColor = theme.colorScheme.primary;
    if (_selectedTrend == 'income') {
      trendColor = const Color(0xFF10B981);
    } else if (_selectedTrend == 'expense') {
      trendColor = const Color(0xFFF43F5E);
    } else if (_selectedTrend == 'savings' || _selectedTrend == 'cashflow') {
      trendColor = Colors.blue;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Monthly Trends',
                  style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Icon(
                  Icons.show_chart,
                  color: trendColor,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _TrendChip(
                    label: 'Expenses',
                    isSelected: _selectedTrend == 'expense',
                    color: const Color(0xFFF43F5E),
                    onTap: () => setState(() => _selectedTrend = 'expense'),
                  ),
                  const SizedBox(width: 8),
                  _TrendChip(
                    label: 'Income',
                    isSelected: _selectedTrend == 'income',
                    color: const Color(0xFF10B981),
                    onTap: () => setState(() => _selectedTrend = 'income'),
                  ),
                  const SizedBox(width: 8),
                  _TrendChip(
                    label: 'Savings',
                    isSelected: _selectedTrend == 'savings',
                    color: Colors.blue,
                    onTap: () => setState(() => _selectedTrend = 'savings'),
                  ),
                  const SizedBox(width: 8),
                  _TrendChip(
                    label: 'Cash Flow',
                    isSelected: _selectedTrend == 'cashflow',
                    color: Colors.teal,
                    onTap: () => setState(() => _selectedTrend = 'cashflow'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 180,
              child: CustomPaint(
                painter: _LineTrendPainter(
                  values: values,
                  lineColor: trendColor,
                  gridColor: theme.colorScheme.outlineVariant.withOpacity(0.4),
                  textStyle: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '1st',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                ),
                Text(
                  '15th',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                ),
                Text(
                  '${widget.dailyBreakdown.length}th',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TrendChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = color.withOpacity(0.12);
    final border = isSelected
        ? BorderSide(color: color, width: 1.5)
        : BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.fromBorderSide(border),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}

class _LineTrendPainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;
  final Color gridColor;
  final TextStyle? textStyle;

  _LineTrendPainter({
    required this.values,
    required this.lineColor,
    required this.gridColor,
    this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final double minVal = values.reduce(min);
    final double maxVal = values.reduce(max);
    final double range = maxVal - minVal;
    final double safeRange = range <= 0 ? 1.0 : range;

    final double paddingY = size.height * 0.1;
    final double chartHeight = size.height - (paddingY * 2);
    final double chartWidth = size.width;

    // Draw horizontal grid lines
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final int gridLinesCount = 3;
    for (int i = 0; i <= gridLinesCount; i++) {
      final double y = paddingY + (chartHeight / gridLinesCount) * i;
      canvas.drawLine(Offset(0, y), Offset(chartWidth, y), gridPaint);

      // Value label on grid
      final double valueAtGrid = maxVal - ((range / gridLinesCount) * i);
      final textPainter = TextPainter(
        text: TextSpan(
          text: AppFormatter.formatCurrency(valueAtGrid),
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(4, y - textPainter.height - 2),
      );
    }

    final path = Path();
    final fillPath = Path();

    final double stepX = chartWidth / (values.length - 1);

    for (int i = 0; i < values.length; i++) {
      final double x = stepX * i;
      final double normalizedY = (values[i] - minVal) / safeRange;
      final double y = paddingY + chartHeight - (normalizedY * chartHeight);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, paddingY + chartHeight);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      if (i == values.length - 1) {
        fillPath.lineTo(x, paddingY + chartHeight);
        fillPath.close();
      }
    }

    // Draw area fill
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withOpacity(0.24),
          lineColor.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, paddingY, chartWidth, chartHeight))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Draw trend line
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _LineTrendPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.lineColor != lineColor;
  }
}
