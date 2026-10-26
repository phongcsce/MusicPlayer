import '../entities/song.dart';

enum RepeatMode { off, one, all }

abstract class PlaybackController {
  Stream<Duration> get position;
  Stream<Duration?> get duration;
  Stream<bool> get playing;
  Stream<Song?> get currentSong;
  Stream<List<Song>> get queue;
  Stream<bool> get shuffleEnabled;
  Stream<RepeatMode> get repeatMode;

  Song? get currentSongValue;
  List<Song> get queueValue;
  bool get shuffleEnabledValue;
  RepeatMode get repeatModeValue;

  Future<void> playQueue(List<Song> songs, {int startIndex = 0});
  Future<void> playSong(Song song);
  Future<void> pause();
  Future<void> resume();
  Future<void> seek(Duration position);
  Future<void> skipToNext();
  Future<void> skipToPrevious();
  Future<void> setShuffle(bool enabled);
  Future<void> setRepeatMode(RepeatMode mode);
  Future<void> dispose();
}
