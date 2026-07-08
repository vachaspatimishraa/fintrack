import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/custom_report_provider.dart';
import '../controllers/custom_report_controller.dart';
import '../widgets/date_range_picker.dart';
import '../widgets/filter_panel.dart';
import '../widgets/custom_report_builder.dart';
import '../widgets/account_filter_sheet.dart';
import '../widgets/category_filter_sheet.dart';
import '../widgets/budget_filter_sheet.dart';
import '../widgets/custom_offline_banner.dart';
import 'report_preview_screen.dart';
import 'saved_reports_screen.dart';

class CustomReportScreen extends ConsumerStatefulWidget {
  const CustomReportScreen({super.key});

  @override
  ConsumerState<CustomReportScreen> createState() => _CustomReportScreenState();
}

class _CustomReportScreenState extends ConsumerState<CustomReportScreen> {
  final bool _offlineMode = false;

  void _showSaveDialog(BuildContext context, CustomReportController controller, String groupBy, String sortBy) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save Report Template'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Enter template name (e.g. Monthly Food Expense)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                await controller.saveReport(name, groupBy, sortBy, 'bar');
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Template "$name" saved successfully!')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(customReportFilterProvider);
    final groupBy = ref.watch(customReportGroupByProvider);
    final sortBy = ref.watch(customReportSortByProvider);
    final controller = ref.watch(customReportControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Report Builder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_special_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SavedReportsScreen()),
              );
            },
            tooltip: 'Saved Templates',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.clearFilters(),
            tooltip: 'Clear Filters',
          ),
        ],
      ),
      body: Column(
        children: [
          CustomOfflineBanner(isOffline: _offlineMode),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Date range picker
                  const CustomDateRangePicker(),
                  const SizedBox(height: 12),

                  // Sheet filters
                  Card(
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
                              Icon(Icons.tune, color: theme.colorScheme.primary, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                'Select Dimensions',
                                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _FilterSheetTile(
                            label: 'Accounts',
                            status: filter.selectedAccounts.isEmpty ? 'All Selected' : '${filter.selectedAccounts.length} Filtered',
                            icon: Icons.account_balance_outlined,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
                                builder: (_) => const AccountFilterSheet(),
                              );
                            },
                          ),
                          const Divider(height: 16),
                          _FilterSheetTile(
                            label: 'Categories',
                            status: filter.selectedCategories.isEmpty ? 'All Selected' : '${filter.selectedCategories.length} Filtered',
                            icon: Icons.category_outlined,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
                                builder: (_) => const CategoryFilterSheet(),
                              );
                            },
                          ),
                          const Divider(height: 16),
                          _FilterSheetTile(
                            label: 'Link to Budget',
                            status: 'Optional',
                            icon: Icons.pie_chart_outline,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
                                builder: (_) => const BudgetFilterSheet(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter Panel
                  const FilterPanel(),
                  const SizedBox(height: 12),

                  // Grouping & Sorting Preferences
                  const CustomReportBuilder(),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.bookmark_outline),
                          label: const Text('Save Template'),
                          onPressed: () => _showSaveDialog(context, controller, groupBy, sortBy),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.query_stats),
                          label: const Text('Generate Report'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ReportPreviewScreen()),
                            );
                          },
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSheetTile extends StatelessWidget {
  final String label;
  final String status;
  final IconData icon;
  final VoidCallback onTap;

  const _FilterSheetTile({
    required this.label,
    required this.status,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            ),
            Text(status, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }
}
