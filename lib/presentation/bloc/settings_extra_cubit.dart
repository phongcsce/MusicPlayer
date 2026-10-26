import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Local UI-only settings (wire to real prefs / platform later).
class SettingsExtraState extends Equatable {
  const SettingsExtraState({
    this.audioQuality = 'High',
    this.notificationsOn = true,
  });

  final String audioQuality;
  final bool notificationsOn;

  SettingsExtraState copyWith({
    String? audioQuality,
    bool? notificationsOn,
  }) {
    return SettingsExtraState(
      audioQuality: audioQuality ?? this.audioQuality,
      notificationsOn: notificationsOn ?? this.notificationsOn,
    );
  }

  @override
  List<Object?> get props => [audioQuality, notificationsOn];
}

class SettingsExtraCubit extends Cubit<SettingsExtraState> {
  SettingsExtraCubit() : super(const SettingsExtraState());

  void setAudioQuality(String q) => emit(state.copyWith(audioQuality: q));

  void toggleNotifications() =>
      emit(state.copyWith(notificationsOn: !state.notificationsOn));
}
