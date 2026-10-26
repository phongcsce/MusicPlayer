import 'package:file_picker/file_picker.dart';

import '../../data/local_media/song_local_factory.dart';
import '../../domain/entities/song.dart';

/// Opens the system file picker for audio/video extensions we support.
Future<List<Song>> pickDeviceMediaFiles() async {
  final exts = <String>{
    ...SongLocalFactory.audioExtensions,
    ...SongLocalFactory.videoExtensions,
  }.toList()
    ..sort();

  final result = await FilePicker.platform.pickFiles(
    allowMultiple: true,
    type: FileType.custom,
    allowedExtensions: exts,
  );

  if (result == null || result.files.isEmpty) return [];

  final songs = <Song>[];
  for (final f in result.files) {
    final path = f.path;
    if (path == null || !SongLocalFactory.isSupported(path)) continue;
    try {
      songs.add(SongLocalFactory.fromPath(path));
    } on ArgumentError {
      continue;
    }
  }
  return songs;
}
