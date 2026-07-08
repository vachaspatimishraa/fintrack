import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/budget_statistics.dart';

class BudgetStatisticsCard extends StatelessWidget {
  final BudgetStatistics statistics;

  const BudgetStatisticsCard({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatBox(
                    label: 'Active',
                    value: statistics.activeBudgets.toString(),
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _StatBox(
                    label: 'Exceeded',
                    value: statistics.exceededBudgets.toString(),
                    icon: Icons.error_outline,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              children: [
                Expanded(
                  child: _StatBox(
                    label: 'Avg Spending',
                    value: currencyFormat.format(statistics.averageSpending),
                    icon: Icons.trending_up,
                    color: Colors.orange,
                  ),
                ),
                Expanded(
                  child: _StatBox(
                    label: 'Total Savings',
                    value: currencyFormat.format(statistics.remaining),
                    icon: Icons.savings_outlined,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
      ],
    );
  }
}
