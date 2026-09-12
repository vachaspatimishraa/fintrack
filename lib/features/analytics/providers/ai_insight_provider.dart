import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fintrack/features/analytics/domain/entities/ai_insight_data.dart';
import 'package:fintrack/features/analytics/presentation/controllers/ai_insight_controller.dart';
import 'package:fintrack/features/analytics/providers/analytics_provider.dart';

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
