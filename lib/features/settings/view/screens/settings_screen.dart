import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spider_doctor/core/shared/widgets/custom_button.dart';
import 'package:spider_doctor/core/shared/widgets/dialog_widgets.dart';
import 'package:spider_doctor/features/settings/cubit/settings_cubit.dart';
import 'package:spider_doctor/features/settings/cubit/settings_state.dart';
import '../../../../core/localization/language_switcher.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../core/shared/widgets/floating_snackbar.dart';
import '../../../auth/view/screens/login_screen.dart';
import '../../repository/settings_repository.dart';
import '../widgets/widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsCubit(repository: SettingsRepository()),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SettingsCubit, SettingsState>(
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
        ),
        BlocListener<LocaleCubit, Locale>(
          listener: (context, locale) {
            // Update SettingsCubit when language changes
            context.read<SettingsCubit>().changeLanguage(locale.languageCode);
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context).settings,
            style: const TextStyle(
              fontFamily: 'NeoSansArabic',
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
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
                SectionHeader(
                  title: AppLocalizations.of(context).language,
                  icon: Icons.language,
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.translate),
                    title: Text(AppLocalizations.of(context).selectLanguage),
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
                ),

                const SizedBox(height: 24),

                // App Settings Section
                SectionHeader(
                  title: AppLocalizations.of(context).settings,
                  icon: Icons.settings,
                ),
                const AppSettingsSection(),

                const SizedBox(height: 24),

                // Device Settings Section
                SectionHeader(
                  title: AppLocalizations.of(context).deviceSettings,
                  icon: Icons.devices,
                ),
                const DeviceSettingsSection(),

                const SizedBox(height: 24),

                // Support Section
                SectionHeader(
                  title: AppLocalizations.of(context).support,
                  icon: Icons.help,
                ),
                const SupportSection(),

                const SizedBox(height: 32),

                // Sign out button
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: AppLocalizations.of(context).signOut,
                    icon: Icons.logout,
                    onPressed: () => _handleSignOut(context),
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    fontFamily: 'NeoSansArabic',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const LanguageDialog());
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
