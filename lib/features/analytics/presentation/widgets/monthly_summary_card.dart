import 'package:flutter/material.dart';
import '../../../../core/utils/formatter.dart';
import '../../domain/entities/monthly_report_data.dart';

class MonthlySummaryCard extends StatelessWidget {
  final MonthlySummary summary;

  const MonthlySummaryCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = (constraints.maxWidth - 12) / 2;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Financial Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _SummaryTile(
                  label: 'Income',
                  amount: summary.income,
                  icon: Icons.trending_up,
                  color: const Color(0xFF10B981),
                  width: cardWidth,
                ),
                _SummaryTile(
                  label: 'Expense',
                  amount: summary.expense,
                  icon: Icons.trending_down,
                  color: const Color(0xFFF43F5E),
                  width: cardWidth,
                ),
                _SummaryTile(
                  label: 'Savings',
                  amount: summary.savings,
                  icon: Icons.account_balance_wallet_outlined,
                  color: Colors.blue,
                  width: cardWidth,
                ),
                _SummaryTile(
                  label: 'Cash Flow',
                  amount: summary.cashFlow,
                  icon: Icons.swap_horiz,
                  color: summary.cashFlow >= 0 ? Colors.teal : Colors.orange,
                  width: cardWidth,
                  showPrefix: true,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _SummaryTile extends StatefulWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  final double width;
  final bool showPrefix;

  const _SummaryTile({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    required this.width,
    this.showPrefix = false,
  });

  @override
  State<_SummaryTile> createState() => _SummaryTileState();
}

class _SummaryTileState extends State<_SummaryTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prefix = widget.showPrefix && widget.amount > 0 ? '+' : '';

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: widget.width,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.label,
                  style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.icon,
                    color: widget.color,
                    size: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '$prefix${AppFormatter.formatCurrency(widget.amount)}',
              style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
