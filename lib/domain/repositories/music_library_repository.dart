import '../entities/playlist.dart';
import '../entities/song.dart';
import '../entities/user_profile.dart';

abstract class MusicLibraryRepository {
  UserProfile getCurrentUser();
  List<Song> getRecentlyPlayed();
  List<Song> getRecommended();
  List<Song> getTrending();
  List<Song> getAllSongs();
  List<Song> getFavoriteSongs();
  List<String> getRecentSearchQueries();
  List<String> getGenreTags();
  List<Song> searchSongs(String query);
  List<Playlist> getUserPlaylists();
  Song? getSongById(String id);
  Future<void> toggleFavorite(String songId);
  Future<void> addRecentSearch(String query);
}
