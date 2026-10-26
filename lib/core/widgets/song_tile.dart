import 'package:flutter/material.dart';

import '../../domain/entities/song.dart';
import '../theme/app_colors.dart';
import 'album_art.dart';

class SongTile extends StatelessWidget {
  const SongTile({
    super.key,
    required this.song,
    this.trailing,
    this.onTap,
    this.dense = false,
  });

  final Song song;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: AlbumArt(
        imageUrl: song.albumArtUrl,
        size: dense ? 48 : 56,
        borderRadius: dense ? 12 : 14,
        emptyUrlIcon: song.isVideo
            ? Icons.movie_outlined
            : Icons.audio_file_rounded,
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        song.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
      trailing: trailing,
    );
  }
}
