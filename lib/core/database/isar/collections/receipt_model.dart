import 'package:isar/isar.dart';

part 'receipt_model.g.dart';

@collection
class ReceiptModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String uuid = '';

  @Index()
  String transactionId = '';

  String localPath = '';
  String? cloudUrl;
  String mimeType = 'image/jpeg';
  int fileSize = 0;
  int width = 0;
  int height = 0;

  bool isUploaded = false;
  bool isDeleted = false;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': uuid,
      'transaction_id': transactionId,
      'local_path': localPath,
      'cloud_url': cloudUrl,
      'mime_type': mimeType,
      'file_size': fileSize,
      'width': width,
      'height': height,
      'is_uploaded': isUploaded,
      'is_deleted': isDeleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  static ReceiptModel fromJson(Map<String, dynamic> json) {
    return ReceiptModel()
      ..uuid = json['id'] as String? ?? ''
      ..transactionId = json['transaction_id'] as String? ?? ''
      ..localPath = json['local_path'] as String? ?? ''
      ..cloudUrl = json['cloud_url'] as String?
      ..mimeType = json['mime_type'] as String? ?? 'image/jpeg'
      ..fileSize = json['file_size'] as int? ?? 0
      ..width = json['width'] as int? ?? 0
      ..height = json['height'] as int? ?? 0
      ..isUploaded = json['is_uploaded'] as bool? ?? false
      ..isDeleted = json['is_deleted'] as bool? ?? false
      ..createdAt = DateTime.parse(json['created_at'] as String)
      ..updatedAt = DateTime.parse(json['updated_at'] as String);
  }
}
