import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../bloc/local_media_cubit.dart';
import '../bloc/player_cubit.dart';
import '../bloc/settings_extra_cubit.dart';
import '../bloc/theme_cubit.dart';
import '../utils/media_file_picker.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 120),
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Text(
            'Settings',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
        ),
        _tile(
          context,
          icon: Icons.person_outline,
          title: 'Account',
          onTap: () => _snack(context, 'Account'),
        ),
        _tile(
          context,
          icon: Icons.play_circle_outline_rounded,
          title: 'Open file from device',
          subtitle: 'Play once; not saved to your list',
          onTap: () => _openFromDevice(context),
        ),
        _tile(
          context,
          icon: Icons.library_add_rounded,
          title: 'Import music or video',
          subtitle: 'Adds to Home → On this device',
          onTap: () => _importFromDevice(context),
        ),
        BlocBuilder<SettingsExtraCubit, SettingsExtraState>(
          builder: (context, s) {
            return _tile(
              context,
              icon: Icons.high_quality_outlined,
              title: 'Audio Quality',
              subtitle: s.audioQuality,
              onTap: () => _pickQuality(context),
            );
          },
        ),
        _tile(
          context,
          icon: Icons.download_outlined,
          title: 'Download Settings',
          onTap: () => _snack(context, 'Download settings'),
        ),
        BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, t) {
            return SwitchListTile.adaptive(
              secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.textSecondary),
              title: const Text('Dark Mode'),
              value: t.darkMode,
              activeThumbColor: AppColors.accentPurple,
              onChanged: (v) => context.read<ThemeCubit>().setDarkMode(v),
            );
          },
        ),
        _tile(
          context,
          icon: Icons.graphic_eq,
          title: 'Equalizer',
          onTap: () => _snack(context, 'Equalizer'),
        ),
        BlocBuilder<SettingsExtraCubit, SettingsExtraState>(
          builder: (context, s) {
            return SwitchListTile.adaptive(
              secondary: const Icon(Icons.notifications_none, color: AppColors.textSecondary),
              title: const Text('Notifications'),
              value: s.notificationsOn,
              activeThumbColor: AppColors.accentPurple,
              onChanged: (_) =>
                  context.read<SettingsExtraCubit>().toggleNotifications(),
            );
          },
        ),
      ],
    );
  }

  static Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(color: AppColors.textSecondary))
          : null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }

  static void _snack(BuildContext context, String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  static Future<void> _openFromDevice(BuildContext context) async {
    final list = await pickDeviceMediaFiles();
    if (!context.mounted || list.isEmpty) return;
    await context.read<PlayerCubit>().playQueue(list);
  }

  static Future<void> _importFromDevice(BuildContext context) async {
    final list = await pickDeviceMediaFiles();
    if (!context.mounted || list.isEmpty) return;
    await context.read<LocalMediaCubit>().importTracks(list);
    if (!context.mounted) return;
    await context.read<PlayerCubit>().play(list.first);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${list.length} file(s) imported')),
    );
  }

  static void _pickQuality(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(title: Text('Audio quality')),
              ListTile(
                title: const Text('Low'),
                onTap: () {
                  context.read<SettingsExtraCubit>().setAudioQuality('Low');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: const Text('High'),
                onTap: () {
                  context.read<SettingsExtraCubit>().setAudioQuality('High');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: const Text('Lossless'),
                onTap: () {
                  context.read<SettingsExtraCubit>().setAudioQuality('Lossless');
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
