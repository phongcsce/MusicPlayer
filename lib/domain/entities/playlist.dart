import 'package:equatable/equatable.dart';

class Playlist extends Equatable {
  const Playlist({
    required this.id,
    required this.name,
    required this.coverUrl,
    required this.songIds,
    required this.ownerName,
    this.description,
  });

  final String id;
  final String name;
  final String coverUrl;
  final List<String> songIds;
  final String ownerName;
  final String? description;

  @override
  List<Object?> get props =>
      [id, name, coverUrl, songIds, ownerName, description];
}
