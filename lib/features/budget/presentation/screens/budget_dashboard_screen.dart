import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/budget_provider.dart';
import '../widgets/overall_budget_card.dart';
import '../widgets/budget_statistics_card.dart';
import '../widgets/budget_efficiency_card.dart';
import '../widgets/category_budget_progress_ring.dart';
import '../widgets/category_budget_grid.dart';
import '../widgets/budget_alert_section.dart';
import '../widgets/budget_recommendation_section.dart';
import '../widgets/recent_activity_timeline.dart';
import '../widgets/quick_action_panel.dart';
import '../../../../shared/widgets/offline_banner.dart';

class BudgetDashboardScreen extends ConsumerWidget {
  const BudgetDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(budgetDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(budgetDashboardProvider),
          ),
        ],
      ),
      body: dashboardAsync.when(
        data: (data) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(budgetDashboardProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const OfflineBanner(message: 'Using locally stored financial data.'),
              const SizedBox(height: 16),
              OverallBudgetCard(budget: data.overallBudget),
              if (data.overallBudget != null) ...[
                const SizedBox(height: 24),
                Center(
                  child: CategoryBudgetProgressRing(
                    progress: data.overallBudget!.progress,
                    size: 200,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              BudgetStatisticsCard(statistics: data.statistics),
              const SizedBox(height: 16),
              BudgetEfficiencyCard(
                score: data.statistics.overallProgress, // Simple score for dashboard
                status: 'Good', 
              ),
              const SizedBox(height: 16),
              BudgetAlertSection(alerts: data.alerts),
              const SizedBox(height: 16),
              CategoryBudgetGrid(budgets: data.categoryBudgets),
              const SizedBox(height: 16),
              BudgetRecommendationSection(recommendations: data.recommendations),
              const SizedBox(height: 16),
              RecentActivityTimeline(activity: data.recentActivity),
              const SizedBox(height: 16),
              const QuickActionPanel(),
              const SizedBox(height: 100),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
