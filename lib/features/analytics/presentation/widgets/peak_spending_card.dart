import 'package:flutter/material.dart';

import '../../../../core/utils/formatter.dart';
import '../../domain/entities/spending_trend_data.dart';

class PeakSpendingCard extends StatelessWidget {
  final List<SpendingPeriodInsight> peaks;
  final List<SpendingPeriodInsight> lows;

  const PeakSpendingCard({
    super.key,
    required this.peaks,
    required this.lows,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Peak Spending Days', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...peaks.take(3).map((item) => _InsightRow(item: item)),
            if (lows.isNotEmpty) ...[
              const Divider(height: 24),
              Text('Low Spending Periods', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              ...lows.take(2).map((item) => _InsightRow(item: item)),
            ],
          ],
        ),
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final SpendingPeriodInsight item;

  const _InsightRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(item.label)),
          Text(
            AppFormatter.formatCurrency(item.amount),
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}
