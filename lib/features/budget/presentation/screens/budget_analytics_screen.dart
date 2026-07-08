import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/budget_analytics_provider.dart';
import '../widgets/budget_efficiency_card.dart';
import '../widgets/savings_analysis_card.dart';
import '../widgets/overspending_analysis_card.dart';
import '../widgets/budget_insight_card.dart';
import '../widgets/budget_charts.dart';
import 'budget_history_screen.dart';

class BudgetAnalyticsScreen extends ConsumerWidget {
  const BudgetAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(budgetAnalyticsProvider);
    final insightsAsync = ref.watch(budgetInsightsProvider);
    final trendsAsync = ref.watch(monthlyTrendsProvider);
    final categorySpendingAsync = ref.watch(categorySpendingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BudgetHistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: analyticsAsync.when(
        data: (analytics) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(budgetAnalyticsProvider);
            ref.invalidate(budgetInsightsProvider);
            ref.invalidate(monthlyTrendsProvider);
            ref.invalidate(categorySpendingProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildOverviewCard(context, analytics),
              const SizedBox(height: 16),
              BudgetEfficiencyCard(score: analytics.budgetEfficiencyScore, status: analytics.healthStatus),
              const SizedBox(height: 16),
              SavingsAnalysisCard(savings: analytics.monthlySavings, successRate: analytics.successRate),
              const SizedBox(height: 16),
              OverspendingAnalysisCard(overspentAmount: analytics.overspentAmount, utilization: analytics.utilizationPercentage),
              const SizedBox(height: 16),
              _buildForecastCard(context, analytics),
              const SizedBox(height: 24),
              Text('Insights', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              insightsAsync.when(
                data: (insights) => Column(
                  children: insights.map((i) => BudgetInsightCard(insight: i)).toList(),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Error: $err'),
              ),
              const SizedBox(height: 24),
              Text('Monthly Spending Trend', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              trendsAsync.when(
                data: (trends) => Card(child: BudgetTrendChart(data: trends)),
                loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                error: (err, _) => Text('Error: $err'),
              ),
              const SizedBox(height: 24),
              Text('Category Allocation', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              categorySpendingAsync.when(
                data: (spending) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: BudgetPieChart(data: spending),
                  ),
                ),
                loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                error: (err, _) => Text('Error: $err'),
              ),
              const SizedBox(height: 100), // Extra space
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildForecastCard(BuildContext context, dynamic analytics) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final isOverBudget = analytics.forecastedSpending > analytics.currentMonthBudget;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_graph, size: 20, color: Colors.purple),
                const SizedBox(width: 8),
                Text('Spending Forecast', style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Based on current spending, you are projected to reach',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              currencyFormat.format(analytics.forecastedSpending),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isOverBudget ? Colors.red : Colors.green,
              ),
            ),
            Text(
              'by the end of the month.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context, dynamic analytics) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem('Utilization', '${analytics.utilizationPercentage.toStringAsFixed(1)}%', Colors.blue),
                _buildSummaryItem('Success Rate', '${analytics.successRate.toStringAsFixed(1)}%', Colors.green),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem('Daily Avg', currencyFormat.format(analytics.averageDailySpending), Colors.orange),
                _buildSummaryItem('Daily Limit', currencyFormat.format(analytics.remainingDailyLimit), Colors.teal),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
