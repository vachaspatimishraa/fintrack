class GoalTemplateModel {
  final String uuid;
  final String title;
  final String category;
  final double? suggestedAmount;
  final String? description;
  final List<String> commonMilestones;

  const GoalTemplateModel({
    required this.uuid,
    required this.title,
    required this.category,
    this.suggestedAmount,
    this.description,
    this.commonMilestones = const [],
  });
}
