import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/custom_report_provider.dart';

class CustomDateRangePicker extends ConsumerWidget {
  const CustomDateRangePicker({super.key});

  void _selectPreset(BuildContext context, WidgetRef ref, String preset) {
    final now = DateTime.now();
    DateTime? start;
    DateTime? end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (preset) {
      case 'today':
        start = DateTime(now.year, now.month, now.day);
        break;
      case 'yesterday':
        start = DateTime(now.year, now.month, now.day - 1);
        end = DateTime(now.year, now.month, now.day - 1, 23, 59, 59);
        break;
      case 'last7':
        start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));
        break;
      case 'last30':
        start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 30));
        break;
      case 'this_month':
        start = DateTime(now.year, now.month, 1);
        break;
      case 'last_month':
        start = DateTime(now.year, now.month - 1, 1);
        end = DateTime(now.year, now.month, 1).subtract(const Duration(seconds: 1));
        break;
      case 'this_quarter':
        final q = ((now.month - 1) / 3).floor();
        start = DateTime(now.year, q * 3 + 1, 1);
        break;
      case 'this_year':
        start = DateTime(now.year, 1, 1);
        break;
      case 'custom':
      default:
        _showCustomRangePicker(context, ref);
        return;
    }

    ref.read(customReportControllerProvider).updateDateRange(start, end);
  }

  Future<void> _showCustomRangePicker(BuildContext context, WidgetRef ref) async {
    final filter = ref.read(customReportFilterProvider);
    final initialRange = (filter.startDate != null && filter.endDate != null)
        ? DateTimeRange(start: filter.startDate!, end: filter.endDate!)
        : null;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: initialRange,
    );

    if (picked != null) {
      ref.read(customReportControllerProvider).updateDateRange(
            picked.start,
            DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59),
          );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(customReportFilterProvider);
    final theme = Theme.of(context);

    String label = 'All Time';
    if (filter.startDate != null && filter.endDate != null) {
      final f = DateFormat('d MMM yyyy');
      label = '${f.format(filter.startDate!)} - ${f.format(filter.endDate!)}';
    } else if (filter.startDate != null) {
      label = 'From ${DateFormat('d MMM yyyy').format(filter.startDate!)}';
    } else if (filter.endDate != null) {
      label = 'Until ${DateFormat('d MMM yyyy').format(filter.endDate!)}';
    }

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
                Icon(Icons.calendar_today_outlined, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Date Range',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _showCustomRangePicker(context, ref),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _PresetChip(label: 'Today', onTap: () => _selectPreset(context, ref, 'today')),
                  const SizedBox(width: 8),
                  _PresetChip(label: 'Yesterday', onTap: () => _selectPreset(context, ref, 'yesterday')),
                  const SizedBox(width: 8),
                  _PresetChip(label: 'Last 7 Days', onTap: () => _selectPreset(context, ref, 'last7')),
                  const SizedBox(width: 8),
                  _PresetChip(label: 'Last 30 Days', onTap: () => _selectPreset(context, ref, 'last30')),
                  const SizedBox(width: 8),
                  _PresetChip(label: 'This Month', onTap: () => _selectPreset(context, ref, 'this_month')),
                  const SizedBox(width: 8),
                  _PresetChip(label: 'Last Month', onTap: () => _selectPreset(context, ref, 'last_month')),
                  const SizedBox(width: 8),
                  _PresetChip(label: 'This Year', onTap: () => _selectPreset(context, ref, 'this_year')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}
