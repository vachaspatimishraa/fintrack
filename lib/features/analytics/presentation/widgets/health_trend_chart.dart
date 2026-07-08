import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../domain/entities/financial_health_data.dart';

class HealthTrendChart extends StatelessWidget {
  final List<HistoricalHealthScore> historicalScores;

  const HealthTrendChart({
    super.key,
    required this.historicalScores,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (historicalScores.isEmpty) return const SizedBox.shrink();

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
              'Historical Wellness Trend',
              style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 180,
              child: CustomPaint(
                painter: _LineChartPainter(
                  scores: historicalScores,
                  theme: theme,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<HistoricalHealthScore> scores;
  final ThemeData theme;

  _LineChartPainter({
    required this.scores,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double paddingLeft = 32.0;
    final double paddingBottom = 24.0;
    final double chartWidth = size.width - paddingLeft;
    final double chartHeight = size.height - paddingBottom;

    final double stepX = scores.length > 1 ? chartWidth / (scores.length - 1) : chartWidth;

    // Draw horizontal grid lines
    final gridPaint = Paint()
      ..color = theme.colorScheme.outlineVariant.withOpacity(0.2)
      ..strokeWidth = 1.0;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i <= 4; i++) {
      final y = chartHeight - (chartHeight / 4) * i;
      canvas.drawLine(Offset(paddingLeft, y), Offset(size.width, y), gridPaint);

      // Y axis labels
      final label = (i * 25).toString();
      textPainter.text = TextSpan(
        text: label,
        style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - textPainter.height / 2));
    }

    final points = <Offset>[];
    for (int i = 0; i < scores.length; i++) {
      final scoreVal = scores[i].overallScore;
      final x = paddingLeft + i * stepX;
      final y = chartHeight - (scoreVal / 100.0) * chartHeight;
      points.add(Offset(x, y));

      // Draw X axis label (month names)
      final labelText = DateFormat('MMM').format(scores[i].date);
      textPainter.text = TextSpan(
        text: labelText,
        style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, chartHeight + 6),
      );
    }

    if (points.isEmpty) return;

    // Draw line fill gradient
    final fillPath = Path()
      ..moveTo(points.first.dx, chartHeight);
    for (final pt in points) {
      fillPath.lineTo(pt.dx, pt.dy);
    }
    fillPath.lineTo(points.last.dx, chartHeight);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          theme.colorScheme.primary.withOpacity(0.3),
          theme.colorScheme.primary.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTRB(paddingLeft, 0, size.width, chartHeight))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final linePaint = Paint()
      ..color = theme.colorScheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, linePaint);

    // Draw point markers
    final markerPaint = Paint()
      ..color = theme.colorScheme.primary
      ..style = PaintingStyle.fill;

    final markerBorderPaint = Paint()
      ..color = theme.colorScheme.surface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final pt in points) {
      canvas.drawCircle(pt, 5.0, markerPaint);
      canvas.drawCircle(pt, 5.0, markerBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) => true;
}
