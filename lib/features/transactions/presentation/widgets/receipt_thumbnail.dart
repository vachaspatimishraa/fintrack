import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/database/isar/collections/receipt_model.dart';
import '../screens/receipt_preview_screen.dart';

class ReceiptThumbnail extends StatelessWidget {
  final ReceiptModel receipt;
  final VoidCallback? onDeleted;

  const ReceiptThumbnail({super.key, required this.receipt, this.onDeleted});

  @override
  Widget build(BuildContext context) {
    final file = File(receipt.localPath);
    final ImageProvider? imageProvider = file.existsSync()
        ? FileImage(file)
        : (receipt.cloudUrl != null
            ? NetworkImage(receipt.cloudUrl!)
            : null);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReceiptPreviewScreen(receipt: receipt),
          ),
        ).then((wasDeleted) {
          if (wasDeleted == true && onDeleted != null) {
            onDeleted!();
          }
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 80,
          height: 80,
          color: Colors.grey.shade200,
          child: imageProvider != null
              ? Image(
                  image: imageProvider,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  ),
                )
              : const Center(
                  child: Icon(Icons.attach_file, color: Colors.grey),
                ),
        ),
      ),
    );
  }
}
