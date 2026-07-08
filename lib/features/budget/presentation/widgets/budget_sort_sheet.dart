import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/budget_list_controller.dart';

class BudgetSortSheet extends ConsumerWidget {
  const BudgetSortSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortBy = ref.watch(budgetListProvider).filter.sortBy;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Sort By', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          _SortTile(
            label: 'Newest First',
            value: 'newest',
            groupValue: sortBy,
            onChanged: (val) => _handleSort(ref, context, val!),
          ),
          _SortTile(
            label: 'Oldest First',
            value: 'oldest',
            groupValue: sortBy,
            onChanged: (val) => _handleSort(ref, context, val!),
          ),
          _SortTile(
            label: 'Name (A-Z)',
            value: 'name',
            groupValue: sortBy,
            onChanged: (val) => _handleSort(ref, context, val!),
          ),
          _SortTile(
            label: 'Highest Amount',
            value: 'amount_high',
            groupValue: sortBy,
            onChanged: (val) => _handleSort(ref, context, val!),
          ),
          _SortTile(
            label: 'Lowest Amount',
            value: 'amount_low',
            groupValue: sortBy,
            onChanged: (val) => _handleSort(ref, context, val!),
          ),
          _SortTile(
            label: 'Highest Progress',
            value: 'progress_high',
            groupValue: sortBy,
            onChanged: (val) => _handleSort(ref, context, val!),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _handleSort(WidgetRef ref, BuildContext context, String value) {
    ref.read(budgetListProvider.notifier).setSortBy(value);
    Navigator.pop(context);
  }
}

class _SortTile extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _SortTile({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
    );
  }
}
