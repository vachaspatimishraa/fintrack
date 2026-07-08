import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/yearly_report_provider.dart';
import '../../domain/entities/yearly_report_data.dart';
import '../controllers/yearly_report_controller.dart';
import '../widgets/yearly_summary_card.dart';
import '../widgets/yearly_statistics_card.dart';
import '../widgets/monthly_breakdown_chart.dart';
import '../widgets/budget_performance_card.dart';
import '../widgets/category_distribution_chart.dart';
import '../widgets/financial_health_card.dart';
import '../widgets/annual_insights_card.dart';
import '../widgets/skeleton_yearly_report.dart';
import '../widgets/yearly_offline_banner.dart';

class YearlyReportScreen extends ConsumerStatefulWidget {
  const YearlyReportScreen({super.key});

  @override
  ConsumerState<YearlyReportScreen> createState() => _YearlyReportScreenState();
}

class _YearlyReportScreenState extends ConsumerState<YearlyReportScreen> {
  bool _offlineMode = false;

  void _changeYear(DateTime current, int offset) {
    final nextYear = DateTime(current.year + offset, 1, 1);
    ref.read(selectedYearProvider.notifier).state = nextYear;
  }

  @override
  Widget build(BuildContext context) {
    final selectedYear = ref.watch(selectedYearProvider);
    final reportAsync = ref.watch(yearlyReportProvider);
    final controller = ref.watch(yearlyReportControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yearly Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              reportAsync.whenData((report) => controller.shareReport(report));
            },
            tooltip: 'Share Report',
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () {
              reportAsync.whenData((report) => controller.exportPDF(report));
            },
            tooltip: 'Export as PDF',
          ),
        ],
      ),
      body: Column(
        children: [
          YearlyOfflineBanner(isOffline: _offlineMode),
          Expanded(
            child: reportAsync.when(
              data: (report) {
                if (report.isEmpty) {
                  return _buildEmptyState(context);
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isWide = constraints.maxWidth > 720;
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildYearSelector(context, selectedYear, controller),
                          const SizedBox(height: 16),
                          if (isWide)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      YearlySummaryCard(summary: report.summary),
                                      const SizedBox(height: 16),
                                      MonthlyBreakdownChart(monthlyBreakdown: report.monthlyBreakdown),
                                      const SizedBox(height: 16),
                                      BudgetPerformanceCard(budgetProgress: report.budgetProgress),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      FinancialHealthCard(health: report.health),
                                      const SizedBox(height: 16),
                                      CategoryDistributionChart(categories: report.categories),
                                      const SizedBox(height: 16),
                                      AnnualInsightsCard(insights: report.insights),
                                      const SizedBox(height: 16),
                                      YearlyStatisticsCard(statistics: report.statistics),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                YearlySummaryCard(summary: report.summary),
                                const SizedBox(height: 16),
                                MonthlyBreakdownChart(monthlyBreakdown: report.monthlyBreakdown),
                                const SizedBox(height: 16),
                                CategoryDistributionChart(categories: report.categories),
                                const SizedBox(height: 16),
                                BudgetPerformanceCard(budgetProgress: report.budgetProgress),
                                const SizedBox(height: 16),
                                FinancialHealthCard(health: report.health),
                                const SizedBox(height: 16),
                                AnnualInsightsCard(insights: report.insights),
                                const SizedBox(height: 16),
                                YearlyStatisticsCard(statistics: report.statistics),
                              ],
                            ),
                          const SizedBox(height: 24),
                          _buildExportSection(context, report, controller),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const SkeletonYearlyReport(),
              error: (err, stack) {
                return _buildErrorState(context, err.toString());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearSelector(BuildContext context, DateTime selectedYear, YearlyReportController controller) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withOpacity(0.24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => _changeYear(selectedYear, -1),
            ),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedYear,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  initialDatePickerMode: DatePickerMode.year,
                );
                if (picked != null) {
                  ref.read(selectedYearProvider.notifier).state = DateTime(picked.year, 1, 1);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Text(
                      controller.yearLabel(selectedYear),
                      style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_drop_down,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => _changeYear(selectedYear, 1),
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.4),
            ),
            const SizedBox(height: 24),
            Text(
              'No Yearly Data Available',
              style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Complete financial activity throughout the year to generate yearly insights.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Transactions'),
              onPressed: () {
                Navigator.of(context).pushNamed('/add-transaction');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_outlined,
              size: 80,
              color: theme.colorScheme.error.withOpacity(0.6),
            ),
            const SizedBox(height: 24),
            Text(
              'Unable to generate yearly report.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(yearlyReportProvider);
                  },
                  child: const Text('Retry'),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _offlineMode = true;
                    });
                    ref.invalidate(yearlyReportProvider);
                  },
                  child: const Text('Continue Offline'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportSection(BuildContext context, YearlyReport report, YearlyReportController controller) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Report',
              style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _ExportButton(
                  label: 'PDF',
                  icon: Icons.picture_as_pdf,
                  onPressed: () => controller.exportPDF(report),
                ),
                _ExportButton(
                  label: 'Excel',
                  icon: Icons.grid_on,
                  onPressed: () => controller.exportExcel(report),
                ),
                _ExportButton(
                  label: 'CSV',
                  icon: Icons.article_outlined,
                  onPressed: () => controller.exportCSV(report),
                ),
                _ExportButton(
                  label: 'Print',
                  icon: Icons.print_outlined,
                  onPressed: () => controller.printReport(report),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _ExportButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OutlinedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
