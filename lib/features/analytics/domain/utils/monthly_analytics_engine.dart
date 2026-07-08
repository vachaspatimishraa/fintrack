import '../entities/monthly_report_data.dart';

class MonthlyAnalyticsEngine {
  const MonthlyAnalyticsEngine._();

  static MonthlyScore calculateScore({
    required MonthlySummary summary,
    required MonthlyBudgetProgress budgetProgress,
  }) {
    double score = 50.0;
    final factors = <String>[];

    final income = summary.income;
    final expense = summary.expense;
    final savings = summary.savings;
    final cashFlow = summary.cashFlow;

    // Savings Ratio (Savings / Income)
    if (income > 0) {
      final savingsRatio = savings / income;
      if (savingsRatio >= 0.4) {
        score += 25;
        factors.add('Excellent savings rate (above 40% of income)');
      } else if (savingsRatio >= 0.2) {
        score += 15;
        factors.add('Healthy savings rate (above 20% of income)');
      } else if (savingsRatio < 0) {
        score -= 15;
        factors.add('Negative savings rate (spending exceeded income)');
      } else {
        score += 5;
        factors.add('Positive savings rate');
      }
    } else {
      if (expense > 0) {
        score -= 20;
        factors.add('No income recorded while spending');
      }
    }

    // Expense Ratio (Expense / Income)
    if (income > 0) {
      final expenseRatio = expense / income;
      if (expenseRatio <= 0.5) {
        score += 15;
        factors.add('Expense ratio kept below 50%');
      } else if (expenseRatio > 0.9) {
        score -= 15;
        factors.add('High expense ratio (spent over 90% of income)');
      }
    }

    // Cash Flow
    if (cashFlow > 0) {
      score += 10;
      factors.add('Positive cash flow');
    } else if (cashFlow < 0) {
      score -= 15;
      factors.add('Negative cash flow');
    }

    // Budget Compliance
    if (budgetProgress.budgetLimit > 0) {
      final utilization = budgetProgress.utilization;
      if (utilization <= 0.8) {
        score += 15;
        factors.add('Under budget limit with safe margin');
      } else if (utilization > 1.0) {
        score -= 20;
        factors.add('Exceeded overall budget limit');
      } else if (utilization > 0.9) {
        score -= 5;
        factors.add('Approaching overall budget limit (warning)');
      }
    } else {
      if (summary.income > 0 && summary.expense > 0) {
        score += 5;
        factors.add('Budget compliance stable');
      }
    }

    score = score.clamp(0.0, 100.0);

    return MonthlyScore(
      score: score,
      grade: _grade(score),
      status: _status(score),
      factors: factors,
    );
  }

  static List<String> generateRecommendations({
    required MonthlySummary summary,
    required MonthlyComparison comparison,
    required MonthlyBudgetProgress budgetProgress,
    required List<MonthlyCategoryBreakdown> categories,
  }) {
    final recommendations = <String>[];

    // Savings increase comparison
    if (comparison.savingsGrowthPercentage > 0) {
      recommendations.add(
        'Savings increased ${comparison.savingsGrowthPercentage.toStringAsFixed(0)}% compared to last month.',
      );
    } else if (comparison.savingsGrowthPercentage < 0) {
      recommendations.add(
        'Savings decreased ${comparison.savingsGrowthPercentage.abs().toStringAsFixed(0)}% compared to last month.',
      );
    }

    // Expense changes
    if (comparison.expenseGrowthPercentage < 0) {
      recommendations.add(
        'Total expenses reduced by ${comparison.expenseGrowthPercentage.abs().toStringAsFixed(0)}% compared to last month.',
      );
    } else if (comparison.expenseGrowthPercentage > 15) {
      recommendations.add(
        'Total expenses increased by ${comparison.expenseGrowthPercentage.toStringAsFixed(0)}% compared to last month. Consider review.',
      );
    }

    // Category specific budget exceeded
    if (budgetProgress.exceededCategories.isNotEmpty) {
      final categoriesList = budgetProgress.exceededCategories.join(', ');
      recommendations.add(
        '$categoriesList exceeded the allocated budget.',
      );
    } else if (budgetProgress.budgetLimit > 0 && budgetProgress.utilization <= 0.9) {
      recommendations.add('Budget compliance improved this month.');
    }

    // Highlight top expense category
    if (categories.isNotEmpty) {
      final top = categories.first;
      recommendations.add(
        '${top.category} is your highest spending category at ${top.percentage.toStringAsFixed(0)}% of expenses.',
      );
    }

    // If no recommendations generated, add a default one
    if (recommendations.isEmpty) {
      recommendations.add('Great job tracking your finances. Maintain this habit next month.');
    }

    return recommendations;
  }

  static String _grade(double score) {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }

  static String _status(double score) {
    if (score >= 85) return 'Excellent';
    if (score >= 70) return 'Good';
    if (score >= 55) return 'Fair';
    return 'Needs Attention';
  }
}
