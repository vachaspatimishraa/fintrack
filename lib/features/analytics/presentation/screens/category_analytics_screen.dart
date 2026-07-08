import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/formatter.dart';
import '../../providers/category_provider.dart';
import '../widgets/banners.dart';
import '../widgets/category_bar_chart.dart';
import '../widgets/category_comparison_card.dart';
import '../widgets/category_insights_widget.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/category_statistics_card.dart';
import '../widgets/category_details_screen.dart';
import '../widgets/skeleton_loaders.dart';

class CategoryAnalyticsScreen extends ConsumerWidget {
  const CategoryAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(categoryAnalyticsReportProvider);
    final selectedFilter = ref.watch(categoryTimeFilterProvider);
    final controller = ref.watch(categoryControllerProvider);
    final periodLabel = ref.watch(categoryPeriodLabelProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Analytics'),
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
                  // Time Filter
                  SegmentedButton<String>(
                    selected: {selectedFilter},
                    onSelectionChanged: (Set<String> newSelection) {
                      ref.read(categoryTimeFilterProvider.notifier).state =
                          newSelection.first;
                    },
                    segments: const <ButtonSegment<String>>[
                      ButtonSegment<String>(value: 'today', label: Text('Today')),
                      ButtonSegment<String>(value: 'week', label: Text('Week')),
                      ButtonSegment<String>(value: 'month', label: Text('Month')),
                      ButtonSegment<String>(value: 'quarter', label: Text('Quarter')),
                      ButtonSegment<String>(value: 'year', label: Text('Year')),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Main content
                  reportAsync.when(
                    data: (report) {
                      if (controller.isEmpty(report)) {
                        return _buildEmptyState(context);
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Total summary card
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    periodLabel,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Total Across Categories',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              AppFormatter.formatCurrency(
                                                  report.totalAmount),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: colorScheme
                                                  .primaryContainer,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${report.categoryCount} categories',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelSmall,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Pie chart
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Expense Distribution',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 16),
                                  CategoryPieChart(
                                    rankings: report.rankings,
                                    onCategoryTap: (categoryName) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              CategoryDetailsScreen(
                                                categoryName: categoryName,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Top categories bar chart
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Top Categories',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 16),
                                  CategoryBarChart(
                                    rankings:
                                        controller.getTopCategories(report),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Statistics card
                          CategoryStatisticsCard(
                            report: report,
                          ),
                          const SizedBox(height: 16),

                          // Category comparison
                          if (report.comparisons.isNotEmpty)
                            CategoryComparisonCard(
                              comparisons: report.comparisons,
                            ),
                          const SizedBox(height: 16),

                          // Insights
                          const CategoryInsightsWidget(),
                        ],
                      );
                    },
                    loading: () => _buildLoadingState(context),
                    error: (error, stack) {
                      return ErrorBanner(
                        message: error.toString(),
                        onRetry: () {
                          ref.refresh(categoryAnalyticsReportProvider);
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No Category Data',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add transactions to see category insights.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

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
