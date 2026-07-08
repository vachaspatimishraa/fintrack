import 'package:uuid/uuid.dart';
import '../entities/budget_entity.dart';
import '../entities/budget_alert_entity.dart';
import '../repositories/budget_alert_repository.dart';

class BudgetAlertEngine {
  final BudgetAlertRepository _alertRepository;

  BudgetAlertEngine(this._alertRepository);

  Future<void> checkBudget(BudgetEntity budget) async {
    final progress = budget.progress;
    final threshold = budget.alertThreshold;

    // Check for "Exceeded" alert (100%+)
    if (progress >= 100) {
      await _generateAlertIfUnique(
        budgetId: budget.uuid,
        alertType: 'exceeded',
        severity: 'critical',
        title: 'Budget Exceeded',
        message: 'Your budget for "${budget.title}" has been exceeded.',
        threshold: 100,
      );
    } 
    // Check for "Critical" alert (e.g., 90% or custom threshold if high)
    else if (progress >= 90) {
      await _generateAlertIfUnique(
        budgetId: budget.uuid,
        alertType: 'critical',
        severity: 'high',
        title: 'Critical Budget Level',
        message: 'You have used 90% of your budget for "${budget.title}".',
        threshold: 90,
      );
    }
    // Check for "Warning" alert (custom threshold or 80%)
    else if (progress >= threshold) {
      await _generateAlertIfUnique(
        budgetId: budget.uuid,
        alertType: 'warning',
        severity: 'medium',
        title: 'Budget Warning',
        message: 'You have used ${progress.toStringAsFixed(0)}% of your budget for "${budget.title}".',
        threshold: threshold,
      );
    }
  }

  Future<void> _generateAlertIfUnique({
    required String budgetId,
    required String alertType,
    required String severity,
    required String title,
    required String message,
    required double threshold,
  }) async {
    final existingAlerts = await _alertRepository.getAlertsByBudgetId(budgetId);
    
    // Check if an active (not dismissed/resolved) alert of the same type and threshold already exists
    final alreadyExists = existingAlerts.any((a) =>
      a.alertType == alertType && 
      a.threshold == threshold && 
      !a.dismissed && 
      !a.resolved
    );

    if (!alreadyExists) {
      final alert = BudgetAlertEntity(
        uuid: const Uuid().v4(),
        budgetId: budgetId,
        alertType: alertType,
        severity: severity,
        title: title,
        message: message,
        threshold: threshold,
        triggered: true,
        triggeredAt: DateTime.now(),
        createdAt: DateTime.now(),
      );
      await _alertRepository.saveAlert(alert);
    }
  }
}
