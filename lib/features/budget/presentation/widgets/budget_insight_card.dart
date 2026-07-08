import 'package:flutter/material.dart';
import '../../domain/entities/budget_insight.dart';

class BudgetInsightCard extends StatelessWidget {
  final BudgetInsight insight;

  const BudgetInsightCard({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: insight.color.withOpacity(0.05),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: insight.color.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Icon(insight.icon, color: insight.color),
        title: Text(
          insight.message,
          style: TextStyle(fontSize: 14, color: insight.color.withOpacity(0.8), fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
