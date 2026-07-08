import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CategoryBudgetStatisticsCard extends StatelessWidget {
  final double totalAllocated;
  final double totalSpent;
  final int budgetCount;

  const CategoryBudgetStatisticsCard({
    super.key,
    required this.totalAllocated,
    required this.totalSpent,
    required this.budgetCount,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final remaining = totalAllocated - totalSpent;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatItem(
                  label: 'Category Budgets',
                  value: budgetCount.toString(),
                  icon: Icons.category,
                  color: Colors.blue,
                ),
                _StatItem(
                  label: 'Total Allocated',
                  value: currencyFormat.format(totalAllocated),
                  icon: Icons.account_balance_wallet,
                  color: Colors.green,
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatItem(
                  label: 'Total Spent',
                  value: currencyFormat.format(totalSpent),
                  icon: Icons.shopping_cart,
                  color: Colors.orange,
                ),
                _StatItem(
                  label: 'Remaining',
                  value: currencyFormat.format(remaining),
                  icon: Icons.savings,
                  color: remaining < 0 ? Colors.red : Colors.teal,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
