import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/custom_report_provider.dart';

class SavedReportsScreen extends ConsumerWidget {
  const SavedReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedReportsAsync = ref.watch(savedReportsProvider);
    final controller = ref.watch(customReportControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Templates'),
      ),
      body: savedReportsAsync.when(
        data: (reports) {
          if (reports.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open_outlined, size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  Text('No saved report templates', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('Save templates in the Report Builder to see them here', style: theme.textTheme.bodyMedium),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final report = reports[index];
              return Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
                ),
                child: ListTile(
                  title: Text(report.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Grouped by: ${report.groupBy} | Sorted by: ${report.sortBy}'),
                      Text('Created: ${DateFormat('d MMM yyyy').format(report.createdAt)}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Template'),
                          content: const Text('Are you sure you want to delete this report template?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () {
                                controller.deleteReport(report.uuid);
                                Navigator.of(ctx).pop();
                              },
                              child: Text('Delete', style: TextStyle(color: theme.colorScheme.error)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  onTap: () {
                    controller.loadPreset(report);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Loaded template "${report.name}"')),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading saved templates: $err')),
      ),
    );
  }
}
