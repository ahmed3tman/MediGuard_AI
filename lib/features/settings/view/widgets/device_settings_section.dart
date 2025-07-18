import 'package:flutter/material.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../../core/shared/widgets/floating_snackbar.dart';

class DeviceSettingsSection extends StatelessWidget {
  const DeviceSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.wifi),
            title: Text(AppLocalizations.of(context).wifiSettings),
            subtitle: Text(AppLocalizations.of(context).manageConnections),
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
            title: Text(AppLocalizations.of(context).bluetoothSettings),
            subtitle: Text(AppLocalizations.of(context).manageDevices),
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
