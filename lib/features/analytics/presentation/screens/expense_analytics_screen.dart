import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/formatter.dart';
import '../../domain/utils/expense_growth_calculator.dart';
import '../../providers/expense_provider.dart';
import '../widgets/banners.dart';
import '../widgets/expense_health_card.dart';
import '../widgets/expense_insights_widget.dart';
import '../widgets/expense_pie_chart.dart';
import '../widgets/expense_statistics_card.dart';
import '../widgets/expense_trend_chart.dart';
import '../widgets/expense_top_merchants.dart';
import '../widgets/skeleton_loaders.dart';

class ExpenseAnalyticsScreen extends ConsumerWidget {
  const ExpenseAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(expenseReportProvider);
    final selectedFilter = ref.watch(expenseTimeFilterProvider);
    final controller = ref.watch(expenseControllerProvider);
    final periodLabel = ref.watch(expensePeriodLabelProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Analytics'),
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
                      ref.read(expenseTimeFilterProvider.notifier).state =
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
                        value: 'year',
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
                          // Total Expense KPI Card
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Expense',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          AppFormatter.formatCurrency(
                                              report.totalExpense),
                                          style: Theme.of(context)
                                              .textTheme
                                              .displaySmall
                                              ?.copyWith(
                                                color: Colors.red,
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
                                                  .growthPercentage <
                                              0
                                              ? Colors.green.withOpacity(0.1)
                                              : Colors.red.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          ExpenseGrowthCalculator
                                              .formatGrowth(report.comparison
                                                  .growthPercentage),
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium
                                              ?.copyWith(
                                                color: report.comparison
                                                        .growthPercentage <
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

                          // Expense Trend Chart
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Expense Trend',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 16),
                                  ExpenseTrendChart(points: report.points),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Top Merchants
                          ExpenseTopMerchants(
                            merchants: report.merchants,
                            totalExpense: report.totalExpense,
                          ),
                          const SizedBox(height: 16),

                          // Top Categories (Pie Chart)
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
                                  ExpensePieChart(
                                      categories: report.categories),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Statistics Card
                          ExpenseStatisticsCard(
                            statistics: report.statistics,
                          ),
                          const SizedBox(height: 16),

                          // Health Score Card
                          ExpenseHealthCard(
                            healthScore: report.healthScore,
                          ),
                          const SizedBox(height: 16),

                          // Expense Insights
                          const ExpenseInsightsWidget(),
                          const SizedBox(height: 16),

                          // Highest Expense Info
                          if (report.highestExpenseInfo != null)
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
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Highest Expense',
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
                                    _ExpenseInfoRow(
                                      label: 'Merchant',
                                      value: report
                                          .highestExpenseInfo!.merchant,
                                    ),
                                    const SizedBox(height: 8),
                                    _ExpenseInfoRow(
                                      label: 'Amount',
                                      value: AppFormatter.formatCurrency(
                                          report.highestExpenseInfo!.amount),
                                      valueColor: Colors.red,
                                    ),
                                    const SizedBox(height: 8),
                                    _ExpenseInfoRow(
                                      label: 'Date',
                                      value: AppFormatter.formatDate(
                                          report.highestExpenseInfo!.date),
                                    ),
                                    const SizedBox(height: 8),
                                    _ExpenseInfoRow(
                                      label: 'Category',
                                      value:
                                          report.highestExpenseInfo!.category,
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
                          ref.refresh(expenseReportProvider);
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
              Icons.trending_down,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No Expenses Recorded',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add an expense transaction to view analytics.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to add expense screen
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
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

/// Widget for displaying expense info rows
class _ExpenseInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _ExpenseInfoRow({
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
