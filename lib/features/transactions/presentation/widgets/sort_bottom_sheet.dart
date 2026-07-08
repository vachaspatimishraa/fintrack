import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/transaction_list_controller.dart';

class SortBottomSheet extends ConsumerWidget {
  const SortBottomSheet({super.key});

  static const List<Map<String, String>> _sortOptions = [
    {'value': 'newest', 'label': 'Newest First'},
    {'value': 'oldest', 'label': 'Oldest First'},
    {'value': 'highest_amount', 'label': 'Highest Amount'},
    {'value': 'lowest_amount', 'label': 'Lowest Amount'},
    {'value': 'alphabetical', 'label': 'Alphabetical (Title)'},
    {'value': 'category', 'label': 'Category Name'},
    {'value': 'recently_updated', 'label': 'Recently Updated'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listState = ref.watch(transactionListProvider);
    final notifier = ref.read(transactionListProvider.notifier);
    final currentSort = listState.filter.sortBy;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Sort Transactions By',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            ..._sortOptions.map((opt) {
              final isSelected = currentSort == opt['value'];
              return ListTile(
                title: Text(
                  opt['label']!,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Theme.of(context).colorScheme.primary : null,
                  ),
                ),
                trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
                onTap: () {
                  notifier.setSortBy(opt['value']!);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
