import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spider_doctor/core/shared/widgets/custom_button.dart';
import 'package:spider_doctor/core/shared/widgets/dialog_widgets.dart';
import '../../../../core/localization/language_switcher.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/shared/widgets/floating_snackbar.dart';
import '../../../auth/view/screens/login_screen.dart';
import '../../cubit/cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsCubit(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state is SigningOut) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 16),
                  Text(AppLocalizations.of(context).signingOut),
                ],
              ),
            ),
          );
        } else if (state is SignOutSuccess) {
          Navigator.of(context).pop(); // Close loading dialog
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        } else if (state is SignOutError) {
          Navigator.of(context).pop(); // Close loading dialog
          FloatingSnackBar.showError(
            context,
            message: AppLocalizations.of(context).errorSigningOut,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).settings),
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            if (state is SettingsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Language Settings Section
                _buildSectionHeader(
                  context,
                  AppLocalizations.of(context).language,
                  Icons.language,
                ),
                Card(
                  child: Column(
                    children: [
                      const LanguageSettingTile(),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.translate),
                        title: Text(
                          AppLocalizations.of(context).selectLanguage,
                        ),
                        subtitle: BlocBuilder<LocaleCubit, Locale>(
                          builder: (context, locale) {
                            return Text(
                              locale.languageCode == 'en'
                                  ? AppLocalizations.of(context).english
                                  : AppLocalizations.of(context).arabic,
                            );
                          },
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          _showLanguageDialog(context);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // App Settings Section
                _buildSectionHeader(
                  context,
                  AppLocalizations.of(context).settings,
                  Icons.settings,
                ),
                Card(
                  child: Column(
                    children: [
                      BlocBuilder<SettingsCubit, SettingsState>(
                        builder: (context, settingsState) {
                          final notificationsEnabled =
                              settingsState is SettingsLoaded
                              ? settingsState.notificationsEnabled
                              : true;
                          return ListTile(
                            leading: const Icon(Icons.notifications),
                            title: Text(
                              AppLocalizations.of(context).notifications,
                            ),
                            subtitle: Text(
                              AppLocalizations.of(context).manageNotifications,
                            ),
                            trailing: Switch(
                              value: notificationsEnabled,
                              onChanged: (value) {
                                context
                                    .read<SettingsCubit>()
                                    .toggleNotifications(value);
                                FloatingSnackBar.showInfo(
                                  context,
                                  message: AppLocalizations.of(
                                    context,
                                  ).comingSoon,
                                );
                              },
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      BlocBuilder<SettingsCubit, SettingsState>(
                        builder: (context, settingsState) {
                          final darkModeEnabled =
                              settingsState is SettingsLoaded
                              ? settingsState.darkModeEnabled
                              : false;
                          return ListTile(
                            leading: const Icon(Icons.dark_mode),
                            title: Text(AppLocalizations.of(context).darkMode),
                            subtitle: Text(
                              AppLocalizations.of(context).toggleTheme,
                            ),
                            trailing: Switch(
                              value: darkModeEnabled,
                              onChanged: (value) {
                                context.read<SettingsCubit>().toggleDarkMode(
                                  value,
                                );
                                FloatingSnackBar.showInfo(
                                  context,
                                  message: AppLocalizations.of(
                                    context,
                                  ).comingSoon,
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
                        subtitle: Text(
                          AppLocalizations.of(context).privacySettings,
                        ),
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
                ),

                const SizedBox(height: 24),

                // Device Settings Section
                _buildSectionHeader(
                  context,
                  AppLocalizations.of(context).deviceSettings,
                  Icons.devices,
                ),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.wifi),
                        title: Text(AppLocalizations.of(context).wifiSettings),
                        subtitle: Text(
                          AppLocalizations.of(context).manageConnections,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          FloatingSnackBar.showInfo(
                            context,
                            message: AppLocalizations.of(context).comingSoon,
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.bluetooth),
                        title: Text(
                          AppLocalizations.of(context).bluetoothSettings,
                        ),
                        subtitle: Text(
                          AppLocalizations.of(context).manageDevices,
                        ),
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
                ),

                const SizedBox(height: 24),

                // Support Section
                _buildSectionHeader(
                  context,
                  AppLocalizations.of(context).support,
                  Icons.help,
                ),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.help_outline),
                        title: Text(AppLocalizations.of(context).helpSupport),
                        subtitle: Text(AppLocalizations.of(context).getHelp),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          FloatingSnackBar.showInfo(
                            context,
                            message: AppLocalizations.of(context).comingSoon,
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: Text(AppLocalizations.of(context).about),
                        subtitle: Text(AppLocalizations.of(context).appVersion),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          _showAboutDialog(context);
                        },
                      ),
                      const SizedBox(height: 32),

                      // Sign Out Button
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: AppLocalizations.of(context).signOut,
                          icon: Icons.logout,
                          onPressed: () => _handleSignOut(context),
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[600], size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const LanguageDialog());
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: AppLocalizations.of(context).appTitle,
        applicationVersion: '1.0.0',
        applicationIcon: const Icon(Icons.medical_services, size: 50),
        children: [Text(AppLocalizations.of(context).appDescription)],
      ),
    );
  }

  Future<void> _handleSignOut(BuildContext context) async {
    final shouldSignOut = await ConfirmationDialog.show(
      context,
      title: AppLocalizations.of(context).signOut,
      content: AppLocalizations.of(context).signOutConfirm,
      confirmText: AppLocalizations.of(context).signOut,
      cancelText: AppLocalizations.of(context).cancel,
      confirmColor: Colors.red,
    );

    if (shouldSignOut == true && context.mounted) {
      context.read<SettingsCubit>().signOut();
    }
  }
}
