import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/category_chip.dart';
import '../../core/widgets/song_tile.dart';
import '../../domain/entities/song.dart';
import '../bloc/local_media_cubit.dart';
import '../bloc/music_library_cubit.dart';
import '../bloc/player_cubit.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Song> _mergedResults(MusicLibraryCubit catalog, List<Song> local) {
    final t = _query.trim().toLowerCase();
    if (t.isEmpty) return [];
    final fromRemote = catalog.searchCatalog(_query);
    final fromLocal = local
        .where(
          (s) =>
              s.title.toLowerCase().contains(t) ||
              s.artist.toLowerCase().contains(t),
        )
        .toList();
    final ids = <String>{};
    final out = <Song>[];
    for (final s in [...fromLocal, ...fromRemote]) {
      if (ids.add(s.id)) out.add(s);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.read<MusicLibraryCubit>();
    return BlocBuilder<LocalMediaCubit, LocalMediaState>(
      builder: (context, lm) {
        final results = _mergedResults(catalog, lm.items);
        return BlocListener<MusicLibraryCubit, MusicLibraryState>(
      listenWhen: (p, c) => p.recentSearches != c.recentSearches,
      listener: (_, __) => setState(() {}),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: TextField(
                controller: _controller,
                onChanged: (v) => setState(() => _query = v),
                onSubmitted: (v) =>
                    context.read<MusicLibraryCubit>().addRecentSearch(v),
                decoration: InputDecoration(
                  hintText: 'Search artists, songs, albums',
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.textSecondary),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.mic_none_rounded),
                    color: AppColors.textSecondary,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Voice search (demo)')),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 0, 8),
              child: Text(
                'Recent Searches',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: BlocBuilder<MusicLibraryCubit, MusicLibraryState>(
              builder: (context, st) {
                return SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: st.recentSearches.length,
                    itemBuilder: (context, i) {
                      final q = st.recentSearches[i];
                      return CategoryChip(
                        label: q,
                        onTap: () {
                          _controller.text = q;
                          setState(() => _query = q);
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 0, 8),
              child: Text(
                'Browse by Genre',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: BlocBuilder<MusicLibraryCubit, MusicLibraryState>(
              builder: (context, st) {
                return SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: st.genres.length,
                    itemBuilder: (context, i) {
                      final g = st.genres[i];
                      return CategoryChip(
                        label: g,
                        onTap: () {
                          _controller.text = g;
                          setState(() => _query = g);
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
          if (_query.trim().isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Text(
                  'Top Results',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final song = results[i];
                  return BlocBuilder<MusicLibraryCubit, MusicLibraryState>(
                    buildWhen: (p, c) => p.allSongs != c.allSongs,
                    builder: (context, lib) {
                      final resolved = lib.allSongs.firstWhere(
                        (s) => s.id == song.id,
                        orElse: () => song,
                      );
                      return SongTile(
                        song: resolved,
                        dense: true,
                        onTap: () =>
                            context.read<PlayerCubit>().play(resolved),
                        trailing: IconButton(
                          icon: Icon(
                            resolved.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: resolved.isFavorite
                                ? AppColors.accentPurple
                                : AppColors.textSecondary,
                          ),
                          onPressed: () => context
                              .read<MusicLibraryCubit>()
                              .toggleFavorite(resolved.id),
                        ),
                      );
                    },
                  );
                },
                childCount: results.length,
              ),
            ),
          ] else
            const SliverToBoxAdapter(child: SizedBox.shrink()),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
      },
    );
  }
}
