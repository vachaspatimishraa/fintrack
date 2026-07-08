import '../../../../core/database/isar/collections/backup_history_model.dart';
import '../../domain/entities/backup_history_entity.dart';

class BackupHistoryMapper {
  static BackupHistoryEntity toEntity(BackupHistoryModel model) {
    return BackupHistoryEntity(
      uuid: model.uuid,
      backupName: model.backupName,
      backupType: model.backupType,
      createdAt: model.createdAt,
      fileSize: model.fileSize,
      recordCount: model.recordCount,
      status: model.status,
      checksum: model.checksum,
      version: model.version,
    );
  }

  static BackupHistoryModel toModel(BackupHistoryEntity entity) {
    return BackupHistoryModel()
      ..uuid = entity.uuid
      ..backupName = entity.backupName
      ..backupType = entity.backupType
      ..createdAt = entity.createdAt
      ..fileSize = entity.fileSize
      ..recordCount = entity.recordCount
      ..status = entity.status
      ..checksum = entity.checksum
      ..version = entity.version;
  }
}
