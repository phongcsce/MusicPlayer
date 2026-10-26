import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/song_tile.dart';
import '../bloc/music_library_cubit.dart';
import '../bloc/player_cubit.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicLibraryCubit, MusicLibraryState>(
      builder: (context, state) {
        if (state.favorites.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No favorites yet.\nTap the heart on any track to save it here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, height: 1.4),
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          itemCount: state.favorites.length,
          itemBuilder: (context, i) {
            final s = state.favorites[i];
            return SongTile(
              song: s,
              onTap: () => context.read<PlayerCubit>().play(s),
              trailing: IconButton(
                icon: const Icon(Icons.favorite, color: AppColors.accentPurple),
                onPressed: () =>
                    context.read<MusicLibraryCubit>().toggleFavorite(s.id),
              ),
            );
          },
        );
      },
    );
  }
}
