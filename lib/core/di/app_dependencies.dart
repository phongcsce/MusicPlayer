import '../../data/datasources/music_local_datasource.dart';
import '../../data/repositories/local_media_repository_impl.dart';
import '../../data/repositories/music_library_repository_impl.dart';
import '../../data/services/hybrid_playback_controller.dart';
import '../../domain/repositories/local_media_repository.dart';
import '../../domain/repositories/music_library_repository.dart';
import '../../domain/services/playback_controller.dart';
import '../../domain/usecases/get_user_playlists_usecase.dart';
import '../../domain/usecases/import_device_media_usecase.dart';
import '../../domain/usecases/play_song_usecase.dart';
import '../../domain/usecases/search_music_usecase.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';

/// Simple composition root. Swap implementations here for tests or remote API.
class AppDependencies {
  AppDependencies() {
    _local = MusicLocalDataSource();
    libraryRepository = MusicLibraryRepositoryImpl(_local);
    localMediaRepository = LocalMediaRepositoryImpl();
    hybridPlayback = HybridPlaybackController();
    playback = hybridPlayback;
    playSong = PlaySongUseCase(playback);
    toggleFavorite = ToggleFavoriteUseCase(libraryRepository);
    searchMusic = SearchMusicUseCase(libraryRepository);
    getUserPlaylists = GetUserPlaylistsUseCase(libraryRepository);
    importDeviceMedia = ImportDeviceMediaUseCase(localMediaRepository);
  }

  late final MusicLocalDataSource _local;
  late final MusicLibraryRepository libraryRepository;
  late final LocalMediaRepository localMediaRepository;
  late final HybridPlaybackController hybridPlayback;
  late final PlaybackController playback;
  late final PlaySongUseCase playSong;
  late final ToggleFavoriteUseCase toggleFavorite;
  late final SearchMusicUseCase searchMusic;
  late final GetUserPlaylistsUseCase getUserPlaylists;
  late final ImportDeviceMediaUseCase importDeviceMedia;

  Future<void> dispose() => playback.dispose();
}
