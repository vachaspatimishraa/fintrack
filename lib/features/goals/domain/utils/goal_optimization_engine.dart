import 'package:flutter/foundation.dart';
import '../entities/goal_entity.dart';

class GoalOptimizationEngine {
  /// Efficiently filters and sorts a large list of goals.
  /// Uses compute (Isolate) for datasets larger than 500 goals.
  static Future<List<GoalEntity>> processGoals(
    List<GoalEntity> goals, {
    required String query,
    required String sortBy,
    required String filterStatus,
  }) async {
    if (goals.length < 500) {
      return _process(goals, query, sortBy, filterStatus);
    }
    
    return compute(_processInIsolate, {
      'goals': goals,
      'query': query,
      'sortBy': sortBy,
      'filterStatus': filterStatus,
    });
  }

  static List<GoalEntity> _processInIsolate(Map<String, dynamic> params) {
    return _process(
      params['goals'] as List<GoalEntity>,
      params['query'] as String,
      params['sortBy'] as String,
      params['filterStatus'] as String,
    );
  }

  static List<GoalEntity> _process(
    List<GoalEntity> goals, 
    String query, 
    String sortBy, 
    String filterStatus
  ) {
    var list = List<GoalEntity>.from(goals);
    
    // Filter by status
    if (filterStatus != 'all') {
      list = list.where((g) => g.status == filterStatus).toList();
    }

    // Filter by query
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      list = list.where((g) => 
        g.title.toLowerCase().contains(q) || 
        (g.description?.toLowerCase().contains(q) ?? false)
      ).toList();
    }

    // Sort
    switch (sortBy) {
      case 'priority':
        list.sort((a, b) => b.priority.compareTo(a.priority));
        break;
      case 'deadline':
        list.sort((a, b) => a.deadline.compareTo(b.deadline));
        break;
      case 'progress_high':
        list.sort((a, b) => b.progress.compareTo(a.progress));
        break;
      case 'progress_low':
        list.sort((a, b) => a.progress.compareTo(b.progress));
        break;
      case 'newest':
      default:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    
    return list;
  }
}
