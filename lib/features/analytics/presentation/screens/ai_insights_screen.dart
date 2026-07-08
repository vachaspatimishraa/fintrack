import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/ai_insight_provider.dart';
import '../widgets/insight_card.dart';
import '../widgets/forecast_card.dart';
import '../widgets/smart_recommendation_card.dart';
import '../widgets/insight_offline_banner.dart';
import 'insight_history_screen.dart';

class AIInsightsScreen extends ConsumerStatefulWidget {
  const AIInsightsScreen({super.key});

  @override
  ConsumerState<AIInsightsScreen> createState() => _AIInsightsScreenState();
}

class _AIInsightsScreenState extends ConsumerState<AIInsightsScreen> {
  bool _offlineMode = false;

  @override
  Widget build(BuildContext context) {
    final reportAsync = ref.watch(aiInsightsProvider);
    final controller = ref.watch(aiInsightControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InsightHistoryScreen()),
              );
            },
            tooltip: 'View History',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refresh(),
            tooltip: 'Regenerate Insights',
          ),
        ],
      ),
      body: Column(
        children: [
          InsightOfflineBanner(isOffline: _offlineMode),
          Expanded(
            child: reportAsync.when(
              data: (report) {
                if (report.isEmpty) {
                  return _buildEmptyState(context);
                }

                // Sort insights: pinned first, then warnings/critical, then positive
                final sortedInsights = List.from(report.currentInsights)
                  ..sort((a, b) {
                    if (a.pinned && !b.pinned) return -1;
                    if (!a.pinned && b.pinned) return 1;
                    if (a.severity == 'Critical' && b.severity != 'Critical') return -1;
                    if (a.severity != 'Critical' && b.severity == 'Critical') return 1;
                    if (a.severity == 'Warning' && b.severity != 'Warning') return -1;
                    if (a.severity != 'Warning' && b.severity == 'Warning') return 1;
                    return 0;
                  });

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final bool isWide = constraints.maxWidth > 720;
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (isWide)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        'Key AI Insights',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 12),
                                      if (sortedInsights.isEmpty)
                                        Card(
                                          child: Padding(
                                            padding: const EdgeInsets.all(24.0),
                                            child: Text(
                                              'No active insights at the moment. Excellent financial standing!',
                                              style: theme.textTheme.bodyMedium,
                                            ),
                                          ),
                                        )
                                      else
                                        ListView.separated(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: sortedInsights.length,
                                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                                          itemBuilder: (context, index) {
                                            return InsightCard(insight: sortedInsights[index]);
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      ForecastCard(forecast: report.forecast),
                                      const SizedBox(height: 16),
                                      SmartRecommendationCard(patterns: report.detectedPatterns),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ForecastCard(forecast: report.forecast),
                                const SizedBox(height: 16),
                                SmartRecommendationCard(patterns: report.detectedPatterns),
                                const SizedBox(height: 24),
                                Text(
                                  'Key AI Insights',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                if (sortedInsights.isEmpty)
                                  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Text(
                                        'No active insights at the moment. Excellent financial standing!',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ),
                                  )
                                else
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: sortedInsights.length,
                                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      return InsightCard(insight: sortedInsights[index]);
                                    },
                                  ),
                              ],
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) {
                return _buildErrorState(context, err.toString());
              },
            ),
          ),
        ],
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
              Icons.auto_awesome_outlined,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.4),
            ),
            const SizedBox(height: 24),
            Text(
              'No Insights Available',
              style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Continue using FinTrack to receive personalized insights.',
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
              'Unable to generate AI insights.',
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
                    ref.invalidate(aiInsightsProvider);
                  },
                  child: const Text('Retry'),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _offlineMode = true;
                    });
                    ref.invalidate(aiInsightsProvider);
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
}
