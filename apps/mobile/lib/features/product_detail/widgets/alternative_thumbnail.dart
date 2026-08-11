import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Square product image with a graceful placeholder while loading or on error.
/// Shared by the recommendation card and the bottom-sheet row.
class AlternativeThumbnail extends StatelessWidget {
  const AlternativeThumbnail({
    super.key,
    required this.imageUrl,
    required this.size,
  });

  final String imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: size,
        height: size,
        child: imageUrl.isEmpty
            ? _placeholder()
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return _placeholder();
                },
                errorBuilder: (context, error, stackTrace) => _placeholder(),
              ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.surfaceMuted,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_outlined,
        size: size * 0.4,
        color: AppColors.textSecondary,
      ),
    );
  }
}
