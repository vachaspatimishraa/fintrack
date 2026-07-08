import '../entities/goal_progress_model.dart';
import '../entities/goal_forecast_model.dart';

/// Core engine for calculating goal progress, forecasts and achievements.
/// 
/// This service must remain deterministic and independently testable.
abstract class GoalEngine {
  /// Calculates real-time progress for a specific goal.
  Future<GoalProgressModel> calculateProgress(String goalId);

  /// Generates a financial forecast for when the goal will be reached.
  Future<GoalForecastModel> forecast(String goalId);
}
