import 'package:flutter/material.dart';
import 'package:spider_doctor/l10n/generated/app_localizations.dart';

class MonitoringControlsCard extends StatelessWidget {
  final AppLocalizations l10n;
  const MonitoringControlsCard({super.key, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.monitoringControlsTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: 'NeoSansArabic',
            ),
          ),

          const SizedBox(height: 8),
          Text(
            l10n.monitoringControlsDescription,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
