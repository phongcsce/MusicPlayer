import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/album_art.dart';
import '../../domain/entities/song.dart';
import '../bloc/local_media_cubit.dart';
import '../bloc/music_library_cubit.dart';
import '../bloc/player_cubit.dart';
import '../utils/media_file_picker.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onOpenSearch});

  final VoidCallback onOpenSearch;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicLibraryCubit, MusicLibraryState>(
      builder: (context, state) {
        return BlocBuilder<LocalMediaCubit, LocalMediaState>(
          builder: (context, local) {
            return CustomScrollView(
              slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${state.user.displayName},',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'What do you want to hear?',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    ClipOval(
                      child: Image.network(
                        state.user.avatarUrl,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 52,
                          height: 52,
                          color: AppColors.surfaceElevated,
                          child: const Icon(Icons.person, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: onOpenSearch,
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search songs, artists...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.textSecondary,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceElevated,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            _deviceSectionHeader(context, local.busy),
            if (local.items.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Import or open audio/video from your device using the buttons above.',
                    style: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.9),
                      height: 1.35,
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final s = local.items[i];
                    return ListTile(
                      leading: AlbumArt(
                        imageUrl: s.albumArtUrl,
                        size: 48,
                        borderRadius: 12,
                        emptyUrlIcon: s.isVideo
                            ? Icons.movie_outlined
                            : Icons.audio_file_rounded,
                      ),
                      title: Text(
                        s.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        s.isVideo ? 'Video · On device' : 'Audio · On device',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      onTap: () => context.read<PlayerCubit>().play(s),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        color: AppColors.textSecondary,
                        onPressed: () =>
                            context.read<LocalMediaCubit>().remove(s.id),
                      ),
                    );
                  },
                  childCount: local.items.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            _sectionTitle('Recently Played'),
            _horizontalSongs(context, state.recentlyPlayed),
            _sectionTitle('Recommended For You'),
            _horizontalSongs(context, state.recommended),
            _sectionTitle('Trending Now'),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: state.trending.isEmpty
                    ? const SizedBox.shrink()
                    : _TrendingCard(song: state.trending.first),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        );
          },
        );
      },
    );
  }

  static Widget _deviceSectionHeader(BuildContext context, bool busy) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 12, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'On this device',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Open to play once, or import to keep in this list.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (busy)
              const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Play file (not saved)',
                    onPressed: () => _pickAndOpen(context),
                    icon: const Icon(Icons.play_circle_outline_rounded),
                  ),
                  IconButton(
                    tooltip: 'Import to library',
                    onPressed: () => _pickAndImport(context),
                    icon: const Icon(Icons.library_add_rounded),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  static Future<void> _pickAndOpen(BuildContext context) async {
    final list = await pickDeviceMediaFiles();
    if (!context.mounted || list.isEmpty) return;
    await context.read<PlayerCubit>().playQueue(list);
  }

  static Future<void> _pickAndImport(BuildContext context) async {
    final list = await pickDeviceMediaFiles();
    if (!context.mounted || list.isEmpty) return;
    await context.read<LocalMediaCubit>().importTracks(list);
    if (!context.mounted) return;
    await context.read<PlayerCubit>().play(list.first);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${list.length} file(s) added to this device list')),
    );
  }

  static Widget _sectionTitle(String t) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Text(
          t,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  static Widget _horizontalSongs(BuildContext context, List<Song> songs) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 168,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          itemCount: songs.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (context, i) {
            final s = songs[i];
            return SizedBox(
              width: 112,
              child: InkWell(
                onTap: () => context.read<PlayerCubit>().play(s),
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AlbumArt(
                      imageUrl: s.albumArtUrl,
                      size: 112,
                      borderRadius: 18,
                      emptyUrlIcon: s.isVideo
                          ? Icons.movie_outlined
                          : Icons.music_note_rounded,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      s.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  const _TrendingCard({required this.song});

  final Song song;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            AppColors.surfaceElevated,
            AppColors.accentPurple.withValues(alpha: 0.2),
          ],
        ),
        border: Border.all(color: const Color(0x22FFFFFF)),
      ),
      child: Row(
        children: [
          AlbumArt(imageUrl: song.albumArtUrl, size: 72, borderRadius: 16),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  song.artist,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          DecoratedBox(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.accentGradient,
            ),
            child: IconButton(
              onPressed: () => context.read<PlayerCubit>().play(song),
              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
