import 'package:flutter/material.dart';
import '../../../../l10n/generated/app_localizations.dart';

class AddDeviceInfoCard extends StatelessWidget {
  const AddDeviceInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: Colors.amber[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppLocalizations.of(context).patientDataInfo,
              style: const TextStyle(fontSize: 13, fontFamily: 'NeoSansArabic'),
            ),
          ),
        ],
      ),
    );
  }
}
