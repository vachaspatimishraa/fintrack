import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/transaction_list_controller.dart';

class QuickFilterChips extends ConsumerWidget {
  const QuickFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listState = ref.watch(transactionListProvider);
    final notifier = ref.read(transactionListProvider.notifier);
    final filter = listState.filter;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Today Chip
          _filterChip(
            context: context,
            label: 'Today',
            isSelected: _isToday(filter.dateRange),
            onSelected: (selected) {
              final range = selected ? DateTimeRange(
                start: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                end: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
              ) : null;
              notifier.updateFilter(filter.copyWith(dateRange: range));
            },
          ),
          const SizedBox(width: 8),

          // Week Chip (7 Days)
          _filterChip(
            context: context,
            label: 'Week',
            isSelected: _isPast7Days(filter.dateRange),
            onSelected: (selected) {
              final range = selected ? DateTimeRange(
                start: DateTime.now().subtract(const Duration(days: 7)),
                end: DateTime.now(),
              ) : null;
              notifier.updateFilter(filter.copyWith(dateRange: range));
            },
          ),
          const SizedBox(width: 8),

          // Month Chip
          _filterChip(
            context: context,
            label: 'Month',
            isSelected: _isThisMonth(filter.dateRange),
            onSelected: (selected) {
              final range = selected ? DateTimeRange(
                start: DateTime(DateTime.now().year, DateTime.now().month, 1),
                end: DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
              ) : null;
              notifier.updateFilter(filter.copyWith(dateRange: range));
            },
          ),
          const SizedBox(width: 8),

          // Income Chip
          _filterChip(
            context: context,
            label: 'Income',
            isSelected: filter.type == 'income',
            onSelected: (selected) {
              notifier.updateFilter(filter.copyWith(type: selected ? 'income' : null));
            },
          ),
          const SizedBox(width: 8),

          // Expense Chip
          _filterChip(
            context: context,
            label: 'Expense',
            isSelected: filter.type == 'expense',
            onSelected: (selected) {
              notifier.updateFilter(filter.copyWith(type: selected ? 'expense' : null));
            },
          ),
          const SizedBox(width: 8),

          // Receipt Chip
          _filterChip(
            context: context,
            label: 'Receipt',
            isSelected: filter.hasReceipt == true,
            onSelected: (selected) {
              notifier.updateFilter(filter.copyWith(hasReceipt: selected ? true : null));
            },
          ),
          const SizedBox(width: 8),

          // Pending Sync Chip
          _filterChip(
            context: context,
            label: 'Pending Sync',
            isSelected: filter.syncStatus == 'pending',
            onSelected: (selected) {
              notifier.updateFilter(filter.copyWith(syncStatus: selected ? 'pending' : null));
            },
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
  }) {
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  bool _isToday(DateTimeRange? range) {
    if (range == null) return false;
    final now = DateTime.now();
    return range.start.year == now.year &&
        range.start.month == now.month &&
        range.start.day == now.day &&
        range.end.year == now.year &&
        range.end.month == now.month &&
        range.end.day == now.day;
  }

  bool _isPast7Days(DateTimeRange? range) {
    if (range == null) return false;
    final diff = range.end.difference(range.start).inDays;
    return diff >= 6 && diff <= 8 && range.end.isAfter(DateTime.now().subtract(const Duration(minutes: 10)));
  }

  bool _isThisMonth(DateTimeRange? range) {
    if (range == null) return false;
    final now = DateTime.now();
    return range.start.year == now.year &&
        range.start.month == now.month &&
        range.start.day == 1;
  }
}
