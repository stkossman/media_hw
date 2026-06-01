import 'dart:io';

import 'package:flutter/material.dart';

class ImageGridItem extends StatelessWidget {
  const ImageGridItem({
    super.key,
    required this.imagePath,
    required this.index,
    required this.isSelected,
    required this.selectionMode,
    required this.onTap,
    required this.onLongPress,
  });

  final String imagePath;
  final int index;
  final bool isSelected;
  final bool selectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'photo_$index',
              child: Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                cacheWidth: 300,
              ),
            ),
            if (selectionMode) ...[
              ColoredBox(
                color: isSelected ? Colors.black26 : Colors.black54,
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (!isSelected)
                      const Icon(
                        Icons.circle,
                        color: Colors.black,
                        size: 29,
                      ),
                    Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: isSelected ? Colors.black : Colors.white,
                      size: 30,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
