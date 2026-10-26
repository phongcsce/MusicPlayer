import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/mini_player_bar.dart';
import '../bloc/player_cubit.dart';
import 'favorites_page.dart';
import 'home_page.dart';
import 'now_playing_page.dart';
import 'playlist_page.dart';
import 'search_page.dart';
import 'settings_page.dart';

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _index = 0;

  void _openPlayer(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => const NowPlayingPage(),
        transitionsBuilder: (_, anim, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: FadeTransition(opacity: anim, child: child),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _index,
                children: [
                  HomePage(onOpenSearch: () => setState(() => _index = 1)),
                  const SearchPage(),
                  const FavoritesPage(),
                  const PlaylistPage(),
                  const SettingsPage(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: BlocBuilder<PlayerCubit, PlayerUiState>(
                buildWhen: (p, c) =>
                    p.current != c.current || p.playing != c.playing,
                builder: (context, ps) {
                  final song = ps.current;
                  if (song == null) return const SizedBox.shrink();
                  return MiniPlayerBar(
                    song: song,
                    playing: ps.playing,
                    onTap: () => _openPlayer(context),
                    onPlayPause: () =>
                        context.read<PlayerCubit>().togglePlayPause(),
                    onNext: () => context.read<PlayerCubit>().next(),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: Color(0x14FFFFFF))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    active: _index == 0,
                    onTap: () => setState(() => _index = 0),
                  ),
                  _NavItem(
                    icon: Icons.search_rounded,
                    label: 'Search',
                    active: _index == 1,
                    onTap: () => setState(() => _index = 1),
                  ),
                  _NavItem(
                    icon: Icons.favorite_rounded,
                    label: 'Favorites',
                    active: _index == 2,
                    onTap: () => setState(() => _index = 2),
                  ),
                  _NavItem(
                    icon: Icons.queue_music_rounded,
                    label: 'Playlist',
                    active: _index == 3,
                    onTap: () => setState(() => _index = 3),
                  ),
                  _NavItem(
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    active: _index == 4,
                    onTap: () => setState(() => _index = 4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        active ? AppColors.textPrimary : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                if (active)
                  Positioned(
                    bottom: -6,
                    left: 10,
                    right: 10,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: AppColors.accentGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentPurple.withValues(alpha: 0.55),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                Icon(icon, color: color, size: 26),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
