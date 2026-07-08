import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/budget_list_controller.dart';

class BudgetFilterSheet extends ConsumerWidget {
  const BudgetFilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(budgetListProvider).filter;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter Budgets', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: filter.status == null,
                  onSelected: (_) => ref.read(budgetListProvider.notifier).setStatus(null),
                ),
                _FilterChip(
                  label: 'Active',
                  isSelected: filter.status == 'active',
                  onSelected: (_) => ref.read(budgetListProvider.notifier).setStatus('active'),
                ),
                _FilterChip(
                  label: 'Warning',
                  isSelected: filter.status == 'warning',
                  onSelected: (_) => ref.read(budgetListProvider.notifier).setStatus('warning'),
                ),
                _FilterChip(
                  label: 'Exceeded',
                  isSelected: filter.status == 'exceeded',
                  onSelected: (_) => ref.read(budgetListProvider.notifier).setStatus('exceeded'),
                ),
                _FilterChip(
                  label: 'Archived',
                  isSelected: filter.status == 'archived',
                  onSelected: (_) => ref.read(budgetListProvider.notifier).setStatus('archived'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Apply'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
    );
  }
}
