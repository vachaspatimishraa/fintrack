import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ReceiptCacheService {
  Future<bool> existsLocally(String? localPath) async {
    if (localPath == null || localPath.isEmpty) return false;
    return File(localPath).exists();
  }

  Future<File?> getOrDownload({
    required String? localPath,
    required String? cloudUrl,
    required String fileName,
  }) async {
    if (localPath != null && localPath.isNotEmpty) {
      final file = File(localPath);
      if (await file.exists()) {
        return file;
      }
    }

    if (cloudUrl == null || cloudUrl.isEmpty) {
      return null;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final receiptsDir = Directory('${dir.path}/receipts');
      if (!await receiptsDir.exists()) {
        await receiptsDir.create(recursive: true);
      }

      final ext = p.extension(Uri.parse(cloudUrl).path);
      final cleanExt = ext.isNotEmpty ? ext : '.jpg';
      final newLocalPath = '${receiptsDir.path}/$fileName$cleanExt';
      final file = File(newLocalPath);

      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(cloudUrl));
      final response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        final List<int> bytes = await response.fold<List<int>>([], (p, e) => p..addAll(e));
        await file.writeAsBytes(bytes);
        return file;
      }
    } catch (_) {
      // Fail silently and return null
    }

    return null;
  }
}
