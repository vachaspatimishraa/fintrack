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
    // We try to load regular and bold versions for better rendering
    pw.Font? regularFont;
    pw.Font? boldFont;

    try {
      final fontData = await rootBundle.load('assets/fonts/NotoSansDevanagari-Regular.ttf');
      regularFont = pw.Font.ttf(fontData);
      
      final boldFontData = await rootBundle.load('assets/fonts/NotoSansDevanagari-Bold.ttf');
      boldFont = pw.Font.ttf(boldFontData);
    } catch (e) {
      debugPrint('Warning: Could not load custom Unicode font. Hindi text might not render correctly: $e');
      // Fallback is handled by the PDF library defaults, which don't support Hindi.
      // Ideally, the font must be present in assets/fonts/
    }

    // Define text styles using the loaded font
    final baseStyle = pw.TextStyle(font: regularFont);

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
                        font: boldFont,
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
              font: boldFont,
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
          
          // Transactions Table
          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Category', 'Title', 'Type', 'Amount'],
            data: transactions.map((tx) {
              return [
                AppFormatter.formatDate(tx.date),
                tx.category,
                tx.title.isNotEmpty ? tx.title : (tx.description.isNotEmpty ? tx.description : 'UPI'),
                tx.type.toUpperCase(),
                _formatAmountWithSymbol(tx.amount, tx.type == 'income'),
              ];
            }).toList(),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
              font: boldFont,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo),
            cellStyle: baseStyle,
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {4: pw.Alignment.centerRight},
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

  static String _formatAmountWithSymbol(double amount, bool isIncome) {
    final symbol = isIncome ? '+' : '-';
    // Use AppFormatter for currency formatting if it supports Hindi characters like ₹
    // If not, we just use the number and assume the font handles the glyph.
    return '$symbol ${AppFormatter.formatCurrency(amount)}';
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
            AppFormatter.formatCurrency(amount),
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: color,
              font: boldFont,
            ),
          ),
        ],
      ),
    );
  }
}
