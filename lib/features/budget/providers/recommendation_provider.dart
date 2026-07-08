import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../splash/providers/initialization_provider.dart';
import '../data/repositories/recommendation_repository_impl.dart';
import '../domain/entities/budget_recommendation_entity.dart';
import '../domain/repositories/recommendation_repository.dart';
import '../domain/utils/budget_recommendation_engine.dart';
import 'budget_provider.dart';

final recommendationRepositoryProvider = Provider<RecommendationRepository>((ref) {
  final isarService = ref.watch(isarInitializationServiceProvider);
  return RecommendationRepositoryImpl(isarService.isar);
});

final recommendationsStreamProvider = StreamProvider<List<BudgetRecommendationEntity>>((ref) {
  final repository = ref.watch(recommendationRepositoryProvider);
  return repository.watchRecommendations();
});

final budgetRecommendationEngineProvider = Provider<BudgetRecommendationEngine>((ref) {
  final budgetRepo = ref.watch(budgetRepositoryProvider);
  final recRepo = ref.watch(recommendationRepositoryProvider);
  return BudgetRecommendationEngine(
    budgetRepository: budgetRepo,
    recommendationRepository: recRepo,
  );
});

final budgetRecommendationGeneratorProvider = FutureProvider<void>((ref) async {
  final engine = ref.watch(budgetRecommendationEngineProvider);
  final userId = ref.read(authProvider).user?.id ?? 'guest';
  // Also watch budgets and transactions to trigger regeneration
  ref.watch(budgetsStreamProvider);
  return engine.generateRecommendations(userId);
});
