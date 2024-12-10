import 'dart:io';
import 'package:flutter/material.dart';

class PhotoSectionWidget extends StatelessWidget {
  final List<File> selectedPhotos;
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;
  final void Function(int) onPhotoRemoved;

  const PhotoSectionWidget({
    super.key,
    required this.selectedPhotos,
    required this.onCameraPressed,
    required this.onGalleryPressed,
    required this.onPhotoRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos (optional)',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...selectedPhotos.asMap().entries.map((entry) {
                final index = entry.key;
                final photo = entry.value;
                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Image.file(
                        photo,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.red, size: 20),
                        onPressed: () => onPhotoRemoved(index),
                      ),
                    ),
                  ],
                );
              }),
              if (selectedPhotos.length < 3)
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.camera_alt),
                        onPressed: onCameraPressed,
                      ),
                      IconButton(
                        icon: const Icon(Icons.photo_library),
                        onPressed: onGalleryPressed,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
