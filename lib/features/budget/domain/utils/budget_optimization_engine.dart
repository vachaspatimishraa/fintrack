import 'package:flutter/foundation.dart';
import '../entities/budget_entity.dart';

class BudgetOptimizationEngine {
  /// Efficiently filters and sorts a large list of budgets.
  /// Could be moved to an Isolate if list size exceeds a threshold.
  static Future<List<BudgetEntity>> processLargeDataset(
    List<BudgetEntity> budgets, {
    required String query,
    required String sortBy,
  }) async {
    if (budgets.length < 1000) {
      return _process(budgets, query, sortBy);
    }
    
    return compute(_processInIsolate, {
      'budgets': budgets,
      'query': query,
      'sortBy': sortBy,
    });
  }

  static List<BudgetEntity> _processInIsolate(Map<String, dynamic> params) {
    return _process(
      params['budgets'] as List<BudgetEntity>,
      params['query'] as String,
      params['sortBy'] as String,
    );
  }

  static List<BudgetEntity> _process(List<BudgetEntity> budgets, String query, String sortBy) {
    var list = List<BudgetEntity>.from(budgets);
    
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      list = list.where((b) => 
        b.title.toLowerCase().contains(q) || 
        (b.description?.toLowerCase().contains(q) ?? false)
      ).toList();
    }

    switch (sortBy) {
      case 'name':
        list.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'amount_high':
        list.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      default:
        list.sort((a, b) => b.startDate.compareTo(a.startDate));
    }
    
    return list;
  }
}
