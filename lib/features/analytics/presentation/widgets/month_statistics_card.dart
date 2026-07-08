import 'package:flutter/material.dart';

import '../../../../core/utils/formatter.dart';
import '../../domain/entities/calendar_analytics_data.dart';

class MonthStatisticsCard extends StatelessWidget {
  final CalendarPeriodSummary summary;
  final ActivityStreak streak;

  const MonthStatisticsCard({
    super.key,
    required this.summary,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Monthly Statistics', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _Row(label: 'Working Days', value: '${summary.workingDays}'),
            _Row(label: 'Spending Days', value: '${summary.spendingDays}'),
            _Row(label: 'Income Days', value: '${summary.incomeDays}'),
            _Row(label: 'No Transaction Days', value: '${summary.noTransactionDays}'),
            const Divider(height: 24),
            _Row(
              label: 'Month Expense',
              value: AppFormatter.formatCurrency(summary.totalExpense),
            ),
            _Row(
              label: 'Month Income',
              value: AppFormatter.formatCurrency(summary.totalIncome),
            ),
            _Row(
              label: 'Activity Streak',
              value: '${streak.longestActivityStreak} days',
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}
