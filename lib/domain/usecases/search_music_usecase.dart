import '../entities/song.dart';
import '../repositories/music_library_repository.dart';

class SearchMusicUseCase {
  SearchMusicUseCase(this._library);

  final MusicLibraryRepository _library;

  List<Song> call(String query) => _library.searchSongs(query);
}
