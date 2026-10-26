import 'package:flutter_test/flutter_test.dart';

import 'package:music_player/data/datasources/music_local_datasource.dart';
import 'package:music_player/data/repositories/music_library_repository_impl.dart';

void main() {
  test('searchSongs returns catalog matches', () {
    final ds = MusicLocalDataSource();
    final repo = MusicLibraryRepositoryImpl(ds);
    final coldplay = repo.searchSongs('cold');
    expect(coldplay, isNotEmpty);
    expect(coldplay.first.artist.toLowerCase(), contains('cold'));
  });

  test('toggleFavorite flips flag', () async {
    final ds = MusicLocalDataSource();
    final repo = MusicLibraryRepositoryImpl(ds);
    const id = '1';
    final before = repo.getSongById(id)!.isFavorite;
    await repo.toggleFavorite(id);
    expect(repo.getSongById(id)!.isFavorite, !before);
  });
}
