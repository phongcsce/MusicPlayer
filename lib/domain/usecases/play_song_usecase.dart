import '../entities/song.dart';
import '../services/playback_controller.dart';

class PlaySongUseCase {
  PlaySongUseCase(this._playback);

  final PlaybackController _playback;

  Future<void> call(Song song) => _playback.playSong(song);
}
