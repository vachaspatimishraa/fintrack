import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../../providers/ai_insight_provider.dart';

class AIInsightController {
  final AnalyticsRepository _repository;
  final Ref ref;

  AIInsightController(this._repository, this.ref);

  Future<void> pinInsight(String id) async {
    await _repository.pinInsight(id);
    ref.invalidate(aiInsightsProvider);
    ref.invalidate(aiInsightHistoryProvider);
  }

  Future<void> dismissInsight(String id) async {
    await _repository.dismissInsight(id);
    ref.invalidate(aiInsightsProvider);
    ref.invalidate(aiInsightHistoryProvider);
  }

  void refresh() {
    ref.invalidate(aiInsightsProvider);
    ref.invalidate(aiInsightHistoryProvider);
  }
}
