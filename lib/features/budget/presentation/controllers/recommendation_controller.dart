import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fintrack/features/budget/domain/repositories/recommendation_repository.dart';
import 'package:fintrack/features/budget/providers/recommendation_provider.dart';

class RecommendationController {
  final Ref _ref;

  RecommendationController(this._ref);

  RecommendationRepository get _repository => _ref.read(recommendationRepositoryProvider);

  Future<void> dismissRecommendation(String uuid) async {
    await _repository.dismissRecommendation(uuid);
  }

  Future<void> acceptRecommendation(String uuid) async {
    await _repository.acceptRecommendation(uuid);
  }

  Future<void> applyRecommendation(String uuid) async {
    await _repository.applyRecommendation(uuid);
  }
}

final recommendationControllerProvider = Provider<RecommendationController>(RecommendationController.new);
