import '../entities/goal_entity.dart';

class LazyLoadingManager {
  static const int defaultPageSize = 50;

  static List<GoalEntity> getPage(List<GoalEntity> allGoals, int pageIndex) {
    final start = pageIndex * defaultPageSize;
    if (start >= allGoals.length) return [];
    
    final end = (start + defaultPageSize).clamp(0, allGoals.length);
    return allGoals.sublist(start, end);
  }
}
