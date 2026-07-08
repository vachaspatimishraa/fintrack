import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/custom_report_provider.dart';

class CustomReportBuilder extends ConsumerWidget {
  const CustomReportBuilder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupBy = ref.watch(customReportGroupByProvider);
    final theme = Theme.of(context);

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
                Icon(Icons.query_stats_outlined, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Grouping Preferences',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Group Results By', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: groupBy,
              items: const [
                DropdownMenuItem(value: 'category', child: Text('Category')),
                DropdownMenuItem(value: 'account', child: Text('Account')),
                DropdownMenuItem(value: 'day', child: Text('Day')),
                DropdownMenuItem(value: 'week', child: Text('Week')),
                DropdownMenuItem(value: 'month', child: Text('Month')),
                DropdownMenuItem(value: 'quarter', child: Text('Quarter')),
                DropdownMenuItem(value: 'year', child: Text('Year')),
              ],
              onChanged: (val) {
                if (val != null) {
                  ref.read(customReportGroupByProvider.notifier).state = val;
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
