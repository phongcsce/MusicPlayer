import '../entities/playlist.dart';
import '../repositories/music_library_repository.dart';

class GetUserPlaylistsUseCase {
  GetUserPlaylistsUseCase(this._library);

  final MusicLibraryRepository _library;

  List<Playlist> call() => _library.getUserPlaylists();
}
