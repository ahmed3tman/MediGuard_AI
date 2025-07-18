import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/services/auth_service.dart';
import '../repository/settings_repository.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _repository;

  SettingsCubit({SettingsRepository? repository})
    : _repository = repository ?? SettingsRepository(),
      super(const SettingsInitial()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      emit(const SettingsLoading());

      final notificationsEnabled = await _repository.getNotificationsEnabled();
      final darkModeEnabled = await _repository.getDarkModeEnabled();
      final languageCode = await _repository.getLanguageCode();

      emit(
        SettingsLoaded(
          notificationsEnabled: notificationsEnabled,
          darkModeEnabled: darkModeEnabled,
          currentLanguage: languageCode,
        ),
      );
    } catch (e) {
      emit(SettingsError(message: e.toString()));
    }
  }

  Future<void> toggleNotifications(bool value) async {
    if (state is SettingsLoaded) {
      try {
        await _repository.setNotificationsEnabled(value);
        final currentState = state as SettingsLoaded;
        emit(currentState.copyWith(notificationsEnabled: value));
      } catch (e) {
        emit(SettingsError(message: e.toString()));
      }
    }
  }

  Future<void> toggleDarkMode(bool value) async {
    if (state is SettingsLoaded) {
      try {
        await _repository.setDarkModeEnabled(value);
        final currentState = state as SettingsLoaded;
        emit(currentState.copyWith(darkModeEnabled: value));
      } catch (e) {
        emit(SettingsError(message: e.toString()));
      }
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    if (state is SettingsLoaded) {
      try {
        await _repository.setLanguageCode(languageCode);
        final currentState = state as SettingsLoaded;
        emit(currentState.copyWith(currentLanguage: languageCode));

        // Also emit the language change to LocaleCubit if it exists
        // This will be handled in the UI layer
      } catch (e) {
        emit(SettingsError(message: e.toString()));
      }
    }
  }

  Future<void> signOut() async {
    try {
      emit(const SigningOut());
      await AuthService.signOut();
      // Clear settings on sign out
      await _repository.clearAllSettings();
      emit(const SignOutSuccess());
    } catch (e) {
      emit(SignOutError(message: e.toString()));
    }
  }

  void resetToLoaded() {
    if (state is! SettingsLoaded) {
      _loadSettings();
    }
  }
}
