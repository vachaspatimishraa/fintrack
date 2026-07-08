import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/financial_health_provider.dart';
import '../widgets/health_score_card.dart';
import '../widgets/health_breakdown_card.dart';
import '../widgets/health_trend_chart.dart';
import '../widgets/strength_card.dart';
import '../widgets/weakness_card.dart';
import '../widgets/recommendation_card.dart';
import '../widgets/health_offline_banner.dart';

class FinancialHealthScreen extends ConsumerStatefulWidget {
  const FinancialHealthScreen({super.key});

  @override
  ConsumerState<FinancialHealthScreen> createState() => _FinancialHealthScreenState();
}

class _FinancialHealthScreenState extends ConsumerState<FinancialHealthScreen> {
  bool _offlineMode = false;

  @override
  Widget build(BuildContext context) {
    final healthAsync = ref.watch(financialHealthProvider);
    final controller = ref.watch(financialHealthControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Health Score'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refresh(),
            tooltip: 'Recalculate Health',
          ),
        ],
      ),
      body: Column(
        children: [
          HealthOfflineBanner(isOffline: _offlineMode),
          Expanded(
            child: healthAsync.when(
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
                          if (isWide)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      HealthScoreCard(
                                        score: report.overallScore,
                                        rating: report.rating,
                                        ratingDescription: report.ratingDescription,
                                        improvementAdvice: report.improvementAdvice,
                                      ),
                                      const SizedBox(height: 16),
                                      HealthTrendChart(historicalScores: report.historicalScores),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 5,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      HealthBreakdownCard(breakdown: report.breakdown),
                                      const SizedBox(height: 16),
                                      StrengthCard(strengths: report.strengths),
                                      const SizedBox(height: 16),
                                      WeaknessCard(weaknesses: report.weaknesses),
                                      const SizedBox(height: 16),
                                      RecommendationCard(recommendations: report.recommendations),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                HealthScoreCard(
                                  score: report.overallScore,
                                  rating: report.rating,
                                  ratingDescription: report.ratingDescription,
                                  improvementAdvice: report.improvementAdvice,
                                ),
                                const SizedBox(height: 16),
                                HealthBreakdownCard(breakdown: report.breakdown),
                                const SizedBox(height: 16),
                                HealthTrendChart(historicalScores: report.historicalScores),
                                const SizedBox(height: 16),
                                StrengthCard(strengths: report.strengths),
                                const SizedBox(height: 16),
                                WeaknessCard(weaknesses: report.weaknesses),
                                const SizedBox(height: 16),
                                RecommendationCard(recommendations: report.recommendations),
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
              Icons.healing_outlined,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.4),
            ),
            const SizedBox(height: 24),
            Text(
              'Financial Health Unavailable',
              style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add transactions and budgets to generate your financial health score.',
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
              'Unable to calculate financial health.',
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
                    ref.invalidate(financialHealthProvider);
                  },
                  child: const Text('Retry'),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _offlineMode = true;
                    });
                    ref.invalidate(financialHealthProvider);
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
