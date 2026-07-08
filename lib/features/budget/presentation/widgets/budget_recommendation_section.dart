import 'package:flutter/material.dart';
import '../../domain/entities/budget_insight.dart';
import 'budget_insight_card.dart';

class BudgetRecommendationSection extends StatelessWidget {
  final List<BudgetInsight> recommendations;

  const BudgetRecommendationSection({super.key, required this.recommendations});

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Recommendations',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        ...recommendations.map((insight) => BudgetInsightCard(insight: insight)),
      ],
    );
  }
}
