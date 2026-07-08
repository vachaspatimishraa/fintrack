import '../../../transactions/domain/entities/transaction_entity.dart';
import '../entities/ai_insight_data.dart';
import 'pattern_detection_service.dart';
import 'forecast_service.dart';
import 'ai_recommendation_engine.dart';

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
