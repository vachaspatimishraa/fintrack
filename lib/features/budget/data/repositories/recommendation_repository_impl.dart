import 'package:isar/isar.dart';
import 'package:fintrack/core/database/isar/collections/budget_recommendation_model.dart';
import 'package:fintrack/features/budget/domain/entities/budget_recommendation_entity.dart';
import 'package:fintrack/features/budget/domain/repositories/recommendation_repository.dart';
import 'package:fintrack/features/budget/data/mappers/budget_recommendation_mapper.dart';

class RecommendationRepositoryImpl implements RecommendationRepository {
  final Isar _isar;

  RecommendationRepositoryImpl(this._isar);

  @override
  Stream<List<BudgetRecommendationEntity>> watchRecommendations() {
    return _isar.budgetRecommendationModels
        .filter()
        .dismissedEqualTo(false)
        .appliedEqualTo(false)
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true)
        .map((models) => models.map(BudgetRecommendationMapper.toEntity).toList());
  }

  @override
  Future<List<BudgetRecommendationEntity>> getRecommendations() async {
    final models = await _isar.budgetRecommendationModels
        .filter()
        .dismissedEqualTo(false)
        .appliedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
    return models.map(BudgetRecommendationMapper.toEntity).toList();
  }

  @override
  Future<void> saveRecommendation(BudgetRecommendationEntity recommendation) async {
    final model = BudgetRecommendationMapper.toModel(recommendation);
    await _isar.writeTxn(() async {
      await _isar.budgetRecommendationModels.put(model);
    });
  }

  @override
  Future<void> dismissRecommendation(String uuid) async {
    final model = await _isar.budgetRecommendationModels.filter().uuidEqualTo(uuid).findFirst();
    if (model != null) {
      model.dismissed = true;
      model.dismissedAt = DateTime.now();
      await _isar.writeTxn(() async {
        await _isar.budgetRecommendationModels.put(model);
      });
    }
  }

  @override
  Future<void> acceptRecommendation(String uuid) async {
    final model = await _isar.budgetRecommendationModels.filter().uuidEqualTo(uuid).findFirst();
    if (model != null) {
      model.accepted = true;
      await _isar.writeTxn(() async {
        await _isar.budgetRecommendationModels.put(model);
      });
    }
  }

  @override
  Future<void> applyRecommendation(String uuid) async {
    final model = await _isar.budgetRecommendationModels.filter().uuidEqualTo(uuid).findFirst();
    if (model != null) {
      model.applied = true;
      model.appliedAt = DateTime.now();
      await _isar.writeTxn(() async {
        await _isar.budgetRecommendationModels.put(model);
      });
    }
  }
}
