import 'package:isar/isar.dart';

part 'backup_history_model.g.dart';

@collection
class BackupHistoryModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String uuid = '';

  String backupName = '';
  String backupType = 'manual'; // automatic, manual
  DateTime createdAt = DateTime.now();
  int fileSize = 0;
  int recordCount = 0;
  String status = 'success'; // success, failed
  String checksum = '';
  int version = 1;
}
