import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/goal_provider.dart';

class MemoryManager {
  static void clearGoalCache(Ref ref) {
    // Logic to clear repository cache if needed or invalidate providers
    ref.invalidate(goalsStreamProvider);
  }

  static void onLogout(Ref ref) {
    clearGoalCache(ref);
  }
}
