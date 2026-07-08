import '../entities/budget_recommendation_entity.dart';

abstract class RecommendationRepository {
  Stream<List<BudgetRecommendationEntity>> watchRecommendations();
  Future<List<BudgetRecommendationEntity>> getRecommendations();
  Future<void> saveRecommendation(BudgetRecommendationEntity recommendation);
  Future<void> dismissRecommendation(String uuid);
  Future<void> acceptRecommendation(String uuid);
  Future<void> applyRecommendation(String uuid);
}
