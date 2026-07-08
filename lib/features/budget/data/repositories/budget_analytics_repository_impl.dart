import 'package:flutter/material.dart';
import '../../domain/entities/budget_analytics.dart';
import '../../domain/entities/budget_history_record.dart';
import '../../domain/entities/budget_insight.dart';
import '../../domain/repositories/budget_analytics_repository.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../../transactions/domain/repositories/transaction_repository.dart';

class BudgetAnalyticsRepositoryImpl implements BudgetAnalyticsRepository {
  final BudgetRepository _budgetRepository;
  final TransactionRepository _transactionRepository;

  BudgetAnalyticsRepositoryImpl({
    required BudgetRepository budgetRepository,
    required TransactionRepository transactionRepository,
  })  : _budgetRepository = budgetRepository,
        _transactionRepository = transactionRepository;

  @override
  Future<BudgetAnalytics> getBudgetAnalytics() async {
    final budgets = await _budgetRepository.getActiveBudgets();
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final remainingDays = daysInMonth - now.day + 1;

    double totalBudget = 0;
    double totalSpent = 0;

    for (final b in budgets) {
      if (b.startDate.month == now.month && b.startDate.year == now.year) {
        totalBudget += b.amount;
        totalSpent += b.spentAmount;
      }
    }

    final remaining = totalBudget - totalSpent;
    final utilization = totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0.0;
    final avgDaily = now.day > 0 ? totalSpent / now.day : 0.0;
    final remainingDaily = remainingDays > 0 ? (remaining > 0 ? remaining / remainingDays : 0.0) : 0.0;
    
    // Linear Forecast
    final forecasted = avgDaily * daysInMonth;

    // Efficiency Score (0-100)
    // Factors: Compliance (utilization), Savings
    double efficiencyScore = 100 - utilization;
    if (efficiencyScore < 0) efficiencyScore = 0;
    
    // Boost score if we are well under budget
    if (utilization < 50) efficiencyScore += 10;
    if (efficiencyScore > 100) efficiencyScore = 100;

    String status = 'Excellent';
    if (efficiencyScore < 20) {
      status = 'Critical';
    } else if (efficiencyScore < 40) status = 'Poor';
    else if (efficiencyScore < 60) status = 'Average';
    else if (efficiencyScore < 80) status = 'Good';

    final history = await getBudgetHistory();
    final successfulMonths = history.where((h) => h.status == 'Successful').length;
    final successRate = history.isNotEmpty ? (successfulMonths / history.length) * 100 : 0.0;

    return BudgetAnalytics(
      currentMonthBudget: totalBudget,
      currentMonthSpent: totalSpent,
      remainingBudget: remaining,
      utilizationPercentage: utilization,
      averageDailySpending: avgDaily,
      remainingDailyLimit: remainingDaily,
      monthlySavings: remaining > 0 ? remaining : 0.0,
      overspentAmount: totalSpent > totalBudget ? totalSpent - totalBudget : 0.0,
      forecastedSpending: forecasted,
      budgetEfficiencyScore: efficiencyScore,
      healthStatus: status,
      successRate: successRate,
    );
  }

  @override
  Future<List<BudgetHistoryRecord>> getBudgetHistory() async {
    // In a real app, we might query Isar for completed budgets across months
    // For now, let's simulate or derive from existing budgets
    final budgets = await _budgetRepository.getBudgets();
    
    // Group by month/year
    final Map<String, BudgetHistoryRecord> historyMap = {};

    for (final b in budgets) {
      final key = '${b.startDate.month}-${b.startDate.year}';
      final monthName = _getMonthName(b.startDate.month);
      
      if (historyMap.containsKey(key)) {
        final existing = historyMap[key]!;
        final newBudget = existing.budgetAmount + b.amount;
        final newSpent = existing.spentAmount + b.spentAmount;
        final newRemaining = newBudget - newSpent;
        
        historyMap[key] = BudgetHistoryRecord(
          month: monthName,
          year: b.startDate.year,
          budgetAmount: newBudget,
          spentAmount: newSpent,
          remainingAmount: newRemaining,
          savings: newRemaining > 0 ? newRemaining : 0.0,
          utilizationPercentage: newBudget > 0 ? (newSpent / newBudget) * 100 : 0.0,
          status: newSpent <= newBudget ? 'Successful' : 'Exceeded',
          createdAt: existing.createdAt,
          updatedAt: b.updatedAt,
        );
      } else {
        final remaining = b.amount - b.spentAmount;
        historyMap[key] = BudgetHistoryRecord(
          month: monthName,
          year: b.startDate.year,
          budgetAmount: b.amount,
          spentAmount: b.spentAmount,
          remainingAmount: remaining,
          savings: remaining > 0 ? remaining : 0.0,
          utilizationPercentage: b.amount > 0 ? (b.spentAmount / b.amount) * 100 : 0.0,
          status: b.spentAmount <= b.amount ? 'Successful' : 'Exceeded',
          createdAt: b.createdAt,
          updatedAt: b.updatedAt,
        );
      }
    }

    final list = historyMap.values.toList();
    list.sort((a, b) {
      if (a.year != b.year) return b.year.compareTo(a.year);
      return _getMonthNumber(b.month).compareTo(_getMonthNumber(a.month));
    });
    
    return list;
  }

  @override
  Future<List<BudgetInsight>> getBudgetInsights() async {
    final analytics = await getBudgetAnalytics();
    final List<BudgetInsight> insights = [];

    if (analytics.utilizationPercentage > 100) {
      insights.add(BudgetInsight(
        message: 'You have exceeded your total budget this month.',
        icon: Icons.warning,
        color: Colors.red,
        type: 'negative',
      ));
    } else if (analytics.utilizationPercentage > 80) {
      insights.add(BudgetInsight(
        message: 'You are near your budget limit. Consider reducing non-essential spending.',
        icon: Icons.info,
        color: Colors.orange,
        type: 'neutral',
      ));
    } else {
      insights.add(BudgetInsight(
        message: 'Your spending is within a healthy range. Keep it up!',
        icon: Icons.check_circle,
        color: Colors.green,
        type: 'positive',
      ));
    }

    final history = await getBudgetHistory();
    if (history.length >= 2) {
      final lastMonth = history[1];
      final currentMonth = history[0];
      if (currentMonth.spentAmount < lastMonth.spentAmount) {
        final diff = ((lastMonth.spentAmount - currentMonth.spentAmount) / lastMonth.spentAmount * 100).toStringAsFixed(0);
        insights.add(BudgetInsight(
          message: 'You spent $diff% less than last month.',
          icon: Icons.trending_down,
          color: Colors.green,
          type: 'positive',
        ));
      }
    }

    return insights;
  }

  @override
  Future<Map<String, double>> getCategorySpending() async {
    final budgets = await _budgetRepository.getCategoryBudgets();
    final Map<String, double> spending = {};
    for (final b in budgets) {
      if (b.categoryId != null) {
        spending[b.categoryId!] = b.spentAmount;
      }
    }
    return spending;
  }

  @override
  Future<Map<String, double>> getMonthlyTrends() async {
    final history = await getBudgetHistory();
    final Map<String, double> trends = {};
    // Take last 6 months
    final recent = history.take(6).toList().reversed;
    for (final h in recent) {
      trends['${h.month.substring(0, 3)} ${h.year % 100}'] = h.spentAmount;
    }
    return trends;
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  int _getMonthNumber(String name) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months.indexOf(name) + 1;
  }
}
