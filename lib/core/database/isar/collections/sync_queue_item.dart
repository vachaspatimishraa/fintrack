import 'package:isar/isar.dart';

part 'sync_queue_item.g.dart';

@collection
class SyncQueueItem {
  Id id = Isar.autoIncrement;

  String entityType = ''; // 'account', 'transaction'
  String entityUuid = '';
  String action = ''; // 'create', 'update', 'delete'
  String payload = '{}'; // JSON representation of model
  DateTime createdAt = DateTime.now();

  int retryCount = 0;
  String syncStatus = 'pending'; // 'pending', 'failed', 'processing'
}
