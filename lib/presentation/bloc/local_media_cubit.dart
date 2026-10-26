import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/song.dart';
import '../../domain/repositories/local_media_repository.dart';
import '../../domain/usecases/import_device_media_usecase.dart';

class LocalMediaState extends Equatable {
  const LocalMediaState({
    this.items = const [],
    this.busy = false,
  });

  final List<Song> items;
  final bool busy;

  LocalMediaState copyWith({
    List<Song>? items,
    bool? busy,
  }) {
    return LocalMediaState(
      items: items ?? this.items,
      busy: busy ?? this.busy,
    );
  }

  @override
  List<Object?> get props => [items, busy];
}

class LocalMediaCubit extends Cubit<LocalMediaState> {
  LocalMediaCubit(this._repo, this._importUseCase)
      : super(const LocalMediaState());

  final LocalMediaRepository _repo;
  final ImportDeviceMediaUseCase _importUseCase;

  Future<void> load() async {
    emit(state.copyWith(busy: true));
    final list = await _repo.loadAll();
    emit(LocalMediaState(items: list, busy: false));
  }

  Future<void> importTracks(List<Song> tracks) async {
    if (tracks.isEmpty) return;
    emit(state.copyWith(busy: true));
    await _importUseCase(tracks);
    await load();
  }

  Future<void> remove(String id) async {
    emit(state.copyWith(busy: true));
    await _repo.remove(id);
    await load();
  }
}
