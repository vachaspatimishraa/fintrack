import 'package:uuid/uuid.dart';
import '../entities/budget_entity.dart';
import '../entities/budget_recommendation_entity.dart';
import '../repositories/budget_repository.dart';
import '../repositories/recommendation_repository.dart';
import 'budget_health_calculator.dart';

class BudgetRecommendationEngine {
  final BudgetRepository _budgetRepository;
  final RecommendationRepository _recommendationRepository;

  BudgetRecommendationEngine({
    required BudgetRepository budgetRepository,
    required RecommendationRepository recommendationRepository,
  })  : _budgetRepository = budgetRepository,
        _recommendationRepository = recommendationRepository;

  Future<void> generateRecommendations(String userId) async {
    final budgets = await _budgetRepository.getBudgets();
    final activeBudgets = budgets.where((b) => !b.isDeleted).toList();

    for (final budget in activeBudgets) {
      // Rule 1: Consistent Overspending
      if (budget.progress > 100) {
        await _generateOverspendingRecommendation(userId, budget);
      }

      // Rule 2: Low Utilization (Potential to decrease budget)
      if (budget.progress > 0 && budget.progress < 50) {
        final daysPassed = DateTime.now().difference(budget.startDate).inDays;
        final totalDays = budget.endDate.difference(budget.startDate).inDays;
        if (daysPassed > totalDays * 0.7) { // 70% of the period passed
          await _generateLowUtilizationRecommendation(userId, budget);
        }
      }
    }
    
    // Rule 3: Overall Budget Health
    final healthScore = await BudgetHealthCalculator.calculateScore(activeBudgets);
    if (healthScore < 50) {
       await _generateGeneralHealthRecommendation(userId, healthScore);
    }
  }

  Future<void> _generateOverspendingRecommendation(String userId, BudgetEntity budget) async {
    final title = 'Increase Budget for ${budget.title}?';
    final message = 'You have exceeded your budget for ${budget.title} by ${budget.spentAmount - budget.amount}.';
    final reason = 'Frequent overspending indicates the original limit might be too restrictive.';
    
    await _saveIfUnique(userId, 'budget_increase', title, message, reason, budget.uuid, 0.85);
  }

  Future<void> _generateLowUtilizationRecommendation(String userId, BudgetEntity budget) async {
    final title = 'Optimize ${budget.title} Budget';
    final message = 'You have only used ${budget.progress.toStringAsFixed(0)}% of your budget with most of the period passed.';
    final reason = 'Reallocating unused budget to savings or other categories improves financial efficiency.';
    
    await _saveIfUnique(userId, 'budget_decrease', title, message, reason, budget.uuid, 0.75);
  }

  Future<void> _generateGeneralHealthRecommendation(String userId, double score) async {
    final title = 'Improve Budget Discipline';
    final message = 'Your overall budget health score is low ($score/100).';
    final reason = 'Consistent monitoring and realistic goal setting can help improve your financial health.';
    
    await _saveIfUnique(userId, 'general', title, message, reason, null, 0.90);
  }

  Future<void> _saveIfUnique(String userId, String type, String title, String message, String reason, String? budgetId, double confidence) async {
    final existing = await _recommendationRepository.getRecommendations();
    final duplicate = existing.any((r) => r.type == type && r.budgetId == budgetId);
    
    if (!duplicate) {
      final rec = BudgetRecommendationEntity(
        uuid: const Uuid().v4(),
        userId: userId,
        type: type,
        title: title,
        message: message,
        reason: reason,
        confidence: confidence,
        severity: 'medium',
        createdAt: DateTime.now(),
        budgetId: budgetId,
      );
      await _recommendationRepository.saveRecommendation(rec);
    }
  }
}
