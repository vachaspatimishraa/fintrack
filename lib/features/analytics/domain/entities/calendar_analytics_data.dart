enum CalendarActivityLevel {
  none,
  veryLow,
  low,
  medium,
  high,
  veryHigh,
}

class CalendarDayData {
  final DateTime date;
  final double income;
  final double expense;
  final double savings;
  final double cashFlow;
  final int transactionCount;
  final double heatmapValue;
  final CalendarActivityLevel activityLevel;
  final double largestExpense;
  final double largestIncome;
  final double averageTransaction;
  final Map<String, double> categoryDistribution;

  const CalendarDayData({
    required this.date,
    required this.income,
    required this.expense,
    required this.savings,
    required this.cashFlow,
    required this.transactionCount,
    required this.heatmapValue,
    required this.activityLevel,
    required this.largestExpense,
    required this.largestIncome,
    required this.averageTransaction,
    required this.categoryDistribution,
  });

  bool get hasActivity => transactionCount > 0;
}

class CalendarTransactionItem {
  final String id;
  final DateTime date;
  final String title;
  final String type;
  final String category;
  final double amount;
  final bool hasReceipt;

  const CalendarTransactionItem({
    required this.id,
    required this.date,
    required this.title,
    required this.type,
    required this.category,
    required this.amount,
    required this.hasReceipt,
  });
}

class CalendarPeriodSummary {
  final DateTime periodStart;
  final DateTime periodEnd;
  final double totalIncome;
  final double totalExpense;
  final double netCashFlow;
  final int transactionCount;
  final int workingDays;
  final int spendingDays;
  final int incomeDays;
  final int noTransactionDays;
  final CalendarDayData? highestSpendingDay;
  final CalendarDayData? highestIncomeDay;

  const CalendarPeriodSummary({
    required this.periodStart,
    required this.periodEnd,
    required this.totalIncome,
    required this.totalExpense,
    required this.netCashFlow,
    required this.transactionCount,
    required this.workingDays,
    required this.spendingDays,
    required this.incomeDays,
    required this.noTransactionDays,
    required this.highestSpendingDay,
    required this.highestIncomeDay,
  });
}

class ActivityStreak {
  final int currentActivityStreak;
  final int currentSavingsStreak;
  final int longestActivityStreak;
  final int longestSavingsStreak;

  const ActivityStreak({
    required this.currentActivityStreak,
    required this.currentSavingsStreak,
    required this.longestActivityStreak,
    required this.longestSavingsStreak,
  });

  factory ActivityStreak.empty() => const ActivityStreak(
        currentActivityStreak: 0,
        currentSavingsStreak: 0,
        longestActivityStreak: 0,
        longestSavingsStreak: 0,
      );
}

class CalendarHabitIndicators {
  final bool salaryFirstWeek;
  final bool weekendSpending;
  final bool restaurantFrequency;
  final bool shoppingDays;
  final bool subscriptionDays;

  const CalendarHabitIndicators({
    required this.salaryFirstWeek,
    required this.weekendSpending,
    required this.restaurantFrequency,
    required this.shoppingDays,
    required this.subscriptionDays,
  });

  factory CalendarHabitIndicators.empty() => const CalendarHabitIndicators(
        salaryFirstWeek: false,
        weekendSpending: false,
        restaurantFrequency: false,
        shoppingDays: false,
        subscriptionDays: false,
      );
}

class CalendarAnalyticsReport {
  final DateTime visibleMonth;
  final List<CalendarDayData> days;
  final CalendarPeriodSummary monthSummary;
  final CalendarPeriodSummary yearSummary;
  final ActivityStreak streak;
  final CalendarHabitIndicators habits;
  final List<String> insights;

  const CalendarAnalyticsReport({
    required this.visibleMonth,
    required this.days,
    required this.monthSummary,
    required this.yearSummary,
    required this.streak,
    required this.habits,
    required this.insights,
  });

  factory CalendarAnalyticsReport.empty(DateTime visibleMonth) {
    final monthStart = DateTime(visibleMonth.year, visibleMonth.month, 1);
    final monthEnd = DateTime(visibleMonth.year, visibleMonth.month + 1, 1);
    final yearStart = DateTime(visibleMonth.year, 1, 1);
    final yearEnd = DateTime(visibleMonth.year + 1, 1, 1);
    return CalendarAnalyticsReport(
      visibleMonth: visibleMonth,
      days: const [],
      monthSummary: CalendarPeriodSummary(
        periodStart: monthStart,
        periodEnd: monthEnd,
        totalIncome: 0,
        totalExpense: 0,
        netCashFlow: 0,
        transactionCount: 0,
        workingDays: 0,
        spendingDays: 0,
        incomeDays: 0,
        noTransactionDays: 0,
        highestSpendingDay: null,
        highestIncomeDay: null,
      ),
      yearSummary: CalendarPeriodSummary(
        periodStart: yearStart,
        periodEnd: yearEnd,
        totalIncome: 0,
        totalExpense: 0,
        netCashFlow: 0,
        transactionCount: 0,
        workingDays: 0,
        spendingDays: 0,
        incomeDays: 0,
        noTransactionDays: 0,
        highestSpendingDay: null,
        highestIncomeDay: null,
      ),
      streak: ActivityStreak.empty(),
      habits: CalendarHabitIndicators.empty(),
      insights: const [],
    );
  }

  bool get isEmpty => days.every((day) => !day.hasActivity);
}
