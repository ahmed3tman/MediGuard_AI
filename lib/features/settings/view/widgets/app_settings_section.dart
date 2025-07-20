import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spider_doctor/features/settings/cubit/settings_cubit.dart';
import 'package:spider_doctor/features/settings/cubit/settings_state.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../../core/shared/widgets/floating_snackbar.dart';

class AppSettingsSection extends StatelessWidget {
  const AppSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, settingsState) {
              final notificationsEnabled = settingsState is SettingsLoaded
                  ? settingsState.notificationsEnabled
                  : true;
              return ListTile(
                leading: const Icon(Icons.notifications),
                title: Text(AppLocalizations.of(context).notifications),
                subtitle: Text(
                  AppLocalizations.of(context).manageNotifications,
                ),
                trailing: Switch(
                  value: notificationsEnabled,
                  onChanged: (value) {
                    context.read<SettingsCubit>().toggleNotifications(value);
                    FloatingSnackBar.showInfo(
                      context,
                      message: notificationsEnabled
                          ? 'Notifications disabled'
                          : 'Notifications enabled',
                    );
                  },
                ),
              );
            },
          ),
          const Divider(height: 1),
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, settingsState) {
              final darkModeEnabled = settingsState is SettingsLoaded
                  ? settingsState.darkModeEnabled
                  : false;
              return ListTile(
                leading: const Icon(Icons.dark_mode),
                title: Text(AppLocalizations.of(context).darkMode),
                subtitle: Text(AppLocalizations.of(context).toggleTheme),
                trailing: Switch(
                  value: darkModeEnabled,
                  onChanged: (value) {
                    context.read<SettingsCubit>().toggleDarkMode(value);
                    FloatingSnackBar.showInfo(
                      context,
                      message: darkModeEnabled
                          ? 'Dark mode disabled'
                          : 'Dark mode enabled',
                    );
                  },
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.security),
            title: Text(AppLocalizations.of(context).privacy),
            subtitle: Text(AppLocalizations.of(context).privacySettings),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              FloatingSnackBar.showInfo(
                context,
                message: AppLocalizations.of(context).comingSoon,
              );
            },
          ),
        ],
      ),
    );
  }
}
