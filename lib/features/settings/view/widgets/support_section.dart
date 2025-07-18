import 'package:flutter/material.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../../core/shared/widgets/floating_snackbar.dart';

class SupportSection extends StatelessWidget {
  const SupportSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
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
        ],
      ),
    );
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
}
