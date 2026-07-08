class BackupHistoryEntity {
  final String uuid;
  final String backupName;
  final String backupType;
  final DateTime createdAt;
  final int fileSize;
  final int recordCount;
  final String status;
  final String checksum;
  final int version;

  BackupHistoryEntity({
    required this.uuid,
    required this.backupName,
    required this.backupType,
    required this.createdAt,
    required this.fileSize,
    required this.recordCount,
    required this.status,
    required this.checksum,
    required this.version,
  });
}
