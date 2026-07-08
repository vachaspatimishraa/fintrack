import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/formatter.dart';
import '../../domain/utils/income_growth_calculator.dart';
import '../../providers/income_provider.dart';
import '../widgets/banners.dart';
import '../widgets/income_insights_widget.dart';
import '../widgets/income_pie_chart.dart';
import '../widgets/income_sources_list.dart';
import '../widgets/income_statistics_card.dart';
import '../widgets/income_trend_chart.dart';
import '../widgets/skeleton_loaders.dart';

class IncomeAnalyticsScreen extends ConsumerWidget {
  const IncomeAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(incomeReportProvider);
    final selectedFilter = ref.watch(incomeTimeFilterProvider);
    final controller = ref.watch(incomeControllerProvider);
    final periodLabel = ref.watch(incomePeriodLabelProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Income Analytics'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Offline banner
            OfflineBanner(isOffline: controller.isOfflineMode()),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Time Filter Dropdown
                  SegmentedButton<String>(
                    selected: {selectedFilter},
                    onSelectionChanged: (Set<String> newSelection) {
                      ref.read(incomeTimeFilterProvider.notifier).state =
                          newSelection.first;
                    },
                    segments: const <ButtonSegment<String>>[
                      ButtonSegment<String>(
                        value: 'today',
                        label: Text('Today'),
                      ),
                      ButtonSegment<String>(
                        value: '7days',
                        label: Text('7 Days'),
                      ),
                      ButtonSegment<String>(
                        value: '30days',
                        label: Text('30 Days'),
                      ),
                      ButtonSegment<String>(
                        value: 'thisMonth',
                        label: Text('Month'),
                      ),
                      ButtonSegment<String>(
                        value: 'thisYear',
                        label: Text('Year'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Main content based on async state
                  reportAsync.when(
                    data: (report) {
                      if (controller.isEmpty(report)) {
                        return _buildEmptyState(context);
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Total Income KPI Card
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Income',
                                    style:
                                        Theme.of(context).textTheme.labelMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          AppFormatter.formatCurrency(
                                              report.totalIncome),
                                          style: Theme.of(context)
                                              .textTheme
                                              .displaySmall
                                              ?.copyWith(
                                                color: Colors.green,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: report.comparison
                                                  .growthPercentage >=
                                              0
                                              ? Colors.green.withOpacity(0.1)
                                              : Colors.red.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          IncomeGrowthCalculator
                                              .formatGrowth(report.comparison
                                                  .growthPercentage),
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium
                                              ?.copyWith(
                                                color: report.comparison
                                                        .growthPercentage >=
                                                    0
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    periodLabel,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color:
                                              colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Trend Chart
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Income Trend',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 16),
                                  IncomeTrendChart(points: report.points),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Income Sources
                          IncomeSourcesList(
                            sources: report.sources,
                            totalIncome: report.totalIncome,
                          ),
                          const SizedBox(height: 16),

                          // Category Distribution
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Category Distribution',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 16),
                                  IncomePieChart(
                                      categories: report.categories),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Statistics Card
                          IncomeStatisticsCard(
                            statistics: report.statistics,
                          ),
                          const SizedBox(height: 16),

                          // Income Insights
                          const IncomeInsightsWidget(),
                          const SizedBox(height: 16),

                          // Largest Income Info
                          if (report.largestIncomeInfo != null)
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.arrow_upward,
                                          color: Colors.green,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Largest Income',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    _LargestIncomeRow(
                                      label: 'Merchant',
                                      value:
                                          report.largestIncomeInfo!.merchant,
                                    ),
                                    const SizedBox(height: 8),
                                    _LargestIncomeRow(
                                      label: 'Amount',
                                      value: AppFormatter.formatCurrency(
                                          report.largestIncomeInfo!.amount),
                                      valueColor: Colors.green,
                                    ),
                                    const SizedBox(height: 8),
                                    _LargestIncomeRow(
                                      label: 'Date',
                                      value: AppFormatter.formatDate(
                                          report.largestIncomeInfo!.date),
                                    ),
                                    const SizedBox(height: 8),
                                    _LargestIncomeRow(
                                      label: 'Category',
                                      value:
                                          report.largestIncomeInfo!.category,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                    loading: () => _buildLoadingState(context),
                    error: (error, stack) {
                      return ErrorBanner(
                        message: error.toString(),
                        onRetry: () {
                          ref.refresh(incomeReportProvider);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state UI
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_up,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No Income Recorded',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add an income transaction to view analytics.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to add income screen
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Income'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build loading state UI
  Widget _buildLoadingState(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SkeletonCard(),
        const SizedBox(height: 16),
        SkeletonChart(),
        const SizedBox(height: 16),
        SkeletonStatisticsGrid(),
      ],
    );
  }
}

/// Widget for displaying income info rows
class _LargestIncomeRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _LargestIncomeRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
        ),
      ],
    );
  }
}
