import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/app_dependencies.dart';
import 'core/theme/app_theme.dart';
import 'data/services/hybrid_playback_controller.dart';
import 'presentation/bloc/local_media_cubit.dart';
import 'presentation/bloc/music_library_cubit.dart';
import 'presentation/bloc/player_cubit.dart';
import 'presentation/bloc/settings_extra_cubit.dart';
import 'presentation/bloc/theme_cubit.dart';
import 'presentation/pages/shell_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final deps = AppDependencies();
  runApp(MusicPlayerApp(deps: deps));
}

class MusicPlayerApp extends StatefulWidget {
  const MusicPlayerApp({super.key, required this.deps});

  final AppDependencies deps;

  @override
  State<MusicPlayerApp> createState() => _MusicPlayerAppState();
}

class _MusicPlayerAppState extends State<MusicPlayerApp> {
  late final ThemeCubit _themeCubit;

  @override
  void initState() {
    super.initState();
    _themeCubit = ThemeCubit()..load();
  }

  @override
  void dispose() {
    _themeCubit.close();
    widget.deps.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.deps;
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<HybridPlaybackController>.value(
          value: d.hybridPlayback,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _themeCubit),
          BlocProvider(
            create: (_) => MusicLibraryCubit(
              d.libraryRepository,
              d.toggleFavorite,
            ),
          ),
          BlocProvider(
            create: (_) => PlayerCubit(d.playback, d.playSong),
          ),
          BlocProvider(
            create: (_) => LocalMediaCubit(
              d.localMediaRepository,
              d.importDeviceMedia,
            )..load(),
          ),
          BlocProvider(create: (_) => SettingsExtraCubit()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, theme) {
            return MaterialApp(
              title: 'Music Player',
              debugShowCheckedModeBanner: false,
              theme: theme.darkMode
                  ? AppTheme.dark()
                  : AppTheme.light(),
              home: const ShellPage(),
            );
          },
        ),
      ),
    );
  }
}
