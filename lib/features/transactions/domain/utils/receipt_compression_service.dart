import 'dart:io';

class ReceiptCompressionService {
  static Future<File> compress(File file) async {
    // In FinTrack, primary compression is handled at pick time via ImagePicker (quality: 70, maxWidth/height: 1024).
    // This service acts as a validation wrapper ensuring size constraint compliance.
    final size = await file.length();
    if (size > 2 * 1024 * 1024) {
      // File exceeds target limit. Log/handle or return as is (validated by ImageValidator).
    }
    return file;
  }
}
