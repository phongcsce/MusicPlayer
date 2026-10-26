import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AlbumArt extends StatelessWidget {
  const AlbumArt({
    super.key,
    required this.imageUrl,
    this.size = 64,
    this.borderRadius = 16,
    this.emptyUrlIcon,
  });

  final String imageUrl;
  final double size;
  final double borderRadius;
  /// Shown when [imageUrl] is empty (e.g. local files).
  final IconData? emptyUrlIcon;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: SizedBox(
          width: size,
          height: size,
          child: ColoredBox(
            color: AppColors.surfaceElevated,
            child: Icon(
              emptyUrlIcon ?? Icons.music_note_rounded,
              color: AppColors.textSecondary,
              size: size * 0.45,
            ),
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: AppColors.surfaceElevated,
            child: const Icon(Icons.music_note, color: AppColors.textSecondary),
          ),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              color: AppColors.surfaceElevated,
              child: const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
