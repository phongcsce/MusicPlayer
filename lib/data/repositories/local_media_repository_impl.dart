import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/song.dart';
import '../../domain/repositories/local_media_repository.dart';

class LocalMediaRepositoryImpl implements LocalMediaRepository {
  static const _key = 'imported_local_media_v1';

  @override
  Future<List<Song>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => _fromJson(e as Map<String, dynamic>))
          .whereType<Song>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addImportedFiles(List<Song> tracks) async {
    if (tracks.isEmpty) return;
    final existing = await loadAll();
    final byPath = <String, Song>{};
    for (final s in existing) {
      if (s.localFilePath != null) {
        byPath[s.localFilePath!] = s;
      }
    }
    for (final s in tracks) {
      if (s.localFilePath != null) {
        byPath[s.localFilePath!] = s;
      }
    }
    final merged = byPath.values.toList()
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    await _persist(merged);
  }

  @override
  Future<void> remove(String id) async {
    final all = await loadAll();
    await _persist(all.where((s) => s.id != id).toList());
  }

  Future<void> _persist(List<Song> tracks) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(tracks.map(_toJson).toList());
    await prefs.setString(_key, encoded);
  }

  static Map<String, dynamic> _toJson(Song s) => {
        'id': s.id,
        'title': s.title,
        'path': s.localFilePath,
        'isVideo': s.isVideo,
      };

  static Song? _fromJson(Map<String, dynamic> m) {
    final path = m['path'] as String?;
    if (path == null) return null;
    return Song(
      id: m['id'] as String? ?? 'local_${path.hashCode}',
      title: m['title'] as String? ?? p.basename(path),
      artist: 'On device',
      albumArtUrl: '',
      audioUrl: '',
      duration: Duration.zero,
      isVideo: m['isVideo'] == true,
      localFilePath: path,
    );
  }
}
