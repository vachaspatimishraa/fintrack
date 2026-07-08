import 'package:flutter/material.dart';
import '../../domain/entities/budget_history_record.dart';

class RecentActivityTimeline extends StatelessWidget {
  final List<dynamic> activity;

  const RecentActivityTimeline({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    if (activity.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activity.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = activity[index];
              if (item is BudgetHistoryRecord) {
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.history, size: 16, color: Colors.white),
                  ),
                  title: Text('Cycle for ${item.month} ${item.year} updated'),
                  subtitle: Text(item.status),
                  trailing: Text(
                    '${item.utilizationPercentage.toStringAsFixed(0)}%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
