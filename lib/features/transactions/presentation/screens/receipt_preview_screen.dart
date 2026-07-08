import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/database/isar/collections/receipt_model.dart';
import '../controllers/receipt_controller.dart';
import '../widgets/receipt_picker_bottom_sheet.dart';

class ReceiptPreviewScreen extends ConsumerStatefulWidget {
  final ReceiptModel receipt;

  const ReceiptPreviewScreen({super.key, required this.receipt});

  @override
  ConsumerState<ReceiptPreviewScreen> createState() => _ReceiptPreviewScreenState();
}

class _ReceiptPreviewScreenState extends ConsumerState<ReceiptPreviewScreen> {
  late ReceiptModel _receipt;

  @override
  void initState() {
    super.initState();
    _receipt = widget.receipt;
  }

  void _handleShare() {
    Share.shareXFiles([XFile(_receipt.localPath)]);
  }

  void _handleReplace() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ReceiptPickerBottomSheet(
          onFilePicked: (file) async {
            final controller = ref.read(receiptControllerProvider);
            try {
              // Delete original
              await controller.deleteReceipt(_receipt.uuid);
              // Attach new
              final newReceipt = await controller.attachReceipt(_receipt.transactionId, file);
              setState(() {
                _receipt = newReceipt;
              });
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Replace error: $e')),
                );
              }
            }
          },
        );
      },
    );
  }

  void _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Attachment?'),
        content: const Text('Are you sure you want to permanently delete this receipt?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(receiptControllerProvider).deleteReceipt(_receipt.uuid);
      if (mounted) {
        Navigator.pop(context, true); // return signal that it was deleted
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageFile = File(_receipt.localPath);
    final imageProvider = imageFile.existsSync()
        ? FileImage(imageFile)
        : (_receipt.cloudUrl != null
            ? NetworkImage(_receipt.cloudUrl!)
            : const Icon(Icons.image_not_supported) as ImageProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _handleShare,
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _handleReplace,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _handleDelete,
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          maxScale: 4.0,
          child: Image(
            image: imageProvider,
            errorBuilder: (context, error, stackTrace) => const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, color: Colors.white, size: 64),
                SizedBox(height: 12),
                Text('Unable to load receipt image file.', style: TextStyle(color: Colors.white)),
              ],
            ),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
