import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/settings/data/mappers/backup_history_mapper.dart';
import 'package:fintrack/features/settings/domain/entities/backup_history_entity.dart';

void main() {
  group('Backup Settings', () {
    test('BackupHistoryMapper should map correctly', () {
      final entity = BackupHistoryEntity(
        uuid: 'backup-123',
        backupName: 'Test Backup',
        backupType: 'manual',
        createdAt: DateTime(2026, 7, 4),
        fileSize: 1024,
        recordCount: 50,
        status: 'success',
        checksum: 'abc',
        version: 1,
      );

      final model = BackupHistoryMapper.toModel(entity);

      expect(model.uuid, entity.uuid);
      expect(model.backupName, entity.backupName);
      expect(model.recordCount, entity.recordCount);
    });
  });
}
