import 'package:flutter/material.dart';
import '../screens/add_edit_budget_screen.dart';
import '../screens/budget_analytics_screen.dart';
import '../screens/budget_history_screen.dart';
import '../screens/budget_recommendation_screen.dart';

class QuickActionPanel extends StatelessWidget {
  const QuickActionPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          children: [
            _ActionChip(
              label: 'Create',
              icon: Icons.add,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddEditBudgetScreen()),
              ),
            ),
            _ActionChip(
              label: 'Analytics',
              icon: Icons.analytics_outlined,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BudgetAnalyticsScreen()),
              ),
            ),
            _ActionChip(
              label: 'History',
              icon: Icons.history,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BudgetHistoryScreen()),
              ),
            ),
            _ActionChip(
              label: 'Coach',
              icon: Icons.auto_awesome,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BudgetRecommendationScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionChip({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Column(
              children: [
                Icon(icon, size: 24, color: Theme.of(context).primaryColor),
                const SizedBox(height: 4),
                Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
