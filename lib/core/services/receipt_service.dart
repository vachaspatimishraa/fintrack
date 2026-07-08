import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class ReceiptService {
  final ImagePicker _picker = ImagePicker();

  SupabaseClient get _supabase => Supabase.instance.client;

  Future<File?> pickReceipt(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 70,
    );
    if (pickedFile == null) return null;
    return File(pickedFile.path);
  }

  Future<String> saveReceiptLocally(File file) async {
    final dir = await getApplicationDocumentsDirectory();
    final extension = p.extension(file.path);
    final fileName = '${const Uuid().v4()}$extension';
    final receiptsDir = Directory('${dir.path}/receipts');
    if (!await receiptsDir.exists()) {
      await receiptsDir.create(recursive: true);
    }
    final localPath = '${receiptsDir.path}/$fileName';
    await file.copy(localPath);
    return localPath;
  }

  Future<String?> uploadReceipt(File file) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final extension = p.extension(file.path);
      final fileName = '$userId/${const Uuid().v4()}$extension';

      await _supabase.storage
          .from('receipts')
          .upload(
            fileName,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final publicUrl = _supabase.storage
          .from('receipts')
          .getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading receipt to Supabase: $e');
      return null;
    }
  }
}
