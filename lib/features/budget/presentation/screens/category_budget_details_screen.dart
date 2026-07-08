import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/budget_provider.dart';
import '../widgets/category_budget_progress_ring.dart';
import '../widgets/category_budget_statistics_card.dart';
import 'add_edit_budget_screen.dart';

class CategoryBudgetDetailsScreen extends ConsumerWidget {
  final String budgetUuid;

  const CategoryBudgetDetailsScreen({super.key, required this.budgetUuid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(watchBudgetProvider(budgetUuid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              budgetAsync.whenData((budget) {
                if (budget != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddEditBudgetScreen(budget: budget)),
                  );
                }
              });
            },
          ),
        ],
      ),
      body: budgetAsync.when(
        data: (budget) {
          if (budget == null) return const Center(child: Text('Budget not found'));
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CategoryBudgetProgressRing(progress: budget.progress),
                const SizedBox(height: 24),
                Text(
                  budget.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  DateFormat('MMMM yyyy').format(budget.startDate),
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                CategoryBudgetStatisticsCard(
                  totalAllocated: budget.amount,
                  totalSpent: budget.spentAmount,
                  budgetCount: 1,
                ),
                const SizedBox(height: 24),
                _buildInfoSection(context, budget),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, dynamic budget) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    return Card(
      child: Column(
        children: [
          _buildInfoTile(context, 'Category', budget.categoryId ?? 'N/A', Icons.category),
          _buildInfoTile(context, 'Remaining Amount', currencyFormat.format(budget.remainingAmount), Icons.account_balance_wallet),
          _buildInfoTile(context, 'Alert Threshold', '${budget.alertThreshold}%', Icons.notification_important),
          _buildInfoTile(context, 'Rollover', budget.rolloverEnabled ? 'Yes' : 'No', Icons.restart_alt),
          if (budget.description != null && budget.description!.isNotEmpty)
            _buildInfoTile(context, 'Notes', budget.description!, Icons.notes),
        ],
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, String label, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, size: 20, color: Colors.grey[600]),
      title: Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
