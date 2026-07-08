import 'package:flutter/material.dart';

import '../../../../core/utils/formatter.dart';
import '../../domain/entities/calendar_analytics_data.dart';

class DaySummaryCard extends StatelessWidget {
  final CalendarDayData? day;

  const DaySummaryCard({
    super.key,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    final selected = day;
    if (selected == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Select a day to view details'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppFormatter.formatDate(selected.date),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _Metric(label: 'Income', value: selected.income),
                _Metric(label: 'Expense', value: selected.expense),
                _Metric(label: 'Savings', value: selected.savings),
                _Metric(label: 'Cash Flow', value: selected.cashFlow),
              ],
            ),
            const Divider(height: 24),
            Text('${selected.transactionCount} transactions'),
            const SizedBox(height: 4),
            Text(
              'Largest expense ${AppFormatter.formatCurrency(selected.largestExpense)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Largest income ${AppFormatter.formatCurrency(selected.largestIncome)}',
              style: Theme.of(context).textTheme.bodySmall,
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
          const SizedBox(height: 2),
          Text(
            AppFormatter.formatCurrency(value),
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}
