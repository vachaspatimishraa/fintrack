import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../budget/providers/budget_provider.dart';
import '../../providers/custom_report_provider.dart';

class BudgetFilterSheet extends ConsumerWidget {
  const BudgetFilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetsStreamProvider);
    final filter = ref.watch(customReportFilterProvider);
    final controller = ref.watch(customReportControllerProvider);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter by Budget',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  // Clear categories filter to reset budget category filtering
                  controller.updateCategories([]);
                },
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          budgetsAsync.when(
            data: (budgets) {
              if (budgets.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(
                    'No budgets defined',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                  ),
                );
              }

              return ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: budgets.length,
                  itemBuilder: (context, index) {
                    final budget = budgets[index];
                    final isSelected = budget.categoryId != null &&
                        filter.selectedCategories.contains(budget.categoryId);

                    return ListTile(
                      title: Text(budget.title),
                      subtitle: Text('Limit: ₹${budget.amount.toStringAsFixed(2)} | Spent: ₹${budget.spentAmount.toStringAsFixed(2)}'),
                      trailing: isSelected ? Icon(Icons.check, color: theme.colorScheme.primary) : null,
                      onTap: () {
                        if (budget.categoryId != null) {
                          controller.updateCategories([budget.categoryId!]);
                        }
                        Navigator.of(context).pop();
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error loading budgets: $err')),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
