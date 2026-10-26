# Music Player

A Flutter music player app for browsing a sample music library and playing audio or video files from your device. It includes a compact player, favorites, playlists, search, and a dark/light theme.

> The built-in catalog is local sample data; this app does not connect to a music-streaming service.

## Features

- Browse recently played, recommended, and trending sample tracks.
- Search the sample catalog and imported device media; recent searches and genre tags are available in Search.
- Play device audio and video files, with options to play a selection once or import it into the in-app device list.
- Use playback controls for play/pause, seeking, previous/next, shuffle, and repeat.
- Save and remove favorites, and browse songs, artists, and playlists.
- Switch between light and dark themes.

Supported device-file extensions are MP3, M4A, WAV, FLAC, AAC, OGG, OPUS, WMA, MP4, MOV, MKV, WEBM, M4V, AVI, and 3GP. Imported files are listed using their device paths; the app does not copy the media files.

Some visible controls are placeholders rather than implemented features. For example, voice search, audio-quality selection, notifications, account, equalizer, download, sleep timer, and add-to-playlist actions are not connected to those services or settings.

## Requirements

- Flutter SDK compatible with the Dart constraint in `pubspec.yaml` (`^3.11.1`).
- Android Studio or the Android SDK and a working JDK for Android builds.
- An Android device/emulator or another Flutter-supported target.

## Run locally

```sh
flutter doctor
flutter pub get
flutter run
```

To build an Android debug APK:

```sh
flutter build apk --debug
```

The APK is written to `build/app/outputs/flutter-apk/app-debug.apk`.

If an Android build reports that `JAVA_HOME` points to an invalid directory, check the Java path selected by Flutter with `flutter doctor -v`. Configure Flutter to use an installed JDK, for example:

```sh
flutter config --jdk-dir="/path/to/installed/jdk"
```

## Project structure

```text
lib/
  core/        App dependencies, theme, shared widgets, and utilities
  data/        Local sample catalog, device media, and playback implementations
  domain/      Entities, repositories, services, and use cases
  presentation/ UI pages, state management, and media file picking
```

The UI uses Flutter Bloc/Cubit for state management. Imported-media entries and the theme preference are persisted locally with `shared_preferences`.
