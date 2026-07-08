import '../entities/ai_insight_data.dart';

class RuleEngine {
  const RuleEngine._();

  static bool isWarning(AIInsight insight) {
    return insight.severity.toLowerCase() == 'warning';
  }

  static bool isCritical(AIInsight insight) {
    return insight.severity.toLowerCase() == 'critical';
  }

  static bool isPositive(AIInsight insight) {
    return insight.severity.toLowerCase() == 'positive';
  }
}
