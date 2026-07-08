import 'package:isar/isar.dart';
import '../../../../core/database/isar/collections/sync_queue_item.dart';
import '../../data/repositories/sync_coordinator.dart';
import 'repository_logger.dart';

class CrashRecoveryService {
  final Isar _isar;
  final SyncCoordinator _syncCoordinator;

  CrashRecoveryService(this._isar, this._syncCoordinator);

  Future<void> recoverAndSanitize() async {
    RepositoryLogger.logInfo('Starting system Crash Recovery routines...');
    try {
      final pendingCount = await _isar.syncQueueItems
          .filter()
          .syncStatusEqualTo('pending')
          .count();

      if (pendingCount > 0) {
        RepositoryLogger.logInfo('Found $pendingCount interrupted sync items. Invoking Sync Coordinator...');
        await _syncCoordinator.runSync();
      } else {
        RepositoryLogger.logInfo('No interrupted synchronization items found. System in consistent state.');
      }
    } catch (e) {
      RepositoryLogger.logError('Failed to run Crash Recovery routines', e);
    }
  }
}
