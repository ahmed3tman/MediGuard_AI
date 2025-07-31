import 'package:flutter/material.dart';
import 'package:spider_doctor/l10n/generated/app_localizations.dart';
import '../../../patient_detail/model/patient_vital_signs.dart';

class PatientHeaderCard extends StatelessWidget {
  final PatientVitalSigns vitalSigns;
  final AppLocalizations l10n;
  final bool isLive;

  const PatientHeaderCard({
    super.key,
    required this.vitalSigns,
    required this.l10n,
    required this.isLive,
  });

  String _formatTime(DateTime dateTime, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inSeconds < 60) {
      return l10n.timeJustNow;
    } else if (difference.inMinutes < 60) {
      return l10n.timeMinutesAgo(difference.inMinutes.toString());
    } else if (difference.inHours < 24) {
      return l10n.timeHoursAgo(difference.inHours.toString());
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.2), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vitalSigns.patientName,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NeoSansArabic',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${l10n.deviceIdLabel}${vitalSigns.deviceId}',
                  style: const TextStyle(
                    color: Color(0xFF757575),
                    fontSize: 14,
                    fontFamily: 'NeoSansArabic',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${l10n.lastUpdatedLabel}${_formatTime(vitalSigns.timestamp, l10n)}',
                  style: const TextStyle(
                    color: Color(0xFFBDBDBD),
                    fontSize: 12,
                    fontFamily: 'NeoSansArabic',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isLive ? Colors.green[100] : Colors.red[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isLive ? Colors.green : Colors.red,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.wifi,
                  color: isLive ? Colors.green[800] : Colors.red[700],
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  isLive ? l10n.liveStatus : l10n.offlineStatus,
                  style: TextStyle(
                    color: isLive ? Colors.green[800] : Colors.red[700],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
