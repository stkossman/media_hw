import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class PhotoDetailScreen extends StatelessWidget {
  const PhotoDetailScreen({
    super.key,
    required this.imagePath,
    required this.index,
    required this.onDelete,
  });

  final String imagePath;
  final int index;
  final VoidCallback onDelete;

  Future<void> _sharePhoto() async {
    final file = File(imagePath);
    if (await file.exists()) {
      await Share.shareXFiles([XFile(imagePath)], text: 'Check out my photo!');
    }
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Photo?'),
          content: const Text('This photo will be removed from your gallery.'),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
                onDelete();
              },
              child: const Text('DELETE'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.share_rounded),
            onPressed: _sharePhoto,
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_rounded),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SizedBox.expand(
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Hero(
              tag: 'photo_$index',
              child: Image.file(
                File(imagePath),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
