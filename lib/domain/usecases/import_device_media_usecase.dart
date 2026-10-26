import '../entities/song.dart';
import '../repositories/local_media_repository.dart';

class ImportDeviceMediaUseCase {
  ImportDeviceMediaUseCase(this._repo);

  final LocalMediaRepository _repo;

  Future<void> call(List<Song> tracks) => _repo.addImportedFiles(tracks);
}
