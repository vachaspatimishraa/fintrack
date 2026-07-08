import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../features/transactions/domain/entities/transaction_entity.dart';
import '../utils/formatter.dart';

class PdfService {
  Future<void> exportTransactions(
      List<TransactionEntity> transactions, String title) async {
    final pdf = pw.Document();

    // Load logo from assets
    final logoData = await rootBundle.load('assets/images/logo.png');
    final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

    double totalIncome = 0;
    double totalExpense = 0;
    for (final tx in transactions) {
      if (tx.type == 'income') {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Row(
                  children: [
                    pw.Image(logoImage, width: 32, height: 32),
                    pw.SizedBox(width: 10),
                    pw.Text(
                      'FinTrack',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(0xFF4A56B8),
                      ),
                    ),
                  ],
                ),
                pw.Text('Generated: ${AppFormatter.formatDate(DateTime.now())}'),
              ],
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(title,
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryCard('Total Income', totalIncome, PdfColors.green800),
              _buildSummaryCard('Total Expense', totalExpense, PdfColors.red800),
              _buildSummaryCard('Net Balance', totalIncome - totalExpense, PdfColors.blue800),
            ],
          ),
          pw.SizedBox(height: 25),
          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Category', 'Description', 'Type', 'Amount'],
            data: transactions.map((tx) {
              return [
                AppFormatter.formatDate(tx.date),
                tx.category,
                tx.description,
                tx.type.toUpperCase(),
                AppFormatter.formatCurrency(tx.amount),
              ];
            }).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo),
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {4: pw.Alignment.centerRight},
          ),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/fintrack_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: 'My FinTrack Financial Report');
  }

  static pw.Widget _buildSummaryCard(String label, double amount, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
          pw.SizedBox(height: 4),
          pw.Text(AppFormatter.formatCurrency(amount),
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
