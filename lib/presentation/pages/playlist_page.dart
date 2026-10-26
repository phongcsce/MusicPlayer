import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/song_tile.dart';
import '../../domain/entities/playlist.dart';
import '../../domain/entities/song.dart';
import '../bloc/music_library_cubit.dart';
import '../bloc/player_cubit.dart';

class PlaylistPage extends StatelessWidget {
  const PlaylistPage({super.key});

  static List<Song> _songsFor(Playlist p, List<Song> all) {
    final out = <Song>[];
    for (final id in p.songIds) {
      for (final s in all) {
        if (s.id == id) {
          out.add(s);
          break;
        }
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'My Playlist',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TabBar(
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: AppColors.accentGradient,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: 'Songs'),
                  Tab(text: 'Albums'),
                  Tab(text: 'Artists'),
                  Tab(text: 'Playlists'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BlocBuilder<MusicLibraryCubit, MusicLibraryState>(
              builder: (context, st) {
                return TabBarView(
                  children: [
                    _SongsTab(state: st),
                    _AlbumsTab(allSongs: st.allSongs),
                    _ArtistsTab(allSongs: st.allSongs),
                    _PlaylistsTab(state: st),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SongsTab extends StatelessWidget {
  const _SongsTab({required this.state});

  final MusicLibraryState state;

  @override
  Widget build(BuildContext context) {
    final featured = state.playlists.isNotEmpty ? state.playlists.first : null;
    return CustomScrollView(
      slivers: [
        if (featured != null)
          SliverToBoxAdapter(
            child: _FeaturedPlaylistCard(playlist: featured, state: state),
          ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              final s = state.allSongs[i];
              return SongTile(
                song: s,
                onTap: () => context.read<PlayerCubit>().play(s),
                trailing: IconButton(
                  icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                  onPressed: () {},
                ),
              );
            },
            childCount: state.allSongs.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }
}

class _FeaturedPlaylistCard extends StatelessWidget {
  const _FeaturedPlaylistCard({
    required this.playlist,
    required this.state,
  });

  final Playlist playlist;
  final MusicLibraryState state;

  @override
  Widget build(BuildContext context) {
    final songs = PlaylistPage._songsFor(playlist, state.allSongs);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: NetworkImage(playlist.coverUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.55),
              BlendMode.darken,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              playlist.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Created by ${playlist.ownerName}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accentPurple,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: songs.isEmpty
                  ? null
                  : () => context.read<PlayerCubit>().playQueue(
                        songs,
                        startIndex: 0,
                      ),
              icon: const Icon(Icons.shuffle_rounded),
              label: const Text('Shuffle Play'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlbumsTab extends StatelessWidget {
  const _AlbumsTab({required this.allSongs});

  final List<Song> allSongs;

  @override
  Widget build(BuildContext context) {
    final byArtist = <String, Song>{};
    for (final s in allSongs) {
      byArtist.putIfAbsent(s.artist, () => s);
    }
    final entries = byArtist.entries.toList();
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.85,
      ),
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final e = entries[i];
        return InkWell(
          onTap: () => context.read<PlayerCubit>().play(e.value),
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    e.value.albumArtUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.surfaceElevated,
                      alignment: Alignment.center,
                      child: const Icon(Icons.album, color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                e.key,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ArtistsTab extends StatelessWidget {
  const _ArtistsTab({required this.allSongs});

  final List<Song> allSongs;

  @override
  Widget build(BuildContext context) {
    final names = allSongs.map((s) => s.artist).toSet().toList()..sort();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      itemCount: names.length,
      itemBuilder: (context, i) {
        final name = names[i];
        final song = allSongs.firstWhere((s) => s.artist == name);
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            radius: 26,
            backgroundImage: NetworkImage(song.albumArtUrl),
          ),
          title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () => context.read<PlayerCubit>().play(song),
        );
      },
    );
  }
}

class _PlaylistsTab extends StatelessWidget {
  const _PlaylistsTab({required this.state});

  final MusicLibraryState state;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      itemCount: state.playlists.length,
      itemBuilder: (context, i) {
        final p = state.playlists[i];
        final songs = PlaylistPage._songsFor(p, state.allSongs);
        return Card(
          color: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                p.coverUrl,
                width: 52,
                height: 52,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(p.name),
            subtitle: Text('${songs.length} tracks · ${p.ownerName}'),
            trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            onTap: songs.isEmpty
                ? null
                : () =>
                    context.read<PlayerCubit>().playQueue(songs, startIndex: 0),
          ),
        );
      },
    );
  }
}
