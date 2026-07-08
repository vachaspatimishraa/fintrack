import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SavingsAnalysisCard extends StatelessWidget {
  final double savings;
  final double successRate;

  const SavingsAnalysisCard({super.key, required this.savings, required this.successRate});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Savings Analysis', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 16),
            Row(
              children: [
                _SavingsItem(
                  label: 'Monthly Savings',
                  value: currencyFormat.format(savings),
                  icon: Icons.savings_outlined,
                  color: Colors.teal,
                ),
                const SizedBox(width: 16),
                _SavingsItem(
                  label: 'Success Rate',
                  value: '${successRate.toStringAsFixed(0)}%',
                  icon: Icons.assignment_turned_in_outlined,
                  color: Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SavingsItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SavingsItem({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
