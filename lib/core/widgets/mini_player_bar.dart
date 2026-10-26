import 'package:flutter/material.dart';

import '../../domain/entities/song.dart';
import '../theme/app_colors.dart';
import 'album_art.dart';

class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({
    super.key,
    required this.song,
    required this.playing,
    required this.onTap,
    required this.onPlayPause,
    required this.onNext,
  });

  final Song song;
  final bool playing;
  final VoidCallback onTap;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceElevated,
      elevation: 8,
      shadowColor: Colors.black54,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              AlbumArt(
                imageUrl: song.albumArtUrl,
                size: 48,
                borderRadius: 12,
                emptyUrlIcon:
                    song.isVideo ? Icons.movie_outlined : Icons.audio_file_rounded,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      song.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onPlayPause,
                icon: Icon(
                  playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: onNext,
                icon: const Icon(
                  Icons.skip_next_rounded,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
