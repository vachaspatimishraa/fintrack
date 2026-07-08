import 'package:flutter/material.dart';

import '../../domain/entities/calendar_analytics_data.dart';

class FinancialCalendar extends StatelessWidget {
  final List<CalendarDayData> days;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDaySelected;

  const FinancialCalendar({
    super.key,
    required this.days,
    required this.selectedDate,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) return const SizedBox.shrink();

    final first = days.first.date;
    final leadingBlanks = first.weekday % 7;
    final cells = <CalendarDayData?>[
      ...List<CalendarDayData?>.filled(leadingBlanks, null),
      ...days,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const _WeekdayHeader(),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
              ),
              itemCount: cells.length,
              itemBuilder: (context, index) {
                final day = cells[index];
                if (day == null) return const SizedBox.shrink();
                return _CalendarCell(
                  day: day,
                  selected: _sameDay(day.date, selectedDate),
                  onTap: () => onDaySelected(day.date),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  static bool _sameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) {
    const labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      children: labels
          .map(
            (label) => Expanded(
              child: Center(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _CalendarCell extends StatelessWidget {
  final CalendarDayData day;
  final bool selected;
  final VoidCallback onTap;

  const _CalendarCell({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activityColor = _activityColor(colorScheme, day.activityLevel);
    return Semantics(
      button: true,
      label:
          '${day.date.day}, ${day.transactionCount} transactions, activity ${day.heatmapValue.toStringAsFixed(0)}',
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: activityColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? colorScheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${day.date.day}',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              if (day.transactionCount > 0)
                Text(
                  '${day.transactionCount}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _activityColor(ColorScheme colorScheme, CalendarActivityLevel level) {
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
