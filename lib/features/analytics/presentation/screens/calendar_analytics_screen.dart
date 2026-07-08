import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/calendar_provider.dart';
import '../widgets/banners.dart';
import '../widgets/calendar_heatmap.dart';
import '../widgets/calendar_filter_sheet.dart';
import '../widgets/daily_timeline.dart';
import '../widgets/day_summary_card.dart';
import '../widgets/financial_calendar.dart';
import '../widgets/month_statistics_card.dart';
import '../widgets/skeleton_calendar.dart';

class CalendarAnalyticsScreen extends ConsumerWidget {
  const CalendarAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(calendarAnalyticsReportProvider);
    final visibleMonth = ref.watch(calendarVisibleMonthProvider);
    final selectedDate = ref.watch(calendarSelectedDateProvider);
    final selectedDay = ref.watch(selectedCalendarDayProvider);
    final timeline = ref.watch(selectedDayTransactionsProvider);
    final controller = ref.watch(calendarControllerProvider);
    final includeIncome = ref.watch(calendarIncludeIncomeProvider);
    final includeExpense = ref.watch(calendarIncludeExpenseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Analytics'),
        actions: [
          IconButton(
            tooltip: 'Filters',
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                showDragHandle: true,
                builder: (context) {
                  return CalendarFilterSheet(
                    includeIncome: includeIncome,
                    includeExpense: includeExpense,
                    onApply: (filters) {
                      ref.read(calendarIncludeIncomeProvider.notifier).state =
                          filters.includeIncome;
                      ref.read(calendarIncludeExpenseProvider.notifier).state =
                          filters.includeExpense;
                    },
                  );
                },
              );
            },
            icon: const Icon(Icons.tune),
          ),
          IconButton(
            tooltip: 'Today',
            onPressed: () {
              final now = DateTime.now();
              ref.read(calendarVisibleMonthProvider.notifier).state =
                  DateTime(now.year, now.month, 1);
              ref.read(calendarSelectedDateProvider.notifier).state =
                  DateTime(now.year, now.month, now.day);
            },
            icon: const Icon(Icons.today),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OfflineBanner(isOffline: controller.isOfflineMode()),
            Padding(
              padding: const EdgeInsets.all(16),
              child: reportAsync.when(
                data: (report) {
                  if (report.isEmpty) {
                    return _EmptyCalendarState();
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 720;
                      final calendarColumn = Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _MonthHeader(visibleMonth: visibleMonth),
                          const SizedBox(height: 12),
                          FinancialCalendar(
                            days: report.days,
                            selectedDate: selectedDate,
                            onDaySelected: (date) {
                              ref.read(calendarSelectedDateProvider.notifier).state =
                                  date;
                            },
                          ),
                          const SizedBox(height: 16),
                          const CalendarHeatmap(),
                          const SizedBox(height: 16),
                          MonthStatisticsCard(
                            summary: report.monthSummary,
                            streak: report.streak,
                          ),
                        ],
                      );
                      final detailColumn = Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DaySummaryCard(day: selectedDay),
                          const SizedBox(height: 16),
                          DailyTimeline(transactions: timeline),
                          const SizedBox(height: 16),
                          _InsightsCard(insights: report.insights),
                        ],
                      );

                      if (!wide) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            calendarColumn,
                            const SizedBox(height: 16),
                            detailColumn,
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: calendarColumn),
                          const SizedBox(width: 16),
                          Expanded(flex: 2, child: detailColumn),
                        ],
                      );
                    },
                  );
                },
                loading: () => const SkeletonCalendar(),
                error: (error, stack) => ErrorBanner(
                  message: 'Unable to load calendar analytics.',
                  onRetry: () => ref.refresh(calendarAnalyticsReportProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthHeader extends ConsumerWidget {
  final DateTime visibleMonth;

  const _MonthHeader({required this.visibleMonth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(calendarControllerProvider);
    final label = '${_monthName(visibleMonth.month)} ${visibleMonth.year}';
    return Row(
      children: [
        IconButton(
          tooltip: 'Previous month',
          onPressed: () {
            ref.read(calendarVisibleMonthProvider.notifier).state =
                controller.previousMonth(visibleMonth);
          },
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Center(
            child: Text(label, style: Theme.of(context).textTheme.titleLarge),
          ),
        ),
        IconButton(
          tooltip: 'Next month',
          onPressed: () {
            ref.read(calendarVisibleMonthProvider.notifier).state =
                controller.nextMonth(visibleMonth);
          },
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  String _monthName(int month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[month - 1];
  }
}

class _InsightsCard extends StatelessWidget {
  final List<String> insights;

  const _InsightsCard({required this.insights});

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daily Insights', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...insights.map(
              (insight) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(insight)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCalendarState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: Column(
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No Calendar Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start adding transactions to build your financial calendar.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/add-transaction'),
              icon: const Icon(Icons.add),
              label: const Text('Add Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}
