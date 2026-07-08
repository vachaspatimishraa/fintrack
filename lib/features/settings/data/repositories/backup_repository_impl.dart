import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/database/isar/collections/backup_history_model.dart';
import '../../domain/entities/backup_history_entity.dart';
import '../../domain/repositories/backup_repository.dart';
import '../mappers/backup_history_mapper.dart';
import '../../../sync/providers/sync_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BackupRepositoryImpl implements BackupRepository {
  final Isar _isar;
  final Ref _ref;

  BackupRepositoryImpl(this._isar, this._ref);

  @override
  Future<void> createManualBackup() async {
    final backup = BackupHistoryModel()
      ..uuid = const Uuid().v4()
      ..backupName = 'Manual Backup ${DateTime.now()}'
      ..backupType = 'manual'
      ..createdAt = DateTime.now()
      ..fileSize = 0 // In a real app, calculate file size
      ..recordCount = 0 // In a real app, count records
      ..status = 'success'
      ..checksum = ''
      ..version = 1;

    await _isar.writeTxn(() => _isar.backupHistoryModels.put(backup));
  }

  @override
  Future<void> restoreFromBackup(String uuid) async {
    // Restoration logic here
  }

  @override
  Future<List<BackupHistoryEntity>> getBackupHistory() async {
    final models = await _isar.backupHistoryModels.where().sortByCreatedAtDesc().findAll();
    return models.map((m) => BackupHistoryMapper.toEntity(m)).toList();
  }

  @override
  Stream<List<BackupHistoryEntity>> watchBackupHistory() {
    return _isar.backupHistoryModels
        .where()
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true)
        .map((models) => models.map((m) => BackupHistoryMapper.toEntity(m)).toList());
  }

  @override
  Future<void> deleteBackup(String uuid) async {
    await _isar.writeTxn(() async {
      await _isar.backupHistoryModels.filter().uuidEqualTo(uuid).deleteFirst();
    });
  }

  @override
  Future<void> verifyBackup(String uuid) async {
    // Verification logic
  }

  @override
  Future<void> triggerCloudSync() async {
    await _ref.read(syncStatusProvider.notifier).triggerSync();
  }
}
