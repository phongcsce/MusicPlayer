import '../entities/song.dart';

/// Persisted tracks imported from device storage.
abstract class LocalMediaRepository {
  Future<List<Song>> loadAll();
  Future<void> addImportedFiles(List<Song> tracks);
  Future<void> remove(String id);
}
