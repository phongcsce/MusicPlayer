import 'package:equatable/equatable.dart';

class Song extends Equatable {
  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.albumArtUrl,
    required this.audioUrl,
    required this.duration,
    this.isFavorite = false,
    this.isVideo = false,
    this.localFilePath,
  });

  final String id;
  final String title;
  final String artist;
  final String albumArtUrl;
  /// Remote stream URL when [localFilePath] is null.
  final String audioUrl;
  final Duration duration;
  final bool isFavorite;
  /// True when [localFilePath] points to a video file.
  final bool isVideo;
  /// Absolute path for on-device audio/video; playback uses this instead of [audioUrl].
  final String? localFilePath;

  bool get isLocalFile => localFilePath != null;

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? albumArtUrl,
    String? audioUrl,
    Duration? duration,
    bool? isFavorite,
    bool? isVideo,
    String? localFilePath,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      albumArtUrl: albumArtUrl ?? this.albumArtUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      isFavorite: isFavorite ?? this.isFavorite,
      isVideo: isVideo ?? this.isVideo,
      localFilePath: localFilePath ?? this.localFilePath,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        artist,
        albumArtUrl,
        audioUrl,
        duration,
        isFavorite,
        isVideo,
        localFilePath,
      ];
}
