import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack/features/transactions/domain/utils/image_validator.dart';
import 'package:fintrack/features/transactions/domain/utils/receipt_compression_service.dart';

void main() {
  group('Categories & Receipts Workflow Tests', () {
    late File dummyFile;

    setUp(() {
      dummyFile = File('dummy.jpg');
      dummyFile.writeAsStringSync('dummy content');
    });

    tearDown(() {
      if (dummyFile.existsSync()) {
        dummyFile.deleteSync();
      }
    });

    test('ImageValidator validates formats properly', () {
      final invalidPdf = File('test_receipt.pdf');
      expect(ImageValidator.validate(invalidPdf), contains('Format not supported'));
    });

    test('ReceiptCompressionService returns the file', () async {
      final result = await ReceiptCompressionService.compress(dummyFile);
      expect(result.path, equals(dummyFile.path));
    });
  });
}
