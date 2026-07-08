import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/budget_entity.dart';
import '../controllers/budget_controller.dart';
import '../../providers/budget_provider.dart';
import '../widgets/delete_budget_dialog.dart';
import 'add_edit_budget_screen.dart';

class BudgetDetailsScreen extends ConsumerWidget {
  final String budgetUuid;

  const BudgetDetailsScreen({super.key, required this.budgetUuid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(watchBudgetProvider(budgetUuid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () async {
              await ref.read(budgetControllerProvider).duplicateBudget(budgetUuid);
              if (context.mounted) Navigator.pop(context);
            },
          ),
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
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context, ref),
          ),
        ],
      ),
      body: budgetAsync.when(
        data: (budget) {
          if (budget == null) return const Center(child: Text('Budget not found'));
          return _buildBody(context, ref, budget);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, BudgetEntity budget) {
    final progress = budget.progress / 100;
    final color = progress > 1.0 ? Colors.red : (progress > 0.8 ? Colors.orange : Colors.blue);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(budget.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  '${NumberFormat.currency(symbol: '₹').format(budget.spentAmount)} / ${NumberFormat.currency(symbol: '₹').format(budget.amount)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: progress > 1.0 ? 1.0 : progress,
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(6),
                  backgroundColor: color.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${budget.progress.toStringAsFixed(1)}% used'),
                    Text('${NumberFormat.currency(symbol: '₹').format(budget.remainingAmount)} left'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoTile('Type', budget.budgetType.toUpperCase()),
        if (budget.categoryId != null) _buildInfoTile('Category', budget.categoryId!),
        _buildInfoTile('Period', '${DateFormat('MMM d').format(budget.startDate)} - ${DateFormat('MMM d').format(budget.endDate)}'),
        _buildInfoTile('Alert Threshold', '${budget.alertThreshold}%'),
        _buildInfoTile('Rollover', budget.rolloverEnabled ? 'Enabled' : 'Disabled'),
        if (budget.description != null && budget.description!.isNotEmpty)
          _buildInfoTile('Notes', budget.description!),
        const SizedBox(height: 24),
        if (budget.status == 'active' || budget.status == 'warning' || budget.status == 'exceeded')
          OutlinedButton(
            onPressed: () => ref.read(budgetControllerProvider).archiveBudget(budget.uuid),
            child: const Text('Archive Budget'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => DeleteBudgetDialog(
        onConfirm: () async {
          await ref.read(budgetControllerProvider).deleteBudget(budgetUuid);
          if (context.mounted) {
            Navigator.pop(context); // Close dialog
            Navigator.pop(context); // Go back from details
          }
        },
      ),
    );
  }
}
