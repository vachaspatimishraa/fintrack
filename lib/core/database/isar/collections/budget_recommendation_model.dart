import 'package:isar/isar.dart';

part 'budget_recommendation_model.g.dart';

@collection
class BudgetRecommendationModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String uuid = '';

  String userId = '';
  String type = 'informational'; // budget_increase, budget_decrease, reduce_spending, etc.
  String title = '';
  String message = '';
  String reason = '';
  
  double expectedSavings = 0.0;
  double confidence = 0.0; // 0.0 to 1.0
  
  bool accepted = false;
  bool dismissed = false;
  bool applied = false;
  
  DateTime createdAt = DateTime.now();
  DateTime? appliedAt;
  DateTime? dismissedAt;
  
  String severity = 'informational'; // informational, low, medium, high, critical
  
  String? budgetId;
  String? categoryId;
}
