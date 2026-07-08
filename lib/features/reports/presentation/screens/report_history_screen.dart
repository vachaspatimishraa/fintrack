import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/report_history_model.dart';
import '../../providers/report_history_provider.dart';
import '../controllers/report_history_controller.dart';

class ReportHistoryScreen extends ConsumerWidget {
  const ReportHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final historyList = ref.watch(reportHistoryListProvider);
    final storageAsync = ref.watch(storageUsageProvider);
    final controller = ref.watch(reportHistoryControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services_outlined),
            onPressed: () => _showCleanupDialog(context, controller),
            tooltip: 'Clear Archive',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SearchBar(
              hintText: 'Search report name, format or type...',
              leading: const Icon(Icons.search),
              elevation: WidgetStateProperty.all(0),
              backgroundColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHigh),
              onChanged: controller.updateSearchQuery,
            ),
          ),
          _buildFilterChips(context, ref, controller),
          _buildStorageCard(context, storageAsync),
          Expanded(
            child: historyList.isEmpty
                ? _buildEmptyState(context)
                : ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: historyList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildReportCard(context, historyList[index], controller);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, WidgetRef ref, ReportHistoryController controller) {
    final theme = Theme.of(context);
    final selectedFormat = ref.watch(reportHistoryFormatFilterProvider);

    final formats = [
      {'label': 'All formats', 'value': null},
      {'label': 'PDF', 'value': 'PDF'},
      {'label': 'Excel', 'value': 'Excel'},
      {'label': 'CSV', 'value': 'CSV'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: formats.map((f) {
          final isSelected = selectedFormat == f['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(f['label'] as String),
              selected: isSelected,
              onSelected: (selected) {
                controller.updateFormatFilter(selected ? f['value'] : null);
              },
              selectedColor: theme.colorScheme.primaryContainer,
              checkmarkColor: theme.colorScheme.onPrimaryContainer,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStorageCard(BuildContext context, AsyncValue<Map<String, dynamic>> storageAsync) {
    final theme = Theme.of(context);

    return storageAsync.when(
      data: (storage) {
        final int count = storage['totalCount'] as int? ?? 0;
        final double sizeMb = storage['totalSize'] as double? ?? 0.0;
        final double avgKb = storage['averageSize'] as double? ?? 0.0;

        return Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          color: theme.colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.4)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStorageMetric(context, 'Reports', '$count'),
                _buildStorageMetric(context, 'Storage Used', '${sizeMb.toStringAsFixed(2)} MB'),
                _buildStorageMetric(context, 'Avg Size', '${avgKb.toStringAsFixed(0)} KB'),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildStorageMetric(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildReportCard(BuildContext context, ReportHistoryEntry entry, ReportHistoryController controller) {
    final theme = Theme.of(context);
    final sizeKb = entry.fileSize / 1024;

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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    entry.exportFormat.toUpperCase() == 'PDF'
                        ? Icons.picture_as_pdf_outlined
                        : Icons.table_chart_outlined,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.reportName,
                        style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${entry.reportType} • ${entry.exportFormat} • ${sizeKb.toStringAsFixed(0)} KB',
                        style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (action) {
                    if (action == 'rename') {
                      _showRenameDialog(context, entry, controller);
                    } else if (action == 'delete') {
                      controller.deleteReport(entry.id);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'rename',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 12),
                          Text('Rename'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18, color: theme.colorScheme.error),
                          const SizedBox(width: 12),
                          Text('Delete', style: TextStyle(color: theme.colorScheme.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('d MMM yyyy, h:mm a').format(entry.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                      ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share_outlined, size: 20),
                      onPressed: () {
                        // Action for share mock
                      },
                      tooltip: 'Share',
                    ),
                    IconButton(
                      icon: const Icon(Icons.print_outlined, size: 20),
                      onPressed: () {
                        // Action for print mock
                      },
                      tooltip: 'Print',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off_outlined,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.4),
          ),
          const SizedBox(height: 24),
          Text(
            'No Report History Found',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Exported PDF, CSV, or Excel reports will appear here.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, ReportHistoryEntry entry, ReportHistoryController controller) {
    final textController = TextEditingController(text: entry.reportName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Report'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'Enter new name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  controller.renameReport(entry.id, textController.text);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showCleanupDialog(BuildContext context, ReportHistoryController controller) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear Export Archive'),
          content: const Text('Are you sure you want to delete every exported report history? Actual files remain on your device.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                controller.clearAll();
                Navigator.of(context).pop();
              },
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }
}
