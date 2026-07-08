import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/budget_entity.dart';

class OverallBudgetCard extends StatelessWidget {
  final BudgetEntity? budget;

  const OverallBudgetCard({super.key, this.budget});

  @override
  Widget build(BuildContext context) {
    if (budget == null) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.account_balance_wallet, color: Colors.grey),
          title: const Text('No Overall Budget Set'),
          subtitle: const Text('Tap to set a monthly spending limit'),
          onTap: () {
            // Navigate to create budget
          },
        ),
      );
    }

    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final progress = (budget!.spentAmount / budget!.amount).clamp(0.0, 1.0);
    final color = budget!.progress > 100 ? Colors.red : (budget!.progress > 80 ? Colors.orange : Colors.blue);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overall Budget',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${budget!.progress.toStringAsFixed(1)}%',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAmountItem('Allocated', currencyFormat.format(budget!.amount)),
                _buildAmountItem('Spent', currencyFormat.format(budget!.spentAmount)),
                _buildAmountItem('Remaining', currencyFormat.format(budget!.remainingAmount), isHighlighted: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountItem(String label, String value, {bool isHighlighted = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isHighlighted ? 16 : 14,
            color: isHighlighted ? Colors.blue : null,
          ),
        ),
      ],
    );
  }
}
