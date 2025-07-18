import 'package:equatable/equatable.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

class SettingsLoaded extends SettingsState {
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final String currentLanguage;

  const SettingsLoaded({
    required this.notificationsEnabled,
    required this.darkModeEnabled,
    required this.currentLanguage,
  });

  @override
  List<Object?> get props => [
    notificationsEnabled,
    darkModeEnabled,
    currentLanguage,
  ];

  SettingsLoaded copyWith({
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    String? currentLanguage,
  }) {
    return SettingsLoaded(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      currentLanguage: currentLanguage ?? this.currentLanguage,
    );
  }
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class SigningOut extends SettingsState {
  const SigningOut();
}

class SignOutSuccess extends SettingsState {
  const SignOutSuccess();
}

class SignOutError extends SettingsState {
  final String message;

  const SignOutError({required this.message});

  @override
  List<Object?> get props => [message];
}
