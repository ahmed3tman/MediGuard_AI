import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/settings/repository/settings_repository.dart';

class LocaleCubit extends Cubit<Locale> {
  final SettingsRepository _settingsRepository;

  LocaleCubit({SettingsRepository? settingsRepository})
    : _settingsRepository = settingsRepository ?? SettingsRepository(),
      super(const Locale('en')) {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final savedLanguage = await _settingsRepository.getLanguageCode();
      emit(Locale(savedLanguage));
    } catch (e) {
      emit(const Locale('en'));
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    try {
      await _settingsRepository.setLanguageCode(languageCode);
      emit(Locale(languageCode));
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> toggleLanguage() async {
    final newLanguageCode = state.languageCode == 'en' ? 'ar' : 'en';
    await changeLanguage(newLanguageCode);
  }
}
