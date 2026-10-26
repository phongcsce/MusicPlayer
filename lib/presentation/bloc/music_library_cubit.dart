import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/playlist.dart';
import '../../domain/entities/song.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/music_library_repository.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';

class MusicLibraryState extends Equatable {
  const MusicLibraryState({
    required this.user,
    required this.recentlyPlayed,
    required this.recommended,
    required this.trending,
    required this.allSongs,
    required this.favorites,
    required this.playlists,
    required this.recentSearches,
    required this.genres,
  });

  final UserProfile user;
  final List<Song> recentlyPlayed;
  final List<Song> recommended;
  final List<Song> trending;
  final List<Song> allSongs;
  final List<Song> favorites;
  final List<Playlist> playlists;
  final List<String> recentSearches;
  final List<String> genres;

  MusicLibraryState copyWith({
    UserProfile? user,
    List<Song>? recentlyPlayed,
    List<Song>? recommended,
    List<Song>? trending,
    List<Song>? allSongs,
    List<Song>? favorites,
    List<Playlist>? playlists,
    List<String>? recentSearches,
    List<String>? genres,
  }) {
    return MusicLibraryState(
      user: user ?? this.user,
      recentlyPlayed: recentlyPlayed ?? this.recentlyPlayed,
      recommended: recommended ?? this.recommended,
      trending: trending ?? this.trending,
      allSongs: allSongs ?? this.allSongs,
      favorites: favorites ?? this.favorites,
      playlists: playlists ?? this.playlists,
      recentSearches: recentSearches ?? this.recentSearches,
      genres: genres ?? this.genres,
    );
  }

  @override
  List<Object?> get props => [
        user,
        recentlyPlayed,
        recommended,
        trending,
        allSongs,
        favorites,
        playlists,
        recentSearches,
        genres,
      ];
}

MusicLibraryState _librarySnapshot(MusicLibraryRepository r) {
  return MusicLibraryState(
    user: r.getCurrentUser(),
    recentlyPlayed: r.getRecentlyPlayed(),
    recommended: r.getRecommended(),
    trending: r.getTrending(),
    allSongs: r.getAllSongs(),
    favorites: r.getFavoriteSongs(),
    playlists: r.getUserPlaylists(),
    recentSearches: r.getRecentSearchQueries(),
    genres: r.getGenreTags(),
  );
}

class MusicLibraryCubit extends Cubit<MusicLibraryState> {
  MusicLibraryCubit(MusicLibraryRepository library, this._toggleFavorite)
      : _library = library,
        super(_librarySnapshot(library));

  final MusicLibraryRepository _library;
  final ToggleFavoriteUseCase _toggleFavorite;

  void refresh() => emit(_librarySnapshot(_library));

  List<Song> searchCatalog(String query) => _library.searchSongs(query);

  Future<void> addRecentSearch(String query) async {
    await _library.addRecentSearch(query);
    refresh();
  }

  Future<void> toggleFavorite(String songId) async {
    await _toggleFavorite(songId);
    refresh();
  }
}
