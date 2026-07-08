import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/recommendation_provider.dart';
import '../widgets/recommendation_card.dart';
import '../../../../shared/widgets/offline_banner.dart';

class BudgetRecommendationScreen extends ConsumerWidget {
  const BudgetRecommendationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationsAsync = ref.watch(recommendationsStreamProvider);
    // Ensure recommendations are generated
    ref.watch(budgetRecommendationGeneratorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Financial Coach'),
      ),
      body: Column(
        children: [
          const OfflineBanner(message: 'Personalized advice generated on-device.'),
          Expanded(
            child: recommendationsAsync.when(
              data: (recs) {
                if (recs.isEmpty) {
                  return _buildEmptyState(context);
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: recs.length,
                  itemBuilder: (context, index) => RecommendationCard(recommendation: recs[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Everything looks great!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'No new recommendations at the moment.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
