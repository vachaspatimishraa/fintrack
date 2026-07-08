import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/utils/camera_service.dart';
import '../../domain/utils/gallery_service.dart';

class ReceiptPickerBottomSheet extends StatelessWidget {
  final Function(File file) onFilePicked;
  final VoidCallback? onRemove;
  final bool hasReceipt;

  const ReceiptPickerBottomSheet({
    super.key,
    required this.onFilePicked,
    this.onRemove,
    this.hasReceipt = false,
  });

  @override
  Widget build(BuildContext context) {
    final camera = CameraService();
    final gallery = GalleryService();

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take Photo (Camera)'),
            onTap: () async {
              Navigator.pop(context);
              final file = await camera.capturePhoto();
              if (file != null) {
                onFilePicked(file);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Choose Image (Gallery)'),
            onTap: () async {
              Navigator.pop(context);
              final file = await gallery.pickImage();
              if (file != null) {
                onFilePicked(file);
              }
            },
          ),
          if (hasReceipt && onRemove != null)
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Remove Receipt',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                onRemove!();
              },
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
