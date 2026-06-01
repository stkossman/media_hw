import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.onAddPhoto,
  });

  final VoidCallback onAddPhoto;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.photo_library_outlined,
              size: 100,
              color: Colors.black26,
            ),
            const SizedBox(height: 16),
            Text(
              'NO PHOTOS YET',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add your first photo',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAddPhoto,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('ADD PHOTO'),
            ),
          ],
        ),
      ),
    );
  }
}
