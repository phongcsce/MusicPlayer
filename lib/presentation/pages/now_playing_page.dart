import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/duration_format.dart';
import '../../core/widgets/album_art.dart';
import '../../data/services/hybrid_playback_controller.dart';
import '../../domain/entities/song.dart';
import '../../domain/services/playback_controller.dart';
import '../bloc/music_library_cubit.dart';
import '../bloc/player_cubit.dart';

class NowPlayingPage extends StatelessWidget {
  const NowPlayingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A1030),
                AppColors.background,
              ],
            ),
          ),
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _toast(context, 'More options'),
                  ),
                ],
              ),
              Expanded(
                child: BlocBuilder<PlayerCubit, PlayerUiState>(
                  builder: (context, ps) {
                    final song = ps.current;
                    if (song == null) {
                      return const Center(
                        child: Text(
                          'Nothing playing',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          _NowPlayingArtwork(song: song),
                          const SizedBox(height: 28),
                          Text(
                            song.title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            song.artist,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Row(
                            children: [
                              Text(
                                formatPlayerDuration(ps.position),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 4,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 8,
                                    ),
                                    overlayShape: SliderComponentShape.noOverlay,
                                    activeTrackColor: AppColors.accentPurple,
                                    inactiveTrackColor:
                                        AppColors.surfaceElevated,
                                    thumbColor: Colors.white,
                                  ),
                                  child: Slider(
                                    value: _sliderValue(ps),
                                    onChanged: (v) {
                                      final total = ps.duration ?? song.duration;
                                      context.read<PlayerCubit>().seek(
                                            Duration(
                                              milliseconds: (v *
                                                      total.inMilliseconds)
                                                  .round(),
                                            ),
                                          );
                                    },
                                  ),
                                ),
                              ),
                              Text(
                                formatPlayerDuration(
                                    ps.duration ?? song.duration),
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () => context
                                    .read<PlayerCubit>()
                                    .toggleShuffle(),
                                icon: Icon(
                                  Icons.shuffle,
                                  color: ps.shuffle
                                      ? AppColors.accentPurple
                                      : AppColors.textSecondary,
                                ),
                              ),
                              IconButton(
                                iconSize: 36,
                                onPressed: () =>
                                    context.read<PlayerCubit>().previous(),
                                icon: const Icon(Icons.skip_previous_rounded),
                              ),
                              const SizedBox(width: 12),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppColors.accentGradient,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accentPurple
                                          .withValues(alpha: 0.45),
                                      blurRadius: 24,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  iconSize: 44,
                                  onPressed: () => context
                                      .read<PlayerCubit>()
                                      .togglePlayPause(),
                                  icon: Icon(
                                    ps.playing
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                iconSize: 36,
                                onPressed: () =>
                                    context.read<PlayerCubit>().next(),
                                icon: const Icon(Icons.skip_next_rounded),
                              ),
                              IconButton(
                                onPressed: () =>
                                    context.read<PlayerCubit>().cycleRepeat(),
                                icon: Icon(
                                  _repeatIcon(ps.repeat),
                                  color: ps.repeat != RepeatMode.off
                                      ? AppColors.accentPurple
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _utility(
                                context,
                                Icons.timer_outlined,
                                'Sleep',
                                () => _toast(context, 'Sleep timer'),
                              ),
                              _favoriteButton(context, song),
                              _utility(
                                context,
                                Icons.download_outlined,
                                'Download',
                                () => _toast(context, 'Download'),
                              ),
                              _utility(
                                context,
                                Icons.playlist_add,
                                'Playlist',
                                () => _toast(context, 'Add to playlist'),
                              ),
                              _utility(
                                context,
                                Icons.volume_up_outlined,
                                'Volume',
                                () => _toast(context, 'Volume'),
                              ),
                            ],
                          ),
                          const Spacer(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static double _sliderValue(PlayerUiState ps) {
    final total = ps.duration ?? ps.current?.duration;
    if (total == null || total.inMilliseconds <= 0) return 0;
    return (ps.position.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
  }

  static IconData _repeatIcon(RepeatMode m) {
    return switch (m) {
      RepeatMode.one => Icons.repeat_one,
      _ => Icons.repeat,
    };
  }

  static Widget _favoriteButton(BuildContext context, Song song) {
    return BlocBuilder<MusicLibraryCubit, MusicLibraryState>(
      builder: (context, lib) {
        final resolved = lib.allSongs.firstWhere(
          (s) => s.id == song.id,
          orElse: () => song,
        );
        final fav = resolved.isFavorite;
        return _utility(
          context,
          fav ? Icons.favorite : Icons.favorite_border,
          'Like',
          () => context.read<MusicLibraryCubit>().toggleFavorite(song.id),
          active: fav,
        );
      },
    );
  }

  static Widget _utility(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool active = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Icon(
              icon,
              color: active ? AppColors.accentPurple : AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  static void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _NowPlayingArtwork extends StatelessWidget {
  const _NowPlayingArtwork({required this.song});

  final Song song;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width - 48;
    if (!song.isVideo) {
      return AlbumArt(
        imageUrl: song.albumArtUrl,
        size: w,
        borderRadius: 28,
        emptyUrlIcon: Icons.audio_file_rounded,
      );
    }
    final hybrid = context.read<HybridPlaybackController>();
    return ListenableBuilder(
      listenable: hybrid.videoSurface,
      builder: (context, _) {
        final vc = hybrid.videoSurface.value;
        if (vc == null || !vc.value.isInitialized) {
          return SizedBox(
            width: w,
            height: w * 9 / 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: const ColoredBox(
                color: AppColors.surfaceElevated,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          );
        }
        final ar = vc.value.aspectRatio;
        final clamped =
            ar.isFinite && ar > 0 ? ar.clamp(0.5, 2.5) : 16 / 9;
        return ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: SizedBox(
            width: w,
            child: AspectRatio(
              aspectRatio: clamped,
              child: VideoPlayer(vc),
            ),
          ),
        );
      },
    );
  }
}
