import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/ai_insight_data.dart';
import '../../providers/ai_insight_provider.dart';
import '../screens/insight_details_screen.dart';

class InsightCard extends ConsumerWidget {
  final AIInsight insight;

  const InsightCard({
    super.key,
    required this.insight,
  });

  Color _getSeverityColor(String severity, ThemeData theme) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'positive':
        return const Color(0xFF10B981);
      case 'forecast':
      case 'recommendation':
      default:
        return theme.colorScheme.primary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'savings':
        return Icons.savings_outlined;
      case 'budget':
        return Icons.pie_chart_outline;
      case 'income':
        return Icons.trending_up;
      case 'expenses':
        return Icons.trending_down;
      case 'cash flow':
      default:
        return Icons.compare_arrows;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final controller = ref.watch(aiInsightControllerProvider);
    final color = _getSeverityColor(insight.severity, theme);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: insight.pinned ? theme.colorScheme.primary : theme.colorScheme.outlineVariant.withOpacity(0.3),
          width: insight.pinned ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InsightDetailsScreen(insight: insight),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getCategoryIcon(insight.category),
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          insight.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          insight.category.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      insight.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                      size: 20,
                      color: insight.pinned ? theme.colorScheme.primary : null,
                    ),
                    onPressed: () => controller.pinInsight(insight.id),
                    tooltip: insight.pinned ? 'Unpin' : 'Pin Insight',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                insight.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Confidence: ${(insight.confidence * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                        ),
                  ),
                  TextButton.icon(
                    onPressed: () => controller.dismissInsight(insight.id),
                    icon: const Icon(Icons.close, size: 14),
                    label: const Text('Dismiss'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
