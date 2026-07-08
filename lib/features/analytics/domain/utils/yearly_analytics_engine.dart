import '../entities/yearly_report_data.dart';

class YearlyAnalyticsEngine {
  const YearlyAnalyticsEngine._();

  static YearlyHealth calculateHealth({
    required YearlySummary summary,
    required YearlyBudgetProgress budgetProgress,
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
      if (savingsRatio >= 0.3) {
        score += 25;
        factors.add('Excellent annual savings rate (above 30% of income)');
      } else if (savingsRatio >= 0.15) {
        score += 15;
        factors.add('Healthy annual savings rate (above 15% of income)');
      } else if (savingsRatio < 0) {
        score -= 20;
        factors.add('Negative savings rate (expenditure exceeded income)');
      } else {
        score += 5;
        factors.add('Positive annual savings rate');
      }
    } else {
      if (expense > 0) {
        score -= 20;
        factors.add('No annual income recorded while spending');
      }
    }

    // Expense Ratio (Expense / Income)
    if (income > 0) {
      final expenseRatio = expense / income;
      if (expenseRatio <= 0.6) {
        score += 15;
        factors.add('Expense ratio kept under 60% of income');
      } else if (expenseRatio > 0.9) {
        score -= 15;
        factors.add('High expense ratio (spent over 90% of income)');
      }
    }

    // Cash Flow Stability
    if (cashFlow > 0) {
      score += 10;
      factors.add('Positive cash flow surplus');
    } else if (cashFlow < 0) {
      score -= 15;
      factors.add('Negative annual cash flow deficit');
    }

    // Budget Compliance
    if (budgetProgress.budgetLimit > 0) {
      final utilization = budgetProgress.utilization;
      if (utilization <= 0.85) {
        score += 15;
        factors.add('Strong budget compliance throughout the year');
      } else if (utilization > 1.0) {
        score -= 20;
        factors.add('Overspent annual budget limit');
      } else if (utilization > 0.9) {
        score -= 5;
        factors.add('Approaching annual budget threshold');
      }
    } else {
      if (summary.income > 0 && summary.expense > 0) {
        score += 5;
        factors.add('Financial plan remains stable without a fixed budget');
      }
    }

    score = score.clamp(0.0, 100.0);

    return YearlyHealth(
      score: score,
      grade: _grade(score),
      status: _status(score),
      factors: factors,
    );
  }

  static List<String> generateInsights({
    required YearlySummary summary,
    required YearlyComparison comparison,
    required YearlyBudgetProgress budgetProgress,
    required List<YearlyCategoryBreakdown> categories,
  }) {
    final insights = <String>[];

    // Savings growth
    if (comparison.savingsGrowthPercentage > 0) {
      insights.add(
        'Annual savings increased ${comparison.savingsGrowthPercentage.toStringAsFixed(0)}% compared to last year.',
      );
    } else if (comparison.savingsGrowthPercentage < 0) {
      insights.add(
        'Annual savings decreased ${comparison.savingsGrowthPercentage.abs().toStringAsFixed(0)}% compared to last year.',
      );
    }

    // Expense growth
    if (comparison.expenseGrowthPercentage < 0) {
      insights.add(
        'Annual expenses decreased by ${comparison.expenseGrowthPercentage.abs().toStringAsFixed(0)}% compared to last year.',
      );
    } else if (comparison.expenseGrowthPercentage > 20) {
      insights.add(
        'Annual expenses increased by ${comparison.expenseGrowthPercentage.toStringAsFixed(0)}% compared to last year.',
      );
    }

    // Category specifics
    if (categories.isNotEmpty) {
      final top = categories.first;
      insights.add(
        '${top.category} remained your highest expense category, making up ${top.percentage.toStringAsFixed(0)}% of annual spend.',
      );

      final foodCat = categories.where((c) => c.category.toLowerCase() == 'food').toList();
      if (foodCat.isNotEmpty && foodCat.first.trend == 'down') {
        insights.add('Food expenses decreased this year.');
      }
    }

    // Budget compliance
    if (budgetProgress.budgetLimit > 0) {
      if (budgetProgress.utilization <= 0.85) {
        insights.add('Budget compliance improved significantly this year.');
      }
      if (budgetProgress.exceededCategories.isNotEmpty) {
        final exceeded = budgetProgress.exceededCategories.join(', ');
        insights.add('Budgets for $exceeded were exceeded.');
      }
    }

    if (insights.isEmpty) {
      insights.add('Establish consistent savings and budget compliance to see yearly insights.');
    }

    return insights;
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
