import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:music_player/data/repositories/local_media_repository_impl.dart';
import 'package:music_player/domain/entities/song.dart';

void main() {
  test('persists and loads imported tracks', () async {
    SharedPreferences.setMockInitialValues({});
    final repo = LocalMediaRepositoryImpl();
    expect(await repo.loadAll(), isEmpty);

    const t = Song(
      id: 'x1',
      title: 'clip.mp3',
      artist: 'On device',
      albumArtUrl: '',
      audioUrl: '',
      duration: Duration.zero,
      isVideo: false,
      localFilePath: '/tmp/clip.mp3',
    );
    await repo.addImportedFiles([t]);
    final again = LocalMediaRepositoryImpl();
    final loaded = await again.loadAll();
    expect(loaded, hasLength(1));
    expect(loaded.first.localFilePath, '/tmp/clip.mp3');
    expect(loaded.first.title, 'clip.mp3');
  });
}
