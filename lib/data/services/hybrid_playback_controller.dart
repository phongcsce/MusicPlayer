import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

import '../../domain/entities/song.dart';
import '../../domain/services/playback_controller.dart';

/// Plays remote URLs (audio), local audio files, and local video files.
class HybridPlaybackController implements PlaybackController {
  HybridPlaybackController() {
    _attachAudioStreams();
  }

  final AudioPlayer _player = AudioPlayer();
  VideoPlayerController? _video;

  final StreamController<Duration> _positionCtrl =
      StreamController<Duration>.broadcast();
  final StreamController<Duration?> _durationCtrl =
      StreamController<Duration?>.broadcast();
  final StreamController<bool> _playingCtrl =
      StreamController<bool>.broadcast();
  final StreamController<Song?> _currentSongCtrl =
      StreamController<Song?>.broadcast();
  final StreamController<List<Song>> _queueCtrl =
      StreamController<List<Song>>.broadcast();
  final StreamController<bool> _shuffleCtrl =
      StreamController<bool>.broadcast();
  final StreamController<RepeatMode> _repeatCtrl =
      StreamController<RepeatMode>.broadcast();

  final List<StreamSubscription<dynamic>> _subscriptions = [];

  /// Notifies when the active [VideoPlayerController] changes (for UI surface).
  final ValueNotifier<VideoPlayerController?> videoSurface =
      ValueNotifier<VideoPlayerController?>(null);

  List<Song> _queue = [];
  int _index = 0;
  Song? _current;
  bool _shuffle = false;
  RepeatMode _repeat = RepeatMode.off;
  final _random = Random();
  bool _usingVideo = false;
  bool _lastVideoPlaying = false;

  @override
  Stream<Duration> get position => _positionCtrl.stream;

  @override
  Stream<Duration?> get duration => _durationCtrl.stream;

  @override
  Stream<bool> get playing => _playingCtrl.stream;

  @override
  Stream<Song?> get currentSong => _currentSongCtrl.stream;

  @override
  Stream<List<Song>> get queue => _queueCtrl.stream;

  @override
  Stream<bool> get shuffleEnabled => _shuffleCtrl.stream;

  @override
  Stream<RepeatMode> get repeatMode => _repeatCtrl.stream;

  @override
  Song? get currentSongValue => _current;

  @override
  List<Song> get queueValue => List.unmodifiable(_queue);

  @override
  bool get shuffleEnabledValue => _shuffle;

  @override
  RepeatMode get repeatModeValue => _repeat;

  void _attachAudioStreams() {
    _subscriptions.add(_player.positionStream.listen((p) {
      if (!_usingVideo) _positionCtrl.add(p);
    }));
    _subscriptions.add(_player.durationStream.listen((d) {
      if (!_usingVideo) _durationCtrl.add(d);
    }));
    _subscriptions.add(_player.playingStream.listen((v) {
      if (!_usingVideo) _playingCtrl.add(v);
    }));
  }

  void _videoListener() {
    if (!_usingVideo || _video == null || !_video!.value.isInitialized) {
      return;
    }
    final v = _video!;
    _positionCtrl.add(v.value.position);
    _durationCtrl.add(v.value.duration);
    final playingNow = v.value.isPlaying;
    if (playingNow != _lastVideoPlaying) {
      _lastVideoPlaying = playingNow;
      _playingCtrl.add(playingNow);
    }
  }

  void _emitCurrent() {
    _currentSongCtrl.add(_current);
  }

  void _emitQueue() {
    _queueCtrl.add(List.unmodifiable(_queue));
  }

  Future<void> _disposeVideo() async {
    videoSurface.value = null;
    final c = _video;
    _video = null;
    _usingVideo = false;
    _lastVideoPlaying = false;
    if (c != null) {
      c.removeListener(_videoListener);
      await c.dispose();
    }
  }

  Future<void> _loadIndex(int i) async {
    if (_queue.isEmpty || i < 0 || i >= _queue.length) return;
    _index = i;
    _current = _queue[_index];
    _emitCurrent();

    final s = _current!;
    if (s.isVideo && s.localFilePath != null) {
      await _player.stop();
      await _disposeVideo();
      _usingVideo = true;
      final file = File(s.localFilePath!);
      _video = VideoPlayerController.file(file);
      await _video!.initialize();
      _video!.addListener(_videoListener);
      _lastVideoPlaying = false;
      _videoListener();
      videoSurface.value = _video;
      await _video!.play();
      _lastVideoPlaying = true;
      _playingCtrl.add(true);
    } else {
      await _disposeVideo();
      _usingVideo = false;
      if (s.localFilePath != null) {
        await _player.setAudioSource(
          AudioSource.file(s.localFilePath!),
        );
      } else {
        await _player.setUrl(s.audioUrl);
      }
      await _player.play();
    }
  }

  @override
  Future<void> playQueue(List<Song> songs, {int startIndex = 0}) async {
    if (songs.isEmpty) return;
    _queue = List<Song>.from(songs);
    _emitQueue();
    final start = startIndex.clamp(0, _queue.length - 1);
    await _loadIndex(start);
  }

  @override
  Future<void> playSong(Song song) async {
    final all = _queue.isNotEmpty ? _queue : [song];
    final idx = all.indexWhere((s) => s.id == song.id);
    if (idx >= 0) {
      _queue = List<Song>.from(all);
      _emitQueue();
      await _loadIndex(idx);
    } else {
      _queue = [song];
      _emitQueue();
      await _loadIndex(0);
    }
  }

  @override
  Future<void> pause() async {
    if (_usingVideo && _video != null) {
      await _video!.pause();
    } else {
      await _player.pause();
    }
  }

  @override
  Future<void> resume() async {
    if (_usingVideo && _video != null) {
      await _video!.play();
    } else {
      await _player.play();
    }
  }

  @override
  Future<void> seek(Duration position) async {
    if (_usingVideo && _video != null) {
      await _video!.seekTo(position);
    } else {
      await _player.seek(position);
    }
  }

  @override
  Future<void> skipToNext() async {
    if (_queue.isEmpty) return;
    if (_shuffle) {
      final next = _random.nextInt(_queue.length);
      await _loadIndex(next);
      return;
    }
    if (_index < _queue.length - 1) {
      await _loadIndex(_index + 1);
    } else if (_repeat == RepeatMode.all) {
      await _loadIndex(0);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_queue.isEmpty) return;
    if (_shuffle) {
      final prev = _random.nextInt(_queue.length);
      await _loadIndex(prev);
      return;
    }
    if (_index > 0) {
      await _loadIndex(_index - 1);
    } else if (_repeat == RepeatMode.all) {
      await _loadIndex(_queue.length - 1);
    }
  }

  @override
  Future<void> setShuffle(bool enabled) async {
    _shuffle = enabled;
    _shuffleCtrl.add(_shuffle);
  }

  @override
  Future<void> setRepeatMode(RepeatMode mode) async {
    _repeat = mode;
    _repeatCtrl.add(_repeat);
  }

  @override
  Future<void> dispose() async {
    await _disposeVideo();
    for (final s in _subscriptions) {
      await s.cancel();
    }
    await _player.dispose();
    await _positionCtrl.close();
    await _durationCtrl.close();
    await _playingCtrl.close();
    await _currentSongCtrl.close();
    await _queueCtrl.close();
    await _shuffleCtrl.close();
    await _repeatCtrl.close();
  }
}
