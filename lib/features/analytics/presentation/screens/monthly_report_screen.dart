import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/monthly_report_provider.dart';
import '../../domain/entities/monthly_report_data.dart';
import '../controllers/monthly_report_controller.dart';
import '../widgets/monthly_summary_card.dart';
import '../widgets/monthly_statistics_card.dart';
import '../widgets/monthly_trend_chart.dart';
import '../widgets/monthly_budget_card.dart';
import '../widgets/category_breakdown_chart.dart';
import '../widgets/financial_score_card.dart';
import '../widgets/monthly_recommendation_card.dart';
import '../widgets/skeleton_monthly_report.dart';
import '../widgets/monthly_offline_banner.dart';

class MonthlyReportScreen extends ConsumerStatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  ConsumerState<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends ConsumerState<MonthlyReportScreen> {
  bool _offlineMode = false;

  void _changeMonth(DateTime current, int offset) {
    final nextMonth = DateTime(current.year, current.month + offset, 1);
    ref.read(selectedMonthProvider.notifier).state = nextMonth;
  }

  @override
  Widget build(BuildContext context) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final reportAsync = ref.watch(monthlyReportProvider);
    final controller = ref.watch(monthlyReportControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Report'),
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
          MonthlyOfflineBanner(isOffline: _offlineMode),
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
                          _buildMonthSelector(context, selectedMonth, controller),
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
                                      MonthlySummaryCard(summary: report.summary),
                                      const SizedBox(height: 16),
                                      MonthlyBudgetCard(budgetProgress: report.budgetProgress),
                                      const SizedBox(height: 16),
                                      MonthlyTrendChart(dailyBreakdown: report.dailyBreakdown),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      FinancialScoreCard(score: report.score),
                                      const SizedBox(height: 16),
                                      CategoryBreakdownChart(categories: report.categories),
                                      const SizedBox(height: 16),
                                      MonthlyRecommendationCard(recommendations: report.recommendations),
                                      const SizedBox(height: 16),
                                      MonthlyStatisticsCard(statistics: report.statistics),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                MonthlySummaryCard(summary: report.summary),
                                const SizedBox(height: 16),
                                MonthlyBudgetCard(budgetProgress: report.budgetProgress),
                                const SizedBox(height: 16),
                                CategoryBreakdownChart(categories: report.categories),
                                const SizedBox(height: 16),
                                MonthlyTrendChart(dailyBreakdown: report.dailyBreakdown),
                                const SizedBox(height: 16),
                                FinancialScoreCard(score: report.score),
                                const SizedBox(height: 16),
                                MonthlyRecommendationCard(recommendations: report.recommendations),
                                const SizedBox(height: 16),
                                MonthlyStatisticsCard(statistics: report.statistics),
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
              loading: () => const SkeletonMonthlyReport(),
              error: (err, stack) {
                return _buildErrorState(context, err.toString());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(BuildContext context, DateTime selectedMonth, MonthlyReportController controller) {
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
              onPressed: () => _changeMonth(selectedMonth, -1),
            ),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedMonth,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  initialDatePickerMode: DatePickerMode.year,
                );
                if (picked != null) {
                  ref.read(selectedMonthProvider.notifier).state = DateTime(picked.year, picked.month, 1);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Text(
                      controller.monthLabel(selectedMonth),
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
              onPressed: () => _changeMonth(selectedMonth, 1),
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
              'No Monthly Data',
              style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Complete a month of financial activity to generate your first monthly report.',
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
              'Unable to generate monthly report.',
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
                    ref.invalidate(monthlyReportProvider);
                  },
                  child: const Text('Retry'),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _offlineMode = true;
                    });
                    ref.invalidate(monthlyReportProvider);
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

  Widget _buildExportSection(BuildContext context, MonthlyReport report, MonthlyReportController controller) {
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
