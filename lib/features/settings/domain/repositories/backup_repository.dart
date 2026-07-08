import '../entities/backup_history_entity.dart';

abstract class BackupRepository {
  Future<void> createManualBackup();
  Future<void> restoreFromBackup(String uuid);
  Future<List<BackupHistoryEntity>> getBackupHistory();
  Stream<List<BackupHistoryEntity>> watchBackupHistory();
  Future<void> deleteBackup(String uuid);
  Future<void> verifyBackup(String uuid);
  Future<void> triggerCloudSync();
}
