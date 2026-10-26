import '../../domain/entities/playlist.dart';
import '../../domain/entities/song.dart';
import '../../domain/entities/user_profile.dart';

/// In-memory catalog. Replace with Hive / API later.
class MusicLocalDataSource {
  MusicLocalDataSource() {
    _songs.addAll(_seedSongs);
  }

  static const String demoAudioUrl =
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';

  final List<Song> _songs = [];
  final List<String> _recentSearches = ['Coldplay', 'Shape of You', 'Dua Lipa'];

  final UserProfile _user = const UserProfile(
    displayName: 'Alex',
    avatarUrl: 'https://picsum.photos/seed/avatar12/200/200',
  );

  List<Song> get songs => List.unmodifiable(_songs);

  List<String> get recentSearches => List.unmodifiable(_recentSearches);

  List<String> get genres => const [
        'Pop',
        'EDM',
        'Chill',
        'Rock',
        'Hip Hop',
        'Indie',
      ];

  UserProfile get user => _user;

  List<Playlist> get playlists => [
        Playlist(
          id: 'p1',
          name: 'Chill Vibes',
          coverUrl: 'https://picsum.photos/seed/chill/400/400',
          songIds: _songs.take(6).map((s) => s.id).toList(),
          ownerName: 'Alex',
          description: 'Your wind-down mix',
        ),
        Playlist(
          id: 'p2',
          name: 'Late Night Drive',
          coverUrl: 'https://picsum.photos/seed/drive/400/400',
          songIds: _songs.skip(2).take(8).map((s) => s.id).toList(),
          ownerName: 'Alex',
        ),
      ];

  Song? songById(String id) {
    try {
      return _songs.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  void toggleFavorite(String songId) {
    final i = _songs.indexWhere((s) => s.id == songId);
    if (i >= 0) {
      _songs[i] = _songs[i].copyWith(isFavorite: !_songs[i].isFavorite);
    }
  }

  void addRecentSearch(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    _recentSearches.remove(q);
    _recentSearches.insert(0, q);
    if (_recentSearches.length > 12) {
      _recentSearches.removeLast();
    }
  }

  List<Song> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return _songs
        .where(
          (s) =>
              s.title.toLowerCase().contains(q) ||
              s.artist.toLowerCase().contains(q),
        )
        .toList();
  }

  static final List<Song> _seedSongs = [
    Song(
      id: '1',
      title: 'Save Your Tears',
      artist: 'The Weeknd',
      albumArtUrl: 'https://picsum.photos/seed/save/300/300',
      audioUrl: demoAudioUrl,
      duration: const Duration(minutes: 3, seconds: 35),
    ),
    Song(
      id: '2',
      title: 'Blinding Lights',
      artist: 'The Weeknd',
      albumArtUrl: 'https://picsum.photos/seed/blind/300/300',
      audioUrl: demoAudioUrl,
      duration: const Duration(minutes: 3, seconds: 20),
    ),
    Song(
      id: '3',
      title: 'Levitating',
      artist: 'Dua Lipa',
      albumArtUrl: 'https://picsum.photos/seed/lev/300/300',
      audioUrl: demoAudioUrl,
      duration: const Duration(minutes: 3, seconds: 23),
    ),
    Song(
      id: '4',
      title: 'Watermelon Sugar',
      artist: 'Harry Styles',
      albumArtUrl: 'https://picsum.photos/seed/melon/300/300',
      audioUrl: demoAudioUrl,
      duration: const Duration(minutes: 2, seconds: 54),
    ),
    Song(
      id: '5',
      title: 'Shape of You',
      artist: 'Ed Sheeran',
      albumArtUrl: 'https://picsum.photos/seed/shape/300/300',
      audioUrl: demoAudioUrl,
      duration: const Duration(minutes: 3, seconds: 53),
    ),
    Song(
      id: '6',
      title: 'Yellow',
      artist: 'Coldplay',
      albumArtUrl: 'https://picsum.photos/seed/yellow/300/300',
      audioUrl: demoAudioUrl,
      duration: const Duration(minutes: 4, seconds: 27),
    ),
    Song(
      id: '7',
      title: 'Stay',
      artist: 'The Kid LAROI & Justin Bieber',
      albumArtUrl: 'https://picsum.photos/seed/stay/300/300',
      audioUrl: demoAudioUrl,
      duration: const Duration(minutes: 2, seconds: 21),
    ),
    Song(
      id: '8',
      title: 'Heat Waves',
      artist: 'Glass Animals',
      albumArtUrl: 'https://picsum.photos/seed/heat/300/300',
      audioUrl: demoAudioUrl,
      duration: const Duration(minutes: 3, seconds: 58),
    ),
  ];
}
