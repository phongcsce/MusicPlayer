import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeState extends Equatable {
  const ThemeState({required this.darkMode});

  final bool darkMode;

  @override
  List<Object?> get props => [darkMode];
}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState(darkMode: true));

  static const _key = 'settings_dark_mode';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getBool(_key);
    if (v != null) {
      emit(ThemeState(darkMode: v));
    }
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
    emit(ThemeState(darkMode: value));
  }
}
