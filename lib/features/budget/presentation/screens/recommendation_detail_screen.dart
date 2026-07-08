import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/budget_recommendation_entity.dart';
import '../controllers/recommendation_controller.dart';

class RecommendationDetailScreen extends ConsumerWidget {
  final BudgetRecommendationEntity recommendation;

  const RecommendationDetailScreen({super.key, required this.recommendation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommendation Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(_getIcon(recommendation.type), size: 48, color: Theme.of(context).primaryColor),
                    const SizedBox(height: 16),
                    Text(
                      recommendation.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Confidence: ${(recommendation.confidence * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Why this recommendation?', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(recommendation.reason),
            const SizedBox(height: 24),
            Text('Action Plan', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(recommendation.message),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: () async {
                  await ref.read(recommendationControllerProvider).applyRecommendation(recommendation.uuid);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Apply Recommendation'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () async {
                  await ref.read(recommendationControllerProvider).dismissRecommendation(recommendation.uuid);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Dismiss'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'budget_increase':
        return Icons.trending_up;
      case 'budget_decrease':
        return Icons.trending_down;
      default:
        return Icons.auto_awesome;
    }
  }
}
