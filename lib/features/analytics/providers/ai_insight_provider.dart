import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/ai_insight_data.dart';
import '../presentation/controllers/ai_insight_controller.dart';
import 'analytics_provider.dart';

final aiInsightsProvider = StreamProvider<AIInsightsReport>((ref) {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.watchAIInsights();
});

final aiInsightHistoryProvider = FutureProvider<List<AIInsight>>((ref) {
  final repository = ref.watch(analyticsRepositoryProvider);
  // Re-run whenever transactions change
  ref.watch(analyticsStreamProvider);
  return repository.getInsightHistory();
});

final aiInsightControllerProvider = Provider<AIInsightController>((ref) {
  final repository = ref.watch(analyticsRepositoryProvider);
  return AIInsightController(repository, ref);
});
