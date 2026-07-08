import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formatter.dart';
import '../../domain/entities/calendar_analytics_data.dart';

class DailyTimeline extends StatelessWidget {
  final AsyncValue<List<CalendarTransactionItem>> transactions;

  const DailyTimeline({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daily Transactions', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            transactions.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Text('No transactions for this day.');
                }
                return Column(
                  children: items.map((item) => _TimelineRow(item: item)).toList(),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (error, stack) => const Text('Unable to load timeline.'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final CalendarTransactionItem item;

  const _TimelineRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = item.type == 'income' ? Colors.green : Theme.of(context).colorScheme.error;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(AppFormatter.formatTime(item.date)),
          ),
          Icon(
            item.type == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title.isEmpty ? item.category : item.title),
                Text(
                  item.category,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          if (item.hasReceipt) const Icon(Icons.receipt_long, size: 16),
          const SizedBox(width: 8),
          Text(
            AppFormatter.formatCurrency(item.amount),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
