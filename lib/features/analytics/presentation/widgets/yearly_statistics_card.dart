import 'package:flutter/material.dart';
import '../../../../core/utils/formatter.dart';
import '../../domain/entities/yearly_report_data.dart';

class YearlyStatisticsCard extends StatelessWidget {
  final YearlyStatistics statistics;

  const YearlyStatisticsCard({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
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
              'Annual Statistics & Peaks',
              style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.1,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _StatTile(
                  label: 'Annual Transactions',
                  value: '${statistics.totalTransactions} Txns',
                  subValue: '${statistics.incomeTransactions} Inc / ${statistics.expenseTransactions} Exp',
                  icon: Icons.receipt_long_outlined,
                ),
                _StatTile(
                  label: 'Average Monthly Spend',
                  value: AppFormatter.formatCurrency(statistics.averageMonthlyExpense),
                  subValue: 'Earned ${AppFormatter.formatCurrency(statistics.averageMonthlyIncome)}/mo',
                  icon: Icons.calendar_today_outlined,
                ),
                _StatTile(
                  label: 'Peak Saving Month',
                  value: statistics.highestSavingMonth,
                  subValue: 'Highest surplus month',
                  icon: Icons.star_border_outlined,
                  iconColor: Colors.blue,
                ),
                _StatTile(
                  label: 'Peak Spending Month',
                  value: statistics.highestSpendingMonth,
                  subValue: 'Highest expense month',
                  icon: Icons.show_chart_outlined,
                  iconColor: const Color(0xFFF43F5E),
                ),
                _StatTile(
                  label: 'Net Worth growth',
                  value: AppFormatter.formatCurrency(statistics.netWorthGrowth),
                  subValue: 'Annual savings generated',
                  icon: Icons.trending_up_outlined,
                  iconColor: statistics.netWorthGrowth >= 0 ? const Color(0xFF10B981) : Colors.red,
                ),
                _StatTile(
                  label: 'Avg Transaction size',
                  value: AppFormatter.formatCurrency(statistics.averageTransaction),
                  subValue: 'Per transaction size',
                  icon: Icons.analytics_outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String subValue;
  final IconData icon;
  final Color? iconColor;

  const _StatTile({
    required this.label,
    required this.value,
    required this.subValue,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iColor = iconColor ?? theme.colorScheme.primary;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subValue,
                style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                      fontSize: 10,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
