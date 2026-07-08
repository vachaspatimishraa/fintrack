import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/budget_provider.dart';
import '../widgets/budget_card.dart';
import 'add_edit_budget_screen.dart';

import '../widgets/category_budget_statistics_card.dart';
import '../../../../shared/widgets/offline_banner.dart';

class CategoryBudgetScreen extends ConsumerWidget {
  const CategoryBudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allBudgetsAsync = ref.watch(budgetsStreamProvider);
    final stats = ref.watch(categoryBudgetStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Budgets'),
      ),
      body: Column(
        children: [
          const OfflineBanner(message: 'Category budgets are managed locally.'),
          Expanded(
            child: allBudgetsAsync.when(
              data: (budgets) {
                final categoryBudgets = budgets.where((b) => b.budgetType == 'category').toList();
                
                if (categoryBudgets.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    CategoryBudgetStatisticsCard(
                      totalAllocated: stats['totalAllocated'],
                      totalSpent: stats['totalSpent'],
                      budgetCount: stats['count'],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Categories',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: () {}, // Ranking logic here
                          icon: const Icon(Icons.sort, size: 18),
                          label: const Text('Rank'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...categoryBudgets.map((b) => BudgetCard(budget: b)),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditBudgetScreen()),
          );
        },
        label: const Text('Add Category Budget'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(
              'No Category Budgets',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Text(
              'Create category budgets to manage spending more effectively.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddEditBudgetScreen()),
                );
              },
              child: const Text('Create Budget'),
            ),
          ],
        ),
      ),
    );
  }
}
