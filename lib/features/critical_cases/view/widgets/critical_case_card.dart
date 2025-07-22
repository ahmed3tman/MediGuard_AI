import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spider_doctor/features/critical_cases/cubit/critical_cases_cubit.dart';
import 'package:spider_doctor/features/critical_cases/model/critical_case_model.dart';
import 'package:spider_doctor/features/devices/model/data_model.dart';
import 'package:spider_doctor/features/patient_detail/view/screens/patient_detail_screen.dart';
import 'package:spider_doctor/l10n/generated/app_localizations.dart';

class CriticalCaseCard extends StatelessWidget {
  final CriticalCase criticalCase;

  const CriticalCaseCard({super.key, required this.criticalCase});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final device = Device(
          deviceId: criticalCase.deviceId,
          name: criticalCase.name,
          lastUpdated: criticalCase.lastUpdated,
          readings: {
            'temperature': criticalCase.temperature,
            'ecg': criticalCase.ecg,
            'spo2': criticalCase.spo2,
            'bloodPressure': criticalCase.bloodPressure,
          },
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PatientDetailScreen(device: device),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.9),
              Colors.white.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CriticalCaseHeader(
                    patientName: criticalCase.name,
                    onRemove: () {
                      context.read<CriticalCasesCubit>().removeCriticalCase(
                        criticalCase.deviceId,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _VitalSignsDisplay(criticalCase: criticalCase),
                  const SizedBox(height: 16),
                  _CriticalCaseFooter(lastUpdated: criticalCase.lastUpdated),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CriticalCaseHeader extends StatelessWidget {
  final String patientName;
  final VoidCallback onRemove;

  const _CriticalCaseHeader({
    required this.patientName,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          patientName,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(6),
              child: Icon(Icons.close, color: Colors.red[300], size: 16),
            ),
          ),
        ),
      ],
    );
  }
}

class _VitalSignsDisplay extends StatelessWidget {
  final CriticalCase criticalCase;
  const _VitalSignsDisplay({required this.criticalCase});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _VitalSignChip(
                icon: Icons.thermostat,
                label: l10n.temperature,
                value: '${criticalCase.temperature.toStringAsFixed(1)}°C',
                isNormal: criticalCase.isTemperatureNormal,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _VitalSignChip(
                icon: Icons.favorite_border,
                label: l10n.ecg,
                value: '${criticalCase.ecg.toInt()} BPM',
                isNormal: criticalCase.isEcgNormal,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _VitalSignChip(
                icon: Icons.air,
                label: l10n.spo2,
                value: '${criticalCase.spo2.toInt()}%',
                isNormal: criticalCase.isSpo2Normal,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _VitalSignChip(
                icon: Icons.monitor_heart_outlined,
                label: l10n.bloodPressure,
                value:
                    '${criticalCase.bloodPressure['systolic']}/${criticalCase.bloodPressure['diastolic']}',
                isNormal: criticalCase.isBloodPressureNormal,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _VitalSignChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isNormal;
  final Color color;

  const _VitalSignChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.isNormal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isNormal ? Colors.green[600] : Colors.red[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CriticalCaseFooter extends StatelessWidget {
  final DateTime lastUpdated;

  const _CriticalCaseFooter({required this.lastUpdated});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(Icons.update, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          _formatDateTime(lastUpdated, context),
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime, BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return AppLocalizations.of(context).justNow;
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}
