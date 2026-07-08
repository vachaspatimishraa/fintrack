import 'dart:math';

import '../../../transactions/domain/entities/transaction_entity.dart';
import '../entities/calendar_analytics_data.dart';
import 'activity_streak_service.dart';
import 'heatmap_calculator.dart';

class CalendarAnalyticsEngine {
  const CalendarAnalyticsEngine._();

  static CalendarAnalyticsReport aggregate({
    required List<TransactionEntity> transactions,
    required DateTime visibleMonth,
    bool includeIncome = true,
    bool includeExpense = true,
  }) {
    final active = transactions
        .where((tx) =>
            !tx.isDeleted &&
            ((includeIncome && tx.type == 'income') ||
                (includeExpense && tx.type == 'expense')))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final monthStart = DateTime(visibleMonth.year, visibleMonth.month, 1);
    final monthEnd = DateTime(visibleMonth.year, visibleMonth.month + 1, 1);
    final yearStart = DateTime(visibleMonth.year, 1, 1);
    final yearEnd = DateTime(visibleMonth.year + 1, 1, 1);

    final rawDays = _buildDays(
      transactions: active,
      start: monthStart,
      end: monthEnd,
    );
    final maxRaw = rawDays
        .map(
          (day) => HeatmapCalculator.rawValue(
            income: day.income,
            expense: day.expense,
            transactionCount: day.transactionCount,
          ),
        )
        .fold<double>(0, max);
    final days = rawDays.map((day) {
      final heatmap = HeatmapCalculator.normalize(
        income: day.income,
        expense: day.expense,
        transactionCount: day.transactionCount,
        maxRawValue: maxRaw,
      );
      return CalendarDayData(
        date: day.date,
        income: day.income,
        expense: day.expense,
        savings: day.savings,
        cashFlow: day.cashFlow,
        transactionCount: day.transactionCount,
        heatmapValue: heatmap,
        activityLevel: HeatmapCalculator.activityLevel(heatmap),
        largestExpense: day.largestExpense,
        largestIncome: day.largestIncome,
        averageTransaction: day.averageTransaction,
        categoryDistribution: day.categoryDistribution,
      );
    }).toList();

    final yearDays = _buildDays(
      transactions: active,
      start: yearStart,
      end: yearEnd,
    );
    final monthSummary = _summary(days, monthStart, monthEnd);
    final yearSummary = _summary(yearDays, yearStart, yearEnd);
    final streak = ActivityStreakService.calculate(days);
    final habits = _habits(active, monthStart, monthEnd);

    return CalendarAnalyticsReport(
      visibleMonth: DateTime(visibleMonth.year, visibleMonth.month, 1),
      days: days,
      monthSummary: monthSummary,
      yearSummary: yearSummary,
      streak: streak,
      habits: habits,
      insights: _insights(monthSummary, streak, habits),
    );
  }

  static CalendarDayData getDaySummary({
    required List<TransactionEntity> transactions,
    required DateTime date,
  }) {
    return _buildDay(
      date,
      transactions.where((tx) => _sameDay(tx.date, date)).toList(),
    );
  }

  static CalendarPeriodSummary getWeekSummary({
    required List<TransactionEntity> transactions,
    required DateTime date,
  }) {
    final day = DateTime(date.year, date.month, date.day);
    final start = day.subtract(Duration(days: day.weekday - 1));
    final end = start.add(const Duration(days: 7));
    return _summary(
      _buildDays(transactions: transactions, start: start, end: end),
      start,
      end,
    );
  }

  static CalendarPeriodSummary getMonthSummary({
    required List<TransactionEntity> transactions,
    required DateTime month,
  }) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    return _summary(
      _buildDays(transactions: transactions, start: start, end: end),
      start,
      end,
    );
  }

  static CalendarPeriodSummary getYearSummary({
    required List<TransactionEntity> transactions,
    required int year,
  }) {
    final start = DateTime(year, 1, 1);
    final end = DateTime(year + 1, 1, 1);
    return _summary(
      _buildDays(transactions: transactions, start: start, end: end),
      start,
      end,
    );
  }

  static List<CalendarTransactionItem> getDailyTransactions({
    required List<TransactionEntity> transactions,
    required DateTime date,
  }) {
    final daily = transactions
        .where((tx) => !tx.isDeleted && _sameDay(tx.date, date))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return daily.map(_toTimelineItem).toList();
  }

  static List<CalendarDayData> _buildDays({
    required List<TransactionEntity> transactions,
    required DateTime start,
    required DateTime end,
  }) {
    final days = <CalendarDayData>[];
    for (var date = start; date.isBefore(end); date = date.add(const Duration(days: 1))) {
      final daily = transactions.where((tx) => _sameDay(tx.date, date)).toList();
      days.add(_buildDay(date, daily));
    }
    return days;
  }

  static CalendarDayData _buildDay(
    DateTime date,
    List<TransactionEntity> transactions,
  ) {
    double income = 0;
    double expense = 0;
    double largestIncome = 0;
    double largestExpense = 0;
    final categories = <String, double>{};

    for (final tx in transactions) {
      if (tx.type == 'income') {
        income += tx.amount;
        largestIncome = max(largestIncome, tx.amount);
      } else if (tx.type == 'expense') {
        expense += tx.amount;
        largestExpense = max(largestExpense, tx.amount);
      }
      categories[tx.category] = (categories[tx.category] ?? 0) + tx.amount;
    }

    final total = income + expense;
    return CalendarDayData(
      date: DateTime(date.year, date.month, date.day),
      income: income,
      expense: expense,
      savings: income - expense,
      cashFlow: income - expense,
      transactionCount: transactions.length,
      heatmapValue: 0,
      activityLevel: CalendarActivityLevel.none,
      largestExpense: largestExpense,
      largestIncome: largestIncome,
      averageTransaction: transactions.isEmpty ? 0 : total / transactions.length,
      categoryDistribution: categories,
    );
  }

  static CalendarPeriodSummary _summary(
    List<CalendarDayData> days,
    DateTime start,
    DateTime end,
  ) {
    final totalIncome = days.fold<double>(0, (sum, day) => sum + day.income);
    final totalExpense = days.fold<double>(0, (sum, day) => sum + day.expense);
    final transactionCount = days.fold<int>(
      0,
      (sum, day) => sum + day.transactionCount,
    );
    final spendingDays = days.where((day) => day.expense > 0).length;
    final incomeDays = days.where((day) => day.income > 0).length;
    final workingDays = days
        .where((day) =>
            day.date.weekday != DateTime.saturday &&
            day.date.weekday != DateTime.sunday)
        .length;
    final noTransactionDays = days.where((day) => !day.hasActivity).length;
    final spending = days.where((day) => day.expense > 0).toList();
    final income = days.where((day) => day.income > 0).toList();

    return CalendarPeriodSummary(
      periodStart: start,
      periodEnd: end,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netCashFlow: totalIncome - totalExpense,
      transactionCount: transactionCount,
      workingDays: workingDays,
      spendingDays: spendingDays,
      incomeDays: incomeDays,
      noTransactionDays: noTransactionDays,
      highestSpendingDay: spending.isEmpty
          ? null
          : spending.reduce((a, b) => a.expense >= b.expense ? a : b),
      highestIncomeDay: income.isEmpty
          ? null
          : income.reduce((a, b) => a.income >= b.income ? a : b),
    );
  }

  static CalendarHabitIndicators _habits(
    List<TransactionEntity> transactions,
    DateTime start,
    DateTime end,
  ) {
    final monthTx = transactions
        .where((tx) => !tx.date.isBefore(start) && tx.date.isBefore(end))
        .toList();
    final firstWeekIncome = monthTx.any(
      (tx) => tx.type == 'income' && tx.date.day <= 7,
    );
    final weekendExpense = monthTx
            .where((tx) =>
                tx.type == 'expense' &&
                (tx.date.weekday == DateTime.saturday ||
                    tx.date.weekday == DateTime.sunday))
            .fold<double>(0, (sum, tx) => sum + tx.amount) >
        monthTx
            .where((tx) =>
                tx.type == 'expense' &&
                tx.date.weekday != DateTime.saturday &&
                tx.date.weekday != DateTime.sunday)
            .fold<double>(0, (sum, tx) => sum + tx.amount);
    final restaurantFrequency = monthTx
            .where((tx) => tx.category.toLowerCase().contains('food'))
            .length >=
        3;
    final shoppingDays = monthTx.any(
      (tx) => tx.category.toLowerCase().contains('shopping'),
    );
    final titles = <String, int>{};
    for (final tx in monthTx) {
      if (tx.title.isNotEmpty) {
        titles[tx.title] = (titles[tx.title] ?? 0) + 1;
      }
    }

    return CalendarHabitIndicators(
      salaryFirstWeek: firstWeekIncome,
      weekendSpending: weekendExpense,
      restaurantFrequency: restaurantFrequency,
      shoppingDays: shoppingDays,
      subscriptionDays: titles.values.any((count) => count >= 3),
    );
  }

  static List<String> _insights(
    CalendarPeriodSummary summary,
    ActivityStreak streak,
    CalendarHabitIndicators habits,
  ) {
    final insights = <String>[];
    if (summary.highestSpendingDay != null) {
      final day = summary.highestSpendingDay!.date.day;
      insights.add('You spent the most on $day ${_monthName(summary.periodStart.month)}.');
    }
    if (streak.longestActivityStreak > 1) {
      insights.add(
        'Your longest financial activity streak is ${streak.longestActivityStreak} days.',
      );
    }
    if (summary.noTransactionDays > 0) {
      insights.add('You had ${summary.noTransactionDays} days with no transactions.');
    }
    if (habits.salaryFirstWeek) {
      insights.add('Income usually arrives during the first week of the month.');
    }
    if (habits.weekendSpending) {
      insights.add('Weekend spending is consistently higher.');
    }
    return insights;
  }

  static CalendarTransactionItem _toTimelineItem(TransactionEntity tx) {
    return CalendarTransactionItem(
      id: tx.uuid,
      date: tx.date,
      title: tx.title,
      type: tx.type,
      category: tx.category,
      amount: tx.amount,
      hasReceipt: tx.receiptUrl != null || tx.receiptLocalPath != null,
    );
  }

  static bool _sameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  static String _monthName(int month) {
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
