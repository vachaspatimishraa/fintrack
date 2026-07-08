import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../providers/budget_provider.dart';

class CategoryBudgetController {
  final Ref _ref;

  CategoryBudgetController(this._ref);

  BudgetRepository get _repository => _ref.read(budgetRepositoryProvider);

  Future<void> createCategoryBudget({
    required String categoryId,
    required double amount,
    required DateTime startDate,
    required DateTime endDate,
    String? title,
    String? description,
    double alertThreshold = 80.0,
  }) async {
    final budget = BudgetEntity(
      uuid: '',
      ownerId: '', 
      title: title ?? categoryId,
      budgetType: 'category',
      amount: amount,
      categoryId: categoryId,
      startDate: startDate,
      endDate: endDate,
      description: description,
      alertThreshold: alertThreshold,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _repository.createBudget(budget);
    await _repository.refresh();
  }

  Future<void> updateAmount(String uuid, double newAmount) async {
    final budget = await _repository.getBudget(uuid);
    if (budget != null) {
      await _repository.updateBudget(budget.copyWith(amount: newAmount));
      await _repository.refresh();
    }
  }
}

final categoryBudgetControllerProvider = Provider<CategoryBudgetController>((ref) => CategoryBudgetController(ref));
