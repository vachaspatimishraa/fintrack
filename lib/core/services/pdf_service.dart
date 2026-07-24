import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../features/transactions/domain/entities/transaction_entity.dart';
import '../utils/formatter.dart';

class PdfService {
  Future<void> exportTransactions(
    List<TransactionEntity> transactions,
    String title,
  ) async {
    final pdf = pw.Document();

    // Load logo from assets
    final logoData = await rootBundle.load('assets/images/logo.png');
    final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

    // 1. Load Unicode Font for Hindi support
    pw.Font? regularFont;
    pw.Font? boldFont;

    try {
      // These must be added to assets/fonts and pubspec.yaml by the user
      final fontData = await rootBundle.load('assets/fonts/NotoSansDevanagari-Regular.ttf');
      regularFont = pw.Font.ttf(fontData);
      
      final boldFontData = await rootBundle.load('assets/fonts/NotoSansDevanagari-Bold.ttf');
      boldFont = pw.Font.ttf(boldFontData);
    } catch (e) {
      // Log warning instead of crashing if font is missing
      debugPrint('Warning: Unicode font (NotoSansDevanagari) could not be loaded. Hindi characters may not render correctly. Error: $e');
    }

    final baseStyle = pw.TextStyle(font: regularFont, fontSize: 10);
    final headerStyle = pw.TextStyle(font: boldFont ?? regularFont, fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10);

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
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(
          base: regularFont,
          bold: boldFont,
        ),
        build: (context) => [
          // Header
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
                        font: boldFont ?? regularFont,
                      ),
                    ),
                  ],
                ),
                pw.Text(
                  'Generated: ${AppFormatter.formatDate(DateTime.now())}',
                  style: baseStyle,
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 10),
          
          // Title
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 18, 
              fontWeight: pw.FontWeight.bold, 
              font: boldFont ?? regularFont,
            ),
          ),
          pw.SizedBox(height: 20),
          
          // Summary Cards
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryCard('Total Income', totalIncome, PdfColors.green800, regularFont, boldFont),
              _buildSummaryCard('Total Expense', totalExpense, PdfColors.red800, regularFont, boldFont),
              _buildSummaryCard('Net Balance', totalIncome - totalExpense, PdfColors.blue800, regularFont, boldFont),
            ],
          ),
          pw.SizedBox(height: 25),
          
          // Transactions Table (Manual implementation to support colors)
          pw.Table(
            border: const pw.TableBorder(
              bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
              horizontalInside: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
            ),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(3),
              3: const pw.FlexColumnWidth(1.5),
              4: const pw.FlexColumnWidth(1.5),
            },
            children: [
              // Header Row
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.indigo),
                children: [
                  _buildTableCell('Date', headerStyle, isHeader: true),
                  _buildTableCell('Category', headerStyle, isHeader: true),
                  _buildTableCell('Title', headerStyle, isHeader: true),
                  _buildTableCell('Cash In', headerStyle, isHeader: true, align: pw.Alignment.centerRight),
                  _buildTableCell('Cash Out', headerStyle, isHeader: true, align: pw.Alignment.centerRight),
                ],
              ),
              // Data Rows
              ...transactions.map((tx) {
                final isIncome = tx.type == 'income';
                final amountStr = _formatAmountOnly(tx.amount);
                
                return pw.TableRow(
                  children: [
                    _buildTableCell(AppFormatter.formatDate(tx.date), baseStyle),
                    _buildTableCell(tx.category, baseStyle),
                    _buildTableCell(
                      tx.title.isNotEmpty ? tx.title : (tx.description.isNotEmpty ? tx.description : 'UPI'),
                      baseStyle,
                    ),
                    _buildTableCell(
                      isIncome ? amountStr : '',
                      pw.TextStyle(font: boldFont ?? regularFont, color: PdfColors.green, fontWeight: pw.FontWeight.bold, fontSize: 10),
                      align: pw.Alignment.centerRight,
                    ),
                    _buildTableCell(
                      !isIncome ? amountStr : '',
                      pw.TextStyle(font: boldFont ?? regularFont, color: PdfColors.red, fontWeight: pw.FontWeight.bold, fontSize: 10),
                      align: pw.Alignment.centerRight,
                    ),
                  ],
                );
              }),
            ],
          ),
          
          // Footer
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 20),
            child: pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Financial statement generated via FinTrack App',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500, font: regularFont),
              ),
            ),
          ),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final fileName = 'fintrack_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'My FinTrack Financial Report');
  }

  static pw.Widget _buildTableCell(String text, pw.TextStyle style, {bool isHeader = false, pw.Alignment align = pw.Alignment.centerLeft}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Container(
        alignment: align,
        child: pw.Text(text, style: style),
      ),
    );
  }

  static String _formatAmountOnly(double amount) {
    // Return numeric value only, no currency symbol
    return amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2);
  }

  static pw.Widget _buildSummaryCard(
    String label,
    double amount,
    PdfColor color,
    pw.Font? regularFont,
    pw.Font? boldFont,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      width: 150,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600, font: regularFont),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            _formatAmountOnly(amount),
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: color,
              font: boldFont ?? regularFont,
            ),
          ),
        ],
      ),
    );
  }
}
