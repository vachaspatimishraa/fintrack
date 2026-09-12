import 'package:fintrack/features/transactions/domain/entities/transaction_entity.dart';
import 'package:fintrack/features/analytics/domain/entities/ai_insight_data.dart';
import 'package:fintrack/features/analytics/domain/utils/pattern_detection_service.dart';
import 'package:fintrack/features/analytics/domain/utils/forecast_service.dart';
import 'package:fintrack/features/analytics/domain/utils/ai_recommendation_engine.dart';

class AIInsightEngine {
  const AIInsightEngine._();

  static AIInsightsReport generate({
    required List<TransactionEntity> transactions,
  }) {
    final activeTx = transactions.where((tx) => !tx.isDeleted).toList();
    if (activeTx.isEmpty) {
      return AIInsightsReport.empty();
    }

    final patterns = PatternDetectionService.detect(activeTx);
    final forecast = ForecastService.calculate(transactions: activeTx);
    final insights = AIRecommendationEngine.generate(transactions: activeTx);

    return AIInsightsReport(
      currentInsights: insights,
      forecast: forecast,
      detectedPatterns: patterns,
      isEmpty: false,
    );
  }
}
