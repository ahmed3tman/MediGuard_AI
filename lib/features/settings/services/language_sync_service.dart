import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spider_doctor/features/settings/cubit/settings_cubit.dart';
import 'package:spider_doctor/features/settings/cubit/settings_state.dart';
import '../../../core/localization/locale_cubit.dart';

/// خدمة لمزامنة اللغة بين LocaleCubit و SettingsCubit
class LanguageSyncService {
  static void initialize(BuildContext context) {
    final localeCubit = context.read<LocaleCubit>();
    final settingsCubit = context.read<SettingsCubit>();

    // تحديث SettingsCubit عند تغيير اللغة في LocaleCubit
    localeCubit.stream.listen((locale) {
      settingsCubit.changeLanguage(locale.languageCode);
    });

    // تحديث LocaleCubit عند تغيير اللغة في SettingsCubit
    settingsCubit.stream.listen((state) {
      if (state is SettingsLoaded) {
        if (localeCubit.state.languageCode != state.currentLanguage) {
          localeCubit.changeLanguage(state.currentLanguage);
        }
      }
    });
  }

  /// دالة لتغيير اللغة من أي مكان في التطبيق
  static Future<void> changeLanguage(
    BuildContext context,
    String languageCode,
  ) async {
    final localeCubit = context.read<LocaleCubit>();
    await localeCubit.changeLanguage(languageCode);
  }
}
