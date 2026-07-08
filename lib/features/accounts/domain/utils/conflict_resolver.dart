import '../../../../core/database/isar/collections/account_model.dart';

enum ConflictResolutionResult {
  localWins,
  remoteWins,
  noConflict,
}

class ConflictResolver {
  static ConflictResolutionResult resolve({
    required AccountModel local,
    required AccountModel remote,
  }) {
    if (remote.updatedAt.isAfter(local.updatedAt)) {
      return ConflictResolutionResult.remoteWins;
    } else if (local.updatedAt.isAfter(remote.updatedAt)) {
      return ConflictResolutionResult.localWins;
    }
    return ConflictResolutionResult.noConflict;
  }
}
