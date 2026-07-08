import 'package:flutter/material.dart';

import '../../domain/entities/calendar_analytics_data.dart';

class CalendarHeatmap extends StatelessWidget {
  const CalendarHeatmap({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levels = CalendarActivityLevel.values;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Activity Heatmap', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: levels.map((level) {
                return Expanded(
                  child: Container(
                    height: 14,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: _color(colorScheme, level),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('None', style: Theme.of(context).textTheme.labelSmall),
                Text('Very High', style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _color(ColorScheme colorScheme, CalendarActivityLevel level) {
    switch (level) {
      case CalendarActivityLevel.none:
        return colorScheme.surfaceContainerHighest;
      case CalendarActivityLevel.veryLow:
        return colorScheme.primaryContainer;
      case CalendarActivityLevel.low:
        return colorScheme.primary.withOpacity(0.30);
      case CalendarActivityLevel.medium:
        return colorScheme.secondary.withOpacity(0.45);
      case CalendarActivityLevel.high:
        return colorScheme.tertiary.withOpacity(0.55);
      case CalendarActivityLevel.veryHigh:
        return colorScheme.errorContainer;
    }
  }
}
