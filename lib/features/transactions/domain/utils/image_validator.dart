import 'dart:io';
import 'package:path/path.dart' as p;

class ImageValidator {
  static const List<String> _allowedExtensions = ['.jpg', '.jpeg', '.png', '.webp'];
  static const int _maxSizeBytes = 20 * 1024 * 1024; // 20 MB

  static String? validate(File file) {
    final ext = p.extension(file.path).toLowerCase();
    if (!_allowedExtensions.contains(ext)) {
      return 'Format not supported. Only JPG, JPEG, PNG, and WEBP are allowed.';
    }

    try {
      final size = file.lengthSync();
      if (size > _maxSizeBytes) {
        return 'File is too large. Maximum size allowed before compression is 20MB.';
      }
    } catch (e) {
      return 'Unable to read file size: $e';
    }

    return null;
  }
}
