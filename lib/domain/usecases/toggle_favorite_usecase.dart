import '../repositories/music_library_repository.dart';

class ToggleFavoriteUseCase {
  ToggleFavoriteUseCase(this._library);

  final MusicLibraryRepository _library;

  Future<void> call(String songId) => _library.toggleFavorite(songId);
}
