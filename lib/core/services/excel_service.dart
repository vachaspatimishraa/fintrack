import 'dart:io';
import 'package:excel/excel.dart' as xl;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../features/transactions/domain/entities/transaction_entity.dart';
import '../utils/formatter.dart';

class ExcelService {
  Future<void> exportTransactions(List<TransactionEntity> transactions) async {
    final excel = xl.Excel.createExcel();
    final sheet = excel['Sheet1'];

    sheet.appendRow([
      xl.TextCellValue('Date'),
      xl.TextCellValue('Category'),
      xl.TextCellValue('Description'),
      xl.TextCellValue('Type'),
      xl.TextCellValue('Amount'),
    ]);

    for (final tx in transactions) {
      sheet.appendRow([
        xl.TextCellValue(AppFormatter.formatDate(tx.date)),
        xl.TextCellValue(tx.category),
        xl.TextCellValue(tx.description),
        xl.TextCellValue(tx.type.toUpperCase()),
        xl.DoubleCellValue(tx.amount),
      ]);
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/fintrack_report_${DateTime.now().millisecondsSinceEpoch}.xlsx');
    final bytes = excel.encode();
    if (bytes != null) {
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)], text: 'My FinTrack Excel Report');
    }
  }
}
