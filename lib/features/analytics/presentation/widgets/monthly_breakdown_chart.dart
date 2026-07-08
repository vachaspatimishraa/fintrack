import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/utils/formatter.dart';
import '../../domain/entities/yearly_report_data.dart';

class MonthlyBreakdownChart extends StatefulWidget {
  final List<YearlyMonthBreakdown> monthlyBreakdown;

  const MonthlyBreakdownChart({
    super.key,
    required this.monthlyBreakdown,
  });

  @override
  State<MonthlyBreakdownChart> createState() => _MonthlyBreakdownChartState();
}

class _MonthlyBreakdownChartState extends State<MonthlyBreakdownChart> {
  String _activeTab = 'income_expense'; // 'income_expense', 'savings'

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.monthlyBreakdown.isEmpty) {
      return Card(
        color: theme.colorScheme.surfaceContainerLow,
        child: const SizedBox(
          height: 200,
          child: Center(child: Text('No monthly breakdown available')),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Monthly Overview',
                  style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                // Tab selectors
                Row(
                  children: [
                    _TabChip(
                      label: 'Income vs Expense',
                      isSelected: _activeTab == 'income_expense',
                      onTap: () => setState(() => _activeTab = 'income_expense'),
                    ),
                    const SizedBox(width: 8),
                    _TabChip(
                      label: 'Savings',
                      isSelected: _activeTab == 'savings',
                      onTap: () => setState(() => _activeTab = 'savings'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: CustomPaint(
                painter: _MonthlyBarPainter(
                  breakdown: widget.monthlyBreakdown,
                  showSavingsOnly: _activeTab == 'savings',
                  incomeColor: const Color(0xFF10B981),
                  expenseColor: const Color(0xFFF43F5E),
                  savingsColor: Colors.blue,
                  gridColor: theme.colorScheme.outlineVariant.withOpacity(0.4),
                  textStyle: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                    fontSize: 9,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Breakdown list
            ExpansionTile(
              title: Text(
                'View Detailed Monthly Table',
                style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              shape: const Border(),
              children: [
                const Divider(),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.monthlyBreakdown.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = widget.monthlyBreakdown[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.monthName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Inc: ${AppFormatter.formatCurrency(item.income)}',
                                style: const TextStyle(color: Color(0xFF10B981), fontSize: 11),
                              ),
                              Text(
                                'Exp: ${AppFormatter.formatCurrency(item.expense)}',
                                style: const TextStyle(color: Color(0xFFF43F5E), fontSize: 11),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Savings: ${AppFormatter.formatCurrency(item.savings)}',
                                style: TextStyle(
                                  color: item.savings >= 0 ? Colors.blue : Colors.orange,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Cash Flow: ${item.cashFlow >= 0 ? '+' : ''}${AppFormatter.formatCurrency(item.cashFlow)}',
                                style: TextStyle(
                                  color: item.cashFlow >= 0 ? Colors.teal : Colors.deepOrange,
                                  fontSize: 10,
                                ),
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
          ],
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant;
    final bgColor = isSelected ? theme.colorScheme.primary.withOpacity(0.12) : Colors.transparent;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
        ),
      ),
    );
  }
}

class _MonthlyBarPainter extends CustomPainter {
  final List<YearlyMonthBreakdown> breakdown;
  final bool showSavingsOnly;
  final Color incomeColor;
  final Color expenseColor;
  final Color savingsColor;
  final Color gridColor;
  final TextStyle? textStyle;

  _MonthlyBarPainter({
    required this.breakdown,
    required this.showSavingsOnly,
    required this.incomeColor,
    required this.expenseColor,
    required this.savingsColor,
    required this.gridColor,
    this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (breakdown.isEmpty) return;

    double maxVal = 0.0;
    double minVal = 0.0;

    for (final item in breakdown) {
      if (showSavingsOnly) {
        maxVal = max(maxVal, item.savings);
        minVal = min(minVal, item.savings);
      } else {
        maxVal = max(maxVal, max(item.income, item.expense));
      }
    }

    final double range = maxVal - minVal;
    final double safeRange = range <= 0 ? 1.0 : range;

    final double paddingY = size.height * 0.12;
    final double chartHeight = size.height - (paddingY * 2);
    final double chartWidth = size.width;

    // Draw horizontal grid lines
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final int gridLinesCount = 3;
    for (int i = 0; i <= gridLinesCount; i++) {
      final double y = paddingY + (chartHeight / gridLinesCount) * i;
      canvas.drawLine(Offset(0, y), Offset(chartWidth, y), gridPaint);

      final double val = maxVal - ((range / gridLinesCount) * i);
      final textPainter = TextPainter(
        text: TextSpan(
          text: AppFormatter.formatCurrency(val),
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(4, y - textPainter.height - 2),
      );
    }

    final double colWidth = chartWidth / breakdown.length;
    final double barSpacing = colWidth * 0.15;
    final double barWidth = showSavingsOnly ? colWidth - (barSpacing * 2) : (colWidth - (barSpacing * 2.5)) / 2;

    for (int i = 0; i < breakdown.length; i++) {
      final item = breakdown[i];
      final double startX = colWidth * i + barSpacing;

      if (showSavingsOnly) {
        final double normalizedY = (item.savings - minVal) / safeRange;
        final double y = paddingY + chartHeight - (normalizedY * chartHeight);
        final double zeroY = paddingY + chartHeight - ((0.0 - minVal) / safeRange * chartHeight);

        final paint = Paint()..color = item.savings >= 0 ? savingsColor : expenseColor;

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(startX, min(y, zeroY), startX + barWidth, max(y, zeroY)),
            const Radius.circular(4),
          ),
          paint,
        );
      } else {
        // Draw Income Bar
        final double normIncome = (item.income - minVal) / safeRange;
        final double yInc = paddingY + chartHeight - (normIncome * chartHeight);
        final double zeroY = paddingY + chartHeight - ((0.0 - minVal) / safeRange * chartHeight);

        final incPaint = Paint()..color = incomeColor;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(startX, min(yInc, zeroY), startX + barWidth, max(yInc, zeroY)),
            const Radius.circular(3),
          ),
          incPaint,
        );

        // Draw Expense Bar
        final double normExpense = (item.expense - minVal) / safeRange;
        final double yExp = paddingY + chartHeight - (normExpense * chartHeight);

        final expPaint = Paint()..color = expenseColor;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(startX + barWidth + (barSpacing * 0.5), min(yExp, zeroY), startX + (barWidth * 2) + (barSpacing * 0.5), max(yExp, zeroY)),
            const Radius.circular(3),
          ),
          expPaint,
        );
      }

      // X Axis Label
      final labelPainter = TextPainter(
        text: TextSpan(
          text: item.monthName,
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      labelPainter.paint(
        canvas,
        Offset(startX + (colWidth - barSpacing * 2 - labelPainter.width) / 2, size.height - labelPainter.height),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MonthlyBarPainter oldDelegate) {
    return oldDelegate.breakdown != breakdown || oldDelegate.showSavingsOnly != showSavingsOnly;
  }
}
