import 'package:flutter/material.dart';

import '../../../../core/utils/formatter.dart';
import '../../domain/entities/weekly_report_data.dart';

class WeeklySummaryCard extends StatelessWidget {
  final WeeklyReport report;
  final String weekLabel;

  const WeeklySummaryCard({
    super.key,
    required this.report,
    required this.weekLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weekly Report', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(weekLabel, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _Metric(label: 'Income', value: report.summary.income),
                _Metric(label: 'Expense', value: report.summary.expense),
                _Metric(label: 'Savings', value: report.summary.savings),
                _Metric(label: 'Cash Flow', value: report.summary.cashFlow),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final double value;

  const _Metric({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(
            AppFormatter.formatCurrency(value),
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}
