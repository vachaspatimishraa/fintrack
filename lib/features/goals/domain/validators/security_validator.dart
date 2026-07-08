import '../entities/goal_entity.dart';

/// Validator for security and privacy compliance in Goals.
class SecurityValidator {
  /// Ensures no sensitive info is leaked in goal metadata.
  static bool validateGoal(GoalEntity entity) {
    // Check for accidental storage of passwords or tokens in descriptions
    final content = '${entity.title} ${entity.description ?? ''}'.toLowerCase();
    if (content.contains('password') || content.contains('token')) return false;
    return true;
  }

  /// Verifies that data access is restricted to the owner.
  static bool verifyOwnership(String ownerId, String currentUserId) {
    return ownerId == currentUserId;
  }
}
