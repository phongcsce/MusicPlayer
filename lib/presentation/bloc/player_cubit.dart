import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/song.dart';
import '../../domain/services/playback_controller.dart';
import '../../domain/usecases/play_song_usecase.dart';

class PlayerUiState extends Equatable {
  const PlayerUiState({
    this.current,
    this.playing = false,
    this.position = Duration.zero,
    this.duration,
    this.shuffle = false,
    this.repeat = RepeatMode.off,
    this.queue = const [],
  });

  final Song? current;
  final bool playing;
  final Duration position;
  final Duration? duration;
  final bool shuffle;
  final RepeatMode repeat;
  final List<Song> queue;

  PlayerUiState copyWith({
    Song? current,
    bool? playing,
    Duration? position,
    Duration? duration,
    bool? shuffle,
    RepeatMode? repeat,
    List<Song>? queue,
  }) {
    return PlayerUiState(
      current: current ?? this.current,
      playing: playing ?? this.playing,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      shuffle: shuffle ?? this.shuffle,
      repeat: repeat ?? this.repeat,
      queue: queue ?? this.queue,
    );
  }

  @override
  List<Object?> get props =>
      [current, playing, position, duration, shuffle, repeat, queue];
}

PlayerUiState _playerInitial(PlaybackController p) {
  return PlayerUiState(
    current: p.currentSongValue,
    queue: p.queueValue,
    shuffle: p.shuffleEnabledValue,
    repeat: p.repeatModeValue,
  );
}

class PlayerCubit extends Cubit<PlayerUiState> {
  PlayerCubit(PlaybackController playback, this._playSongUseCase)
      : _playback = playback,
        super(_playerInitial(playback)) {
    _subs.add(_playback.position.listen((p) {
      emit(state.copyWith(position: p));
    }));
    _subs.add(_playback.duration.listen((d) {
      emit(state.copyWith(duration: d));
    }));
    _subs.add(_playback.playing.listen((v) {
      emit(state.copyWith(playing: v));
    }));
    _subs.add(_playback.currentSong.listen((s) {
      emit(state.copyWith(current: s));
    }));
    _subs.add(_playback.queue.listen((q) {
      emit(state.copyWith(queue: q));
    }));
    _subs.add(_playback.shuffleEnabled.listen((v) {
      emit(state.copyWith(shuffle: v));
    }));
    _subs.add(_playback.repeatMode.listen((r) {
      emit(state.copyWith(repeat: r));
    }));
  }

  final PlaybackController _playback;
  final PlaySongUseCase _playSongUseCase;
  final List<StreamSubscription<dynamic>> _subs = [];

  Future<void> play(Song song) => _playSongUseCase(song);

  Future<void> playQueue(List<Song> songs, {int startIndex = 0}) =>
      _playback.playQueue(songs, startIndex: startIndex);

  Future<void> togglePlayPause() async {
    if (state.playing) {
      await _playback.pause();
    } else {
      await _playback.resume();
    }
  }

  Future<void> seek(Duration d) => _playback.seek(d);

  Future<void> next() => _playback.skipToNext();

  Future<void> previous() => _playback.skipToPrevious();

  Future<void> toggleShuffle() =>
      _playback.setShuffle(!state.shuffle);

  Future<void> cycleRepeat() async {
    final next = switch (state.repeat) {
      RepeatMode.off => RepeatMode.all,
      RepeatMode.all => RepeatMode.one,
      RepeatMode.one => RepeatMode.off,
    };
    await _playback.setRepeatMode(next);
  }

  @override
  Future<void> close() async {
    for (final s in _subs) {
      await s.cancel();
    }
    return super.close();
  }
}
