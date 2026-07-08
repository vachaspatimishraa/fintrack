import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OverspendingAnalysisCard extends StatelessWidget {
  final double overspentAmount;
  final double utilization;

  const OverspendingAnalysisCard({super.key, required this.overspentAmount, required this.utilization});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final isOverspent = overspentAmount > 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Overspending Analysis', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOverspent ? 'Total Overspent' : 'No Overspending',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormat.format(overspentAmount),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isOverspent ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (utilization > 100 ? Colors.red : Colors.green).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${utilization.toStringAsFixed(1)}% Usage',
                    style: TextStyle(
                      color: utilization > 100 ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (isOverspent) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(
                value: 1.0,
                color: Colors.red,
                backgroundColor: Colors.transparent,
              ),
              const SizedBox(height: 8),
              Text(
                'You have exceeded your monthly limit. Review your categories to identify leaks.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
