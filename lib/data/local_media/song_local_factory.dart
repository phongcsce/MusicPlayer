import 'package:path/path.dart' as p;

import '../../domain/entities/song.dart';

/// Builds [Song] instances for device files.
abstract final class SongLocalFactory {
  static const audioExtensions = {
    'mp3',
    'm4a',
    'wav',
    'flac',
    'aac',
    'ogg',
    'opus',
    'wma',
  };

  static const videoExtensions = {
    'mp4',
    'mov',
    'mkv',
    'webm',
    'm4v',
    'avi',
    '3gp',
  };

  static bool isSupportedAudio(String path) =>
      audioExtensions.contains(_ext(path));

  static bool isSupportedVideo(String path) =>
      videoExtensions.contains(_ext(path));

  static bool isSupported(String path) =>
      isSupportedAudio(path) || isSupportedVideo(path);

  static String _ext(String path) {
    final e = p.extension(path).toLowerCase();
    if (e.startsWith('.')) return e.substring(1);
    return e;
  }

  /// Stable id from path + kind so re-import does not duplicate.
  static Song fromPath(String path) {
    final video = isSupportedVideo(path);
    final audio = isSupportedAudio(path);
    if (!video && !audio) {
      throw ArgumentError('Unsupported media type: $path');
    }
    final name = p.basename(path);
    return Song(
      id: 'device_${path.hashCode}_${video ? 'v' : 'a'}',
      title: name,
      artist: 'On device',
      albumArtUrl: '',
      audioUrl: '',
      duration: Duration.zero,
      isVideo: video,
      localFilePath: path,
    );
  }
}
