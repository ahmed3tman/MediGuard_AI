import 'dart:ui';
import 'package:flutter/material.dart';
import '../../model/data_model.dart';
import '../../cubit/device_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/generated/app_localizations.dart';

enum VitalSignType { temperature, ecg, spo2, bloodPressure, unknown }

class DeviceCard extends StatelessWidget {
  final Device device;

  const DeviceCard({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                // Header with device name and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        device.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                      ),
                    ),
                    Row(
                      children: [
                        // WiFi status icon only
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: device.hasValidReadings
                                ? Colors.green.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            device.hasValidReadings
                                ? Icons.wifi
                                : Icons.wifi_off,
                            color: device.hasValidReadings
                                ? Colors.green[600]
                                : Colors.grey[500],
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Delete button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _showDeleteDialog(context),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                Icons.delete_outline,
                                color: Colors.red[400],
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'ID: ${device.deviceId}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),

                // Vital signs grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 4.0,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  children: [
                    _buildVitalSignTile(
                      icon: Icons.thermostat,
                      title: AppLocalizations.of(context).temperature,
                      value: '${device.temperature.toStringAsFixed(1)}°C',
                      isNormal: device.isTemperatureNormal,
                      color: Colors.orange,
                      context: context,
                    ),
                    _buildVitalSignTile(
                      icon: Icons.favorite,
                      title: AppLocalizations.of(context).ecg,
                      value: '${device.ecg.toStringAsFixed(0)} BPM',
                      isNormal: device.ecg >= 60 && device.ecg <= 100,
                      color: Colors.red,
                      context: context,
                    ),
                    _buildVitalSignTile(
                      icon: Icons.air,
                      title: AppLocalizations.of(context).spo2,
                      value: '${device.spo2.toStringAsFixed(0)}%',
                      isNormal: device.isSpo2Normal,
                      color: Colors.blue,
                      context: context,
                    ),
                    _buildVitalSignTile(
                      icon: Icons.monitor_heart,
                      title: AppLocalizations.of(context).bloodPressure,
                      value:
                          '${device.bloodPressure['systolic']}/${device.bloodPressure['diastolic']}',
                      isNormal: device.isBloodPressureNormal,
                      color: Colors.purple,
                      context: context,
                    ),
                  ],
                ),
                SizedBox(height: 14),
                // Status and last updated information
                if (device.hasValidReadings && device.lastUpdated != null)
                  Text(
                    '${AppLocalizations.of(context).lastUpdated}: ${_formatDateTime(device.lastUpdated!, context)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                  )
                else if (device.hasValidReadings)
                  Text(
                    AppLocalizations.of(context).deviceConnected,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green[600],
                      fontSize: 12,
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Text(
                      AppLocalizations.of(context).waitingForDeviceData,
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVitalSignTile({
    required IconData icon,
    required String title,
    required String value,
    required bool isNormal,
    required Color color,
    required BuildContext context,
  }) {
    // Check if this specific reading has valid data
    bool hasValidReading = false;
    String displayValue = AppLocalizations.of(context).notConnected;

    // Check reading validity using helper method
    VitalSignType signType = _getVitalSignType(title, context);

    switch (signType) {
      case VitalSignType.temperature:
        if (device.temperature > 0) {
          hasValidReading = true;
          displayValue = value;
        }
        break;
      case VitalSignType.ecg:
        if (device.ecg > 0) {
          hasValidReading = true;
          displayValue = value;
        }
        break;
      case VitalSignType.spo2:
        if (device.spo2 > 0) {
          hasValidReading = true;
          displayValue = value;
        }
        break;
      case VitalSignType.bloodPressure:
        if (device.bloodPressure['systolic']! > 0 ||
            device.bloodPressure['diastolic']! > 0) {
          hasValidReading = true;
          displayValue = value;
        }
        break;
      case VitalSignType.unknown:
        // Keep default values
        break;
    }

    final displayColor = hasValidReading
        ? (isNormal ? Colors.green : Colors.red)
        : Colors.grey;

    // Use grey color for background when no data is available
    final backgroundColors = hasValidReading
        ? [color.withOpacity(0.1), color.withOpacity(0.05)]
        : [Colors.grey.withOpacity(0.1), Colors.grey.withOpacity(0.05)];

    // Add red stroke for dangerous readings
    final borderColor = hasValidReading && !isNormal
        ? Colors.red
        : displayColor.withOpacity(0.3);
    final borderWidth = hasValidReading && !isNormal ? 1.5 : 1.0;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: backgroundColors,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: hasValidReading
                  ? color.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              hasValidReading ? icon : Icons.signal_wifi_off,
              color: hasValidReading ? color : Colors.grey[500],
              size: 12,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: hasValidReading ? Colors.grey[800] : Colors.grey[500],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            displayValue,
            style: TextStyle(
              fontSize: hasValidReading ? 10 : 9,
              fontWeight: FontWeight.w700,
              color: displayColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime, BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return AppLocalizations.of(context).justNow;
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  VitalSignType _getVitalSignType(String title, BuildContext context) {
    if (title == AppLocalizations.of(context).temperature ||
        title == 'Temperature') {
      return VitalSignType.temperature;
    } else if (title == AppLocalizations.of(context).ecg || title == 'ECG') {
      return VitalSignType.ecg;
    } else if (title == AppLocalizations.of(context).spo2 || title == 'SpO2') {
      return VitalSignType.spo2;
    } else if (title == AppLocalizations.of(context).bloodPressure ||
        title == 'Blood Pressure') {
      return VitalSignType.bloodPressure;
    }
    return VitalSignType.unknown;
  }

  void _showDeleteDialog(BuildContext context) {
    final deviceCubit = context.read<DeviceCubit>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).deleteDevice),
        content: Text(
          AppLocalizations.of(context).deleteDeviceConfirm(device.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              deviceCubit.deleteDevice(device.deviceId);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context).delete),
          ),
        ],
      ),
    );
  }
}
