import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/trend_provider.dart';
import '../widgets/banners.dart';
import '../widgets/forecast_card.dart';
import '../widgets/moving_average_card.dart';
import '../widgets/peak_spending_card.dart';
import '../widgets/recommendation_card.dart';
import '../widgets/skeleton_trend_chart.dart';
import '../widgets/trend_chart.dart';
import '../widgets/trend_summary_card.dart';

class SpendingTrendScreen extends ConsumerWidget {
  const SpendingTrendScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(spendingTrendReportProvider);
    final selectedFilter = ref.watch(trendTimeFilterProvider);
    final controller = ref.watch(trendControllerProvider);
    final periodLabel = ref.watch(trendPeriodLabelProvider);
    final recommendations = ref.watch(trendRecommendationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending Trends'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OfflineBanner(isOffline: controller.isOfflineMode()),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SegmentedButton<String>(
                    selected: {selectedFilter},
                    onSelectionChanged: (selection) {
                      ref.read(trendTimeFilterProvider.notifier).state =
                          selection.first;
                    },
                    segments: const <ButtonSegment<String>>[
                      ButtonSegment<String>(
                        value: 'today',
                        label: Text('Today'),
                      ),
                      ButtonSegment<String>(
                        value: 'week',
                        label: Text('Week'),
                      ),
                      ButtonSegment<String>(
                        value: 'month',
                        label: Text('Month'),
                      ),
                      ButtonSegment<String>(
                        value: 'quarter',
                        label: Text('Quarter'),
                      ),
                      ButtonSegment<String>(
                        value: 'year',
                        label: Text('Year'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  reportAsync.when(
                    data: (report) {
                      if (controller.isEmpty(report)) {
                        return _EmptyTrendState();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TrendSummaryCard(
                            report: report,
                            periodLabel: periodLabel,
                            directionLabel: controller.directionLabel(
                              report.summary.direction,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Spending Trend Chart',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 16),
                                  TrendChart(points: report.points),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          MovingAverageCard(report: report),
                          const SizedBox(height: 16),
                          PeakSpendingCard(
                            peaks: report.peakPeriods,
                            lows: report.lowPeriods,
                          ),
                          const SizedBox(height: 16),
                          ForecastCard(forecast: report.forecast),
                          const SizedBox(height: 16),
                          RecommendationCard(
                            recommendations: recommendations,
                          ),
                        ],
                      );
                    },
                    loading: () => const SkeletonTrendChart(),
                    error: (error, stack) => ErrorBanner(
                      message: 'Unable to calculate spending trends.',
                      onRetry: () => ref.refresh(spendingTrendReportProvider),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyTrendState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: Column(
          children: [
            Icon(
              Icons.timeline,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No Spending Trends Available',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Add more transactions to discover spending patterns.',
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
}
