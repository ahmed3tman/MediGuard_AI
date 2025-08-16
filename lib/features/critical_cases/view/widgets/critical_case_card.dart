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
  final bool isDeleting;

  const CriticalCaseCard({
    super.key,
    required this.criticalCase,
    this.isDeleting = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // اعتبر الداتا غير متصلة إذا كانت قديمة (أكثر من 10 دقائق) أو لا توجد بيانات حقيقية
    final now = DateTime.now();
    bool noData =
        (criticalCase.temperature == 0.0) &&
        (criticalCase.heartRate == 0.0) &&
        (criticalCase.spo2 == 0.0) &&
        ((criticalCase.bloodPressure['systolic'] ?? 0) == 0) &&
        ((criticalCase.bloodPressure['diastolic'] ?? 0) == 0);
    final age = now.difference(criticalCase.lastUpdated);
    // Tri-state:
    // 1) Not connected: no data at all
    final bool triNotConnected = noData;
    // 2) Real-time: lastUpdated within 5 seconds
    final bool triRealtime = !triNotConnected && age.inSeconds <= 5;
    // 3) Else: stale -> show last updated since
    final bool isNotConnected = triNotConnected;

    return InkWell(
      onTap: () {
        final device = Device(
          deviceId: criticalCase.deviceId,
          name: criticalCase.name,
          lastUpdated: criticalCase.lastUpdated,
          readings: {
            'temperature': criticalCase.temperature,
            'heartRate': criticalCase.heartRate,
            'ecgData': criticalCase.ecgData,
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
          border: Border.all(
            color: isNotConnected
                ? Colors.grey[400]!
                : Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: isNotConnected
                        ? Colors.grey[200]
                        : Colors.green[100],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isNotConnected ? Icons.wifi_off : Icons.wifi,
                        color: isNotConnected
                            ? Colors.grey[500]
                            : Colors.green[700],
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        triRealtime
                            ? l10n.connected
                            : (isNotConnected
                                  ? l10n.notConnected
                                  : l10n.lastUpdated),
                        style: TextStyle(
                          color: isNotConnected
                              ? Colors.grey
                              : Colors.green[700],
                          fontWeight: FontWeight.bold,
                          fontFamily: 'NeoSansArabic',
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CriticalCaseHeader(
                        patientName: criticalCase.name,
                        isDeleting: isDeleting,
                        onRemove: () {
                          context.read<CriticalCasesCubit>().removeCriticalCase(
                            criticalCase.deviceId,
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _VitalSignsDisplay(
                        criticalCase: criticalCase,
                        isNotConnected: isNotConnected,
                      ),
                      const SizedBox(height: 16),
                      if (!triRealtime && !triNotConnected)
                        _CriticalCaseFooter(
                          lastUpdated: criticalCase.lastUpdated,
                        ),
                    ],
                  ),
                ),
              ],
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
  final bool isDeleting;

  const _CriticalCaseHeader({
    required this.patientName,
    required this.onRemove,
    this.isDeleting = false,
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
            fontSize: 18,
            color: Colors.grey[800],
            fontFamily: 'NeoSansArabic',
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDeleting ? null : onRemove,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(6),
              child: isDeleting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.red[300]!,
                        ),
                      ),
                    )
                  : Icon(Icons.close, color: Colors.red[300], size: 20),
            ),
          ),
        ),
      ],
    );
  }
}

class _VitalSignsDisplay extends StatelessWidget {
  final CriticalCase criticalCase;
  final bool isNotConnected;
  const _VitalSignsDisplay({
    required this.criticalCase,
    required this.isNotConnected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Color getColor(Color mainColor, bool hasData) =>
        hasData ? mainColor : Colors.grey[400]!;
    bool hasTemp = criticalCase.temperature != 0.0;
    bool hasHeartRate = criticalCase.heartRate != 0.0;
    bool hasSpo2 = criticalCase.spo2 != 0.0;
    bool hasBP =
        (criticalCase.bloodPressure['systolic'] ?? 0) != 0 &&
        (criticalCase.bloodPressure['diastolic'] ?? 0) != 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _VitalSignChip(
                icon: Icons.thermostat,
                label: l10n.temperature,
                value: hasTemp
                    ? '${criticalCase.temperature.toStringAsFixed(1)}°C'
                    : '--',
                isNormal: criticalCase.isTemperatureNormal,
                color: getColor(Colors.orange, hasTemp),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _VitalSignChip(
                icon: Icons.favorite_border,
                label: l10n.heartRate,
                value: hasHeartRate
                    ? '${criticalCase.heartRate.toInt()} BPM'
                    : '--',
                isNormal: criticalCase.isHeartRateNormal,
                color: getColor(Colors.pink, hasHeartRate),
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
                value: hasSpo2 ? '${criticalCase.spo2.toInt()}%' : '--',
                isNormal: criticalCase.isSpo2Normal,
                color: getColor(Colors.blue, hasSpo2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _VitalSignChip(
                icon: Icons.monitor_heart_outlined,
                label: l10n.bloodPressure,
                value: hasBP
                    ? '${criticalCase.bloodPressure['systolic']}/${criticalCase.bloodPressure['diastolic']}'
                    : '--',
                isNormal: criticalCase.isBloodPressureNormal,
                color: getColor(Colors.deepPurple, hasBP),
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
    // Determine if the color is faded (i.e., no data)
    final bool isFaded = color == Colors.grey[400];
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
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
        ),
        // Show the red warning only if there is data (not faded) and not normal
        if (!isNormal && !isFaded)
          Positioned(
            top: -8,
            right: -8,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.error_outline, color: Colors.white, size: 16),
              ),
            ),
          ),
      ],
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
