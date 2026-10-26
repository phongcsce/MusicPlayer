import '../../domain/entities/playlist.dart';
import '../../domain/entities/song.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/music_library_repository.dart';
import '../datasources/music_local_datasource.dart';

class MusicLibraryRepositoryImpl implements MusicLibraryRepository {
  MusicLibraryRepositoryImpl(this._local);

  final MusicLocalDataSource _local;

  @override
  UserProfile getCurrentUser() => _local.user;

  @override
  List<Song> getRecentlyPlayed() =>
      _local.songs.take(6).map((s) => s).toList();

  @override
  List<Song> getRecommended() =>
      _local.songs.skip(1).take(6).map((s) => s).toList();

  @override
  List<Song> getTrending() => [_local.songs[1]];

  @override
  List<Song> getAllSongs() => _local.songs;

  @override
  List<Song> getFavoriteSongs() =>
      _local.songs.where((s) => s.isFavorite).toList();

  @override
  List<String> getRecentSearchQueries() => _local.recentSearches;

  @override
  List<String> getGenreTags() => _local.genres;

  @override
  List<Song> searchSongs(String query) => _local.search(query);

  @override
  List<Playlist> getUserPlaylists() => _local.playlists;

  @override
  Song? getSongById(String id) => _local.songById(id);

  @override
  Future<void> toggleFavorite(String songId) async {
    _local.toggleFavorite(songId);
  }

  @override
  Future<void> addRecentSearch(String query) async {
    _local.addRecentSearch(query);
  }
}
