import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/custom_report_provider.dart';

class FilterPanel extends ConsumerStatefulWidget {
  const FilterPanel({super.key});

  @override
  ConsumerState<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends ConsumerState<FilterPanel> {
  final _searchController = TextEditingController();
  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final filter = ref.read(customReportFilterProvider);
    _searchController.text = filter.searchQuery;
    if (filter.minAmount != null) {
      _minAmountController.text = filter.minAmount!.toString();
    }
    if (filter.maxAmount != null) {
      _maxAmountController.text = filter.maxAmount!.toString();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  void _applyAmountFilters() {
    final min = double.tryParse(_minAmountController.text);
    final max = double.tryParse(_maxAmountController.text);
    ref.read(customReportControllerProvider).updateAmountRange(min, max);
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(customReportFilterProvider);
    final sortBy = ref.watch(customReportSortByProvider);
    final controller = ref.watch(customReportControllerProvider);
    final theme = Theme.of(context);

    final transactionTypes = ['income', 'expense', 'transfer'];

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.filter_list, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Filters & Sorting',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Search field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search title, category, description...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          controller.updateSearchQuery('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (val) {
                setState(() {});
                controller.updateSearchQuery(val);
              },
            ),
            const SizedBox(height: 16),
            // Type Chips
            Text('Transaction Types', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: transactionTypes.map((type) {
                final isSelected = filter.selectedTypes.contains(type);
                return FilterChip(
                  label: Text(type[0].toUpperCase() + type.substring(1)),
                  selected: isSelected,
                  onSelected: (val) => controller.toggleType(type),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Amount Range
            Text('Amount Range', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minAmountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'Min Amount',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (val) => _applyAmountFilters(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _maxAmountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'Max Amount',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (val) => _applyAmountFilters(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Sorting Dropdown
            Text('Sort Order', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: sortBy,
              items: const [
                DropdownMenuItem(value: 'newest', child: Text('Newest First')),
                DropdownMenuItem(value: 'oldest', child: Text('Oldest First')),
                DropdownMenuItem(value: 'highestAmount', child: Text('Highest Amount')),
                DropdownMenuItem(value: 'lowestAmount', child: Text('Lowest Amount')),
                DropdownMenuItem(value: 'category', child: Text('Category')),
                DropdownMenuItem(value: 'account', child: Text('Wallet')),
              ],
              onChanged: (val) {
                if (val != null) {
                  ref.read(customReportSortByProvider.notifier).state = val;
                }
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
