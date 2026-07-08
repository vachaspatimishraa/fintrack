import 'package:flutter/material.dart';
import '../../domain/entities/financial_health_data.dart';

class HealthBreakdownCard extends StatelessWidget {
  final HealthBreakdown breakdown;

  const HealthBreakdownCard({
    super.key,
    required this.breakdown,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              'Wellness Breakdown',
              style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildBreakdownItem(context, 'Savings (25%)', breakdown.savingsScore, Colors.blue),
            const Divider(height: 24),
            _buildBreakdownItem(context, 'Budget Compliance (20%)', breakdown.budgetScore, theme.colorScheme.primary),
            const Divider(height: 24),
            _buildBreakdownItem(context, 'Cash Flow (20%)', breakdown.cashFlowScore, const Color(0xFF10B981)),
            const Divider(height: 24),
            _buildBreakdownItem(context, 'Expense Control (15%)', breakdown.expenseScore, Colors.deepOrange),
            const Divider(height: 24),
            _buildBreakdownItem(context, 'Income Stability (10%)', breakdown.incomeScore, Colors.indigo),
            const Divider(height: 24),
            _buildBreakdownItem(context, 'Financial Consistency (10%)', breakdown.consistencyScore, Colors.teal),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownItem(BuildContext context, String title, double value, Color barColor) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            Text(
              '${value.toStringAsFixed(0)}/100',
              style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: barColor,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value / 100,
            color: barColor,
            backgroundColor: barColor.withOpacity(0.12),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
