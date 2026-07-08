import 'package:flutter/material.dart';
import '../../domain/entities/budget_alert_entity.dart';
import 'budget_alert_card.dart';

class BudgetAlertSection extends StatelessWidget {
  final List<BudgetAlertEntity> alerts;

  const BudgetAlertSection({super.key, required this.alerts});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Active Alerts',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        ...alerts.map((alert) => BudgetAlertCard(alert: alert)),
      ],
    );
  }
}
